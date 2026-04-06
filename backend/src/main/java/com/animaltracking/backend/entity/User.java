package com.animaltracking.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.time.LocalDateTime;

@Entity
@Table(name = "Users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @Column(name = "EmailAddress", unique = true, nullable = false)
    private String emailAddress;

    @Column(name = "EncryptedPassword", nullable = false)
    private String encryptedPassword;

    @Column(name = "FirstName", nullable = false)
    private String firstName;

    @Column(name = "LastName", nullable = false)
    private String lastName;

    @Column(name = "UserRole", nullable = false)
    @Enumerated(EnumType.STRING)
    private UserRole userRole;

    @Column(name = "IsActive")
    private Boolean isActive;

    @Column(name = "CreationTimestamp", updatable = false, insertable = false)
    private LocalDateTime creationTimestamp;

    // --- COLONNES NON PRÉSENTES DANS LE SQL ---
    // On utilise @Transient pour que Hibernate ne les cherche pas dans MySQL

    @Transient
    private Integer failedLoginAttempts;

    @Transient
    private LocalDateTime lastLoginTimestamp;

    @Transient
    private LocalDateTime passwordLastChangedAt;
}