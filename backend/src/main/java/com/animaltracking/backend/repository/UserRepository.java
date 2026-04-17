package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.User;
import com.animaltracking.backend.entity.UserRole;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Integer> {

    Optional<User> findByEmailAddress(String emailAddress);

    Optional<User> findByUsername(String username);

    Boolean existsByEmailAddress(String emailAddress);

    List<User> findByUserRole(UserRole userRole);

    List<User> findByCreationTimestampBetween(LocalDateTime start, LocalDateTime end);
}