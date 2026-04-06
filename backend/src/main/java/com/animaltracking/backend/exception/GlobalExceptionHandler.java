package com.animaltracking.backend.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

@ControllerAdvice
public class GlobalExceptionHandler {

    // Gère les erreurs 404 classiques
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<Map<String, String>> handleNotFound(ResourceNotFoundException ex) {
        Map<String, String> response = new HashMap<>();
        response.put("status", "404");
        response.put("error", "Not Found");
        response.put("message", ex.getMessage());
        return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
    }

    // LE COUP DE GÉNIE : Capte les erreurs de tes Triggers SQL (SQLSTATE 45000)
    @ExceptionHandler(SQLException.class)
    public ResponseEntity<Map<String, String>> handleSqlException(SQLException ex) {
        Map<String, String> response = new HashMap<>();
        response.put("status", "400");
        response.put("error", "Règle Métier Non Respectée");

        // Si c'est ton trigger (45000), on affiche ton message personnalisé
        if ("45000".equals(ex.getSQLState())) {
            response.put("message", ex.getMessage());
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
        }

        response.put("message", "Erreur d'intégrité de la base de données.");
        return new ResponseEntity<>(response, HttpStatus.CONFLICT);
    }

    // Gère toutes les autres erreurs
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, String>> handleGeneralError(Exception ex) {
        Map<String, String> response = new HashMap<>();
        response.put("status", "500");
        response.put("error", "Internal Server Error");
        response.put("message", ex.getMessage());
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}