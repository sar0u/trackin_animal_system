package com.animaltracking.backend.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;

@Component
public class JwtUtils {

    // Clé pour signer les tokens JWT
    private final Key jwtSecret = Keys.secretKeyFor(SignatureAlgorithm.HS256);

    private final long jwtExpirationMs     = 86_400_000L;        // expiration par défaut: 24h
    private final long jwtRememberMeMs     = 30L * 86_400_000L;  // expiration si "rester connecté": 30 jours

    public String generateJwtToken(Authentication authentication) {
        return generateJwtToken(authentication, false);
    }

    public String generateJwtToken(Authentication authentication, boolean rememberMe) {
        UserDetails userPrincipal = (UserDetails) authentication.getPrincipal();
        long expiry = rememberMe ? jwtRememberMeMs : jwtExpirationMs;

        return Jwts.builder()
                .setSubject(userPrincipal.getUsername())
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + expiry))
                .signWith(jwtSecret)
                .compact();
    }

    public String getUserNameFromJwtToken(String token) {
        return Jwts.parserBuilder().setSigningKey(jwtSecret).build().parseClaimsJws(token).getBody().getSubject();
    }

    public boolean validateJwtToken(String authToken) {
        try {
            Jwts.parserBuilder().setSigningKey(jwtSecret).build().parseClaimsJws(authToken);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            System.err.println("Token JWT Invalide : " + e.getMessage());
        }
        return false;
    }
}