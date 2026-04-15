package com.animaltracking.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

@Entity
@Table(name = "RfidTags") // Corrigé pour correspondre au SQL (Majuscules, pas de tiret)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RfidTag {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @Column(name = "UniqueRfidCode", nullable = false, unique = true)
    private String uniqueRfidCode;

    @Column(name = "HardwareStatus")
    @Enumerated(EnumType.STRING)
    private HardwareStatus hardwareStatus;
}