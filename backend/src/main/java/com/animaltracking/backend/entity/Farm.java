package com.animaltracking.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "Farms") // Correspond au SQL
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Farm {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "OwnerId", nullable = false)
    private User owner;

    @Column(name = "Status")
    private String status = "Active";

    @Column(name = "FarmName", nullable = false)
    private String farmName;

    @Column(name = "GeographicAddress")
    private String geographicAddress;

    @Column(name = "LatitudeCoordinate")
    private Double latitudeCoordinate;

    @Column(name = "LongitudeCoordinate")
    private Double longitudeCoordinate;

    @Column(name = "Capacity")
    private Double capacity;

}