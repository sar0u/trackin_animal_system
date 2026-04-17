package com.animaltracking.backend.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    public void sendResetCode(String toEmail, String code) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom("ton.email@gmail.com"); // Le même que dans application.properties
        message.setTo(toEmail);
        message.setSubject("DZCheptel - Code de réinitialisation");
        message.setText("Bonjour,\n\n" +
                "Vous avez demandé la réinitialisation de votre mot de passe.\n" +
                "Voici votre code de sécurité à 6 chiffres : " + code + "\n\n" +
                "Ce code expirera dans 15 minutes.\n" +
                "L'équipe DZCheptel.");

        mailSender.send(message);
    }
}