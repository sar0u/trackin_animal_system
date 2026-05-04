package com.hbtech.cheptel.controller;

import com.hbtech.cheptel.entity.Farm;
import com.hbtech.cheptel.repository.FarmRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/farms")
public class FarmController {

  private final FarmRepository farmRepository;

  public FarmController(FarmRepository farmRepository) {
    this.farmRepository = farmRepository;
  }

  @GetMapping
  @PreAuthorize("hasAnyRole('VETERINAIRE','CONTROLEUR','ADMIN')")
  public ResponseEntity<List<Map<String, Object>>> getAllFarms() {

    List<Map<String, Object>> result = farmRepository.findAll()
            .stream()
            .map(farm -> {
              Map<String, Object> map = new HashMap<>();
              map.put("id", farm.getId());
              map.put("name", farm.getName());
              map.put("location", farm.getLocation());
              map.put("wilaya", farm.getWilaya());
              map.put("commune", farm.getCommune());
              return map;
            })
            .toList();

    return ResponseEntity.ok(result);
  }
}