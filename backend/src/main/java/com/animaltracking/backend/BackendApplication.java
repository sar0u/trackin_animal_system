package com.animaltracking.backend;

import com.animaltracking.backend.entity.User;
import com.animaltracking.backend.entity.UserRole;
import com.animaltracking.backend.repository.UserRepository;
import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;

@OpenAPIDefinition(
        info = @Info(title = "API Animal Tracking", version = "1.0", description = "Documentation de l'API REST pour le PFE"),
        security = @SecurityRequirement(name = "bearerAuth")
)
@SecurityScheme(
        name = "bearerAuth",
        type = SecuritySchemeType.HTTP,
        scheme = "bearer",
        bearerFormat = "JWT"
)
@SpringBootApplication
public class BackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(BackendApplication.class, args);
    }

    // --- LE CODE MAGIQUE SANS SQL ---
    @Bean
    CommandLineRunner initDatabase(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        return args -> {
            // On vérifie si l'email existe déjà pour ne pas le créer 100 fois
            if (userRepository.findByEmailAddress("admin@test.com").isEmpty()) {

                User admin = new User();
                admin.setEmailAddress("admin@test.com");

                // Spring Boot va crypter "admin123" en BCrypt tout seul ici !
                admin.setEncryptedPassword(passwordEncoder.encode("admin123"));

                admin.setFirstName("Wassim");
                admin.setLastName("Elrifai");
                admin.setUserRole(UserRole.Administrator);
                admin.setIsActive(true);

                userRepository.save(admin);
                System.out.println("✅ UTILISATEUR ADMIN CRÉÉ AVEC SUCCÈS PAR SPRING BOOT !");
            } else {
                System.out.println("✅ L'utilisateur Admin existe déjà.");
            }
        };
    }
}