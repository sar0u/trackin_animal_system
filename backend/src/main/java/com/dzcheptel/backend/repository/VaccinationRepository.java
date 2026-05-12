package com.dzcheptel.backend.repository;

import com.dzcheptel.backend.entity.Vaccination;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface VaccinationRepository extends JpaRepository<Vaccination, Long> {

    @Query("SELECT DISTINCT v FROM Vaccination v "
            + "LEFT JOIN FETCH v.healthRecord hr "
            + "LEFT JOIN FETCH hr.animal a "
            + "LEFT JOIN FETCH a.rfidTagEntity "
            + "LEFT JOIN FETCH a.owner "
            + "LEFT JOIN FETCH a.farm "
            + "LEFT JOIN FETCH hr.veterinarian "
            + "LEFT JOIN FETCH v.administeredBy")
    List<Vaccination> findAllFetched();

    List<Vaccination> findByHealthRecordId(Long healthRecordId);

    List<Vaccination> findByVaccineNameContaining(String name);
}