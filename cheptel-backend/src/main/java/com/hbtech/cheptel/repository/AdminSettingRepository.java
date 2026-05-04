package com.hbtech.cheptel.repository;

import com.hbtech.cheptel.entity.AdminSetting;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AdminSettingRepository extends JpaRepository<AdminSetting, Integer> {

    Optional<AdminSetting> findBySettingKey(String settingKey);
}