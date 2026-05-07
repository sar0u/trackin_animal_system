package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.User;
import com.animaltracking.backend.entity.UserRole;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    Optional<User> findByUsername(String username);

    Boolean existsByEmail(String email);

    List<User> findByRole(UserRole role);
}