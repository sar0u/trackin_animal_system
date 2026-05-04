package com.hbtech.cheptel.service;

import com.hbtech.cheptel.entity.User;
import com.hbtech.cheptel.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class PasswordResetService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;

    private final Map<String, ResetEntry> resetCodes = new ConcurrentHashMap<>();

    public PasswordResetService(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            EmailService emailService
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.emailService = emailService;
    }

    public boolean sendCode(String contact) {
        contact = contact.trim().toLowerCase();

        // Chercher par email
        Optional<User> userOpt = userRepository.findByEmail(contact);

        // Si non trouvé, chercher par téléphone
        if (userOpt.isEmpty()) {
            userOpt = userRepository.findByPhoneNumber(contact);
        }

        // Si non trouvé, chercher par username
        if (userOpt.isEmpty()) {
            userOpt = userRepository.findByUsername(contact);
        }

        if (userOpt.isEmpty()) {
            System.out.println("Aucun utilisateur trouvé pour : " + contact);
            // On retourne true pour ne pas révéler si le compte existe
            return true;
        }

        User user = userOpt.get();

        String code = generateCode();
        LocalDateTime expiry = LocalDateTime.now().plusMinutes(15);

        resetCodes.put(contact, new ResetEntry(code, user.getId(), expiry));

        System.out.println("=========================");
        System.out.println("CODE RESET POUR : " + contact);
        System.out.println("CODE              : " + code);
        System.out.println("EXPIRE À          : " + expiry);
        System.out.println("=========================");

        // Envoyer email si l'utilisateur a un email
        if (user.getEmail() != null && !user.getEmail().isBlank()) {
            String emailToSend = user.getEmail();
            boolean sent = emailService.sendResetCode(emailToSend, code);

            if (!sent) {
                System.out.println("Email non envoyé. Code disponible dans la console.");
            }
        } else {
            System.out.println("Pas d'email. Code disponible dans la console.");
        }

        return true;
    }

    public boolean verifyCode(String contact, String code) {
        contact = contact.trim().toLowerCase();
        code = code.trim();

        ResetEntry entry = resetCodes.get(contact);

        if (entry == null) {
            System.out.println("Aucune entrée pour : " + contact);
            return false;
        }

        if (LocalDateTime.now().isAfter(entry.expiry())) {
            resetCodes.remove(contact);
            System.out.println("Code expiré pour : " + contact);
            return false;
        }

        if (!entry.code().equals(code)) {
            System.out.println("Code incorrect pour : " + contact);
            return false;
        }

        return true;
    }

    public boolean resetPassword(String contact, String code, String newPassword) {
        contact = contact.trim().toLowerCase();
        code = code.trim();

        ResetEntry entry = resetCodes.get(contact);

        if (entry == null) {
            return false;
        }

        if (LocalDateTime.now().isAfter(entry.expiry())) {
            resetCodes.remove(contact);
            return false;
        }

        if (!entry.code().equals(code)) {
            return false;
        }

        Optional<User> userOpt = userRepository.findById(entry.userId());

        if (userOpt.isEmpty()) {
            return false;
        }

        User user = userOpt.get();
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        resetCodes.remove(contact);

        System.out.println("✅ Mot de passe réinitialisé pour : " + user.getUsername());

        return true;
    }

    private String generateCode() {
        return String.format("%06d", new Random().nextInt(999999));
    }

    private record ResetEntry(
            String code,
            Long userId,
            LocalDateTime expiry
    ) {}
}