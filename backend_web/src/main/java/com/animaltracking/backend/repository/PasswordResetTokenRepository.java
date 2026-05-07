package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.PasswordResetToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, Long> {

    Optional<PasswordResetToken> findTopByContactAndUsedFalseOrderByCreatedAtDesc(String contact);

    List<PasswordResetToken> findByUserId(Long userId);
}
