package com.animaltracking.backend.service.impl;

import com.animaltracking.backend.service.AuthService;
import org.springframework.stereotype.Service;

@Service
public class AuthServiceImpl implements AuthService {

    @Override
    public String login(String email, String password) {
        // Mock implementation - real auth is handled by Spring Security
        return "Login successful for: " + email;
    }
}