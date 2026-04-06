package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.User;
import com.animaltracking.backend.entity.UserRole;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Integer> {

    Optional<User> findByEmailAddress(String emailAddress);

    Boolean existsByEmailAddress(String emailAddress);

    List<User> findByUserRole(UserRole userRole);

    List<User> findByIsActive(Boolean isActive);

    List<User> findByUserRoleAndIsActive(UserRole role, Boolean isActive);

    List<User> findByCreationTimestampBetween(LocalDateTime start, LocalDateTime end);

    List<User> findByLastLoginTimestampBefore(LocalDateTime date);
}