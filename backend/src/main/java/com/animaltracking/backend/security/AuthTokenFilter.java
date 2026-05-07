package com.animaltracking.backend.security;

import com.animaltracking.backend.service.CustomUserDetailsService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
public class AuthTokenFilter extends OncePerRequestFilter {

    @Autowired
    private JwtUtils jwtUtils;

    @Autowired
    private CustomUserDetailsService userDetailsService;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        try {
            String jwt = parseJwt(request);

            // 🟢 Vérification robuste : on n'analyse que si le JWT est présent et valide
            if (jwt != null && jwtUtils.validateJwtToken(jwt)) {

                // On récupère l'identifiant (Username ou Email selon ta config JwtUtils)
                String identifier = jwtUtils.getUserNameFromJwtToken(jwt);

                // Chargement des détails de l'utilisateur
                UserDetails userDetails = userDetailsService.loadUserByUsername(identifier);

                UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                        userDetails,
                        null,
                        userDetails.getAuthorities()
                );

                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

                // On définit l'authentification dans le contexte de sécurité
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception e) {
            // Log de l'erreur sans faire crasher tout le serveur (évite l'erreur 500 systématique)
            System.err.println("Impossible de définir l'authentification utilisateur: " + e.getMessage());
        }

        // On continue la chaîne de filtres quoi qu'il arrive
        filterChain.doFilter(request, response);
    }

    /**
     * Extrait le token JWT du header Authorization
     */
    private String parseJwt(HttpServletRequest request) {
        String headerAuth = request.getHeader("Authorization");

        if (StringUtils.hasText(headerAuth) && headerAuth.startsWith("Bearer ")) {
            String token = headerAuth.substring(7);

            // 🟢 PROTECTION CRITIQUE : Ignore les chaînes vides ou les textes "null"/"undefined"
            // envoyés par le frontend avant que l'utilisateur soit connecté.
            if (!token.isBlank() && !token.equals("null") && !token.equals("undefined")) {
                return token;
            }
        }
        return null;
    }
}