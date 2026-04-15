package com.animaltracking.backend.service.impl;

import com.animaltracking.backend.service.AuthService;
import org.springframework.stereotype.Service;

@Service
public class AuthServiceImpl implements AuthService {

    @Override
    public String login(String email, String password) {
        // temporaire (mock)
        return "Login successful for: " + email;
    }
}