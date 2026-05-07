package com.animaltracking.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
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

    @Column(name = "Username", unique = true, nullable = false)
    private String username;

    @Column(name = "EmailAddress", unique = true, nullable = false)
    private String emailAddress;

    // Ajout du champ téléphone ici
    @Column(name = "Phone")
    private String phone;

    @Column(name = "EncryptedPassword", nullable = false)
    private String encryptedPassword;

    @Column(name = "FirstName", nullable = false)
    private String firstName;

    @Column(name = "LastName", nullable = false)
    private String lastName;

    @Column(name = "UserRole", nullable = false)
    @Enumerated(EnumType.STRING)
    private UserRole userRole;

    @Column(name = "CreationTimestamp", updatable = false, insertable = false)
    private LocalDateTime creationTimestamp;

    @Column(name = "ResetCode")
    private String resetCode;

    @Column(name = "ResetCodeExpiration")
    private LocalDateTime resetCodeExpiration;

    @Transient
    private LocalDateTime lastLoginTimestamp;

}