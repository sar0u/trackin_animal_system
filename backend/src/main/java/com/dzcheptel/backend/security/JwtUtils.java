package com.dzcheptel.backend.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Component
public class JwtUtils {

    private final SecretKey jwtSecret;
    private final long jwtExpirationMs;
    private final long jwtRememberMeMs;

    public JwtUtils(
            @Value("${jwt.secret}") String secret,
            @Value("${jwt.expiration:86400000}") long expirationMs,
            @Value("${jwt.remember-me-expiration:2592000000}") long rememberMeMs) {
        this.jwtSecret = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.jwtExpirationMs = expirationMs;
        this.jwtRememberMeMs = rememberMeMs;
    }

    public String generateJwtToken(Authentication authentication) {
        return generateJwtToken(authentication, false, null, null);
    }

    public String generateJwtToken(Authentication authentication, boolean rememberMe) {
        return generateJwtToken(authentication, rememberMe, null, null);
    }

    public String generateJwtToken(Authentication authentication, boolean rememberMe, String role, Long farmId) {
        UserDetails userPrincipal = (UserDetails) authentication.getPrincipal();
        return generateJwtToken(userPrincipal.getUsername(), rememberMe, role, farmId);
    }

    public String generateJwtToken(String username, boolean rememberMe, String role, Long farmId) {
        long expiry = rememberMe ? jwtRememberMeMs : jwtExpirationMs;
        Map<String, Object> claims = new HashMap<>();
        if (role != null) claims.put("role", role);
        if (farmId != null) claims.put("farmId", farmId);

        return Jwts.builder()
                .claims(claims)
                .subject(username)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + expiry))
                .signWith(jwtSecret)
                .compact();
    }

    public String getUserNameFromJwtToken(String token) {
        return parseClaims(token).getSubject();
    }

    public String getRoleFromJwtToken(String token) {
        Object role = parseClaims(token).get("role");
        return role == null ? null : role.toString();
    }

    public Long getFarmIdFromJwtToken(String token) {
        Object farmId = parseClaims(token).get("farmId");
        if (farmId == null) return null;
        return Long.valueOf(farmId.toString());
    }

    public boolean validateJwtToken(String authToken) {
        try {
            parseClaims(authToken);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            System.err.println("Token JWT Invalide : " + e.getMessage());
        }
        return false;
    }

    private Claims parseClaims(String token) {
        return Jwts.parser()
                .verifyWith(jwtSecret)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}
