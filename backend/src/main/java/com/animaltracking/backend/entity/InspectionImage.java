package com.animaltracking.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "InspectionImages")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class InspectionImage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "InspectionId", nullable = false)
    @JsonIgnore
    private Inspection inspection;

    @Column(name = "ImageUrl", columnDefinition = "TEXT", nullable = false)
    private String imageUrl;
}