package com.dzcheptel.backend.exception;

import jakarta.persistence.EntityNotFoundException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.orm.jpa.JpaSystemException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

@ControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<Map<String, String>> handleEntityNotFound(EntityNotFoundException ex) {
        log.warn("Entity not found: {}", ex.getMessage());
        Map<String, String> response = new HashMap<>();
        response.put("status", "404");
        response.put("error", "Not Found");
        response.put("message", ex.getMessage());
        return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
    }

    // Gère les ressources non trouvées
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<Map<String, String>> handleNotFound(ResourceNotFoundException ex) {
        Map<String, String> response = new HashMap<>();
        response.put("status", "404");
        response.put("error", "Not Found");
        response.put("message", ex.getMessage());
        return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
    }

    // Capture les erreurs lancées par les triggers SQL (SQLSTATE 45000)
    @ExceptionHandler(SQLException.class)
    public ResponseEntity<Map<String, String>> handleSqlException(SQLException ex) {
        Map<String, String> response = new HashMap<>();
        response.put("status", "400");
        response.put("error", "Règle Métier Non Respectée");

        if ("45000".equals(ex.getSQLState())) {
            response.put("message", ex.getMessage());
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
        }

        response.put("message", "Erreur d'intégrité de la base de données.");
        return new ResponseEntity<>(response, HttpStatus.CONFLICT);
    }

    @ExceptionHandler({DataIntegrityViolationException.class, JpaSystemException.class})
    public ResponseEntity<Map<String, String>> handleDataIntegrity(Exception ex) {
        Map<String, String> response = new HashMap<>();
        response.put("status", "400");
        response.put("error", "Database Constraint Violation");

        Throwable cause = ex;
        while (cause != null) {
            if (cause instanceof SQLException sqlException) {
                if ("45000".equals(sqlException.getSQLState())) {
                    response.put("message", sqlException.getMessage());
                    return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
                }
                break;
            }
            cause = cause.getCause();
        }

        response.put("message", ex.getMessage());
        return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
    }

    // Gère toutes les autres erreurs
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, String>> handleGeneralError(Exception ex) {
        Throwable root = ex;
        while (root.getCause() != null && root.getCause() != root) {
            root = root.getCause();
        }
        log.error("Unhandled exception (root: {}): {}", root.getClass().getName(), root.getMessage(), ex);
        Map<String, String> response = new HashMap<>();
        response.put("status", "500");
        response.put("error", "Internal Server Error");
        response.put("message", ex.getMessage());
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}