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

    // Crée un utilisateur administrateur par défaut au démarrage de l'application
    @Bean
    CommandLineRunner initDatabase(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        return args -> {
            if (userRepository.findByUsername("superadmin").isEmpty()) {
                User admin = new User();
                admin.setUsername("superadmin");
                admin.setEmail("admin@dzcheptel.com");
                admin.setFirstName("Super");
                admin.setLastName("Admin");
                admin.setPassword(passwordEncoder.encode("admin123"));
                admin.setRole(UserRole.Administrator);

                userRepository.save(admin);
                System.out.println("Utilisateur superadmin créé par défaut !");
            } else {
                System.out.println("L'utilisateur superadmin existe déjà, aucune action requise.");
            }
        };
    }
}