package com.dzcheptel.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "rfid_tags")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RfidTag {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "rfid_code", nullable = false, unique = true)
    private String rfidCode;

    @Enumerated(EnumType.STRING)
    @Column(name = "tag_type")
    private TagType tagType;

    @Enumerated(EnumType.STRING)
    @Column(name = "tag_status")
    private HardwareStatus tagStatus;
}