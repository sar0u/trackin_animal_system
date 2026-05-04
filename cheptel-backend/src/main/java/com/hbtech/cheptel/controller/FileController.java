package com.hbtech.cheptel.controller;

import com.hbtech.cheptel.storage.FileStorageService;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/files")
public class FileController {

    private final FileStorageService fileStorageService;

    public FileController(FileStorageService fileStorageService) {
        this.fileStorageService = fileStorageService;
    }

    /**
     * Upload une photo
     * POST /files/upload/photo
     * Body: multipart/form-data avec champ "file"
     */
    @PostMapping("/upload/photo")
    @PreAuthorize("hasAnyRole('FERMIER','VETERINAIRE','CONTROLEUR','ADMIN')")
    public ResponseEntity<Map<String, String>> uploadPhoto(@RequestParam("file") MultipartFile file) {

        String fileName = fileStorageService.storeFile(file, "photos");

        // URL accessible publiquement
        String fileUrl = "/api/v1/files/photos/" + fileName;

        Map<String, String> response = new HashMap<>();
        response.put("fileName", fileName);
        response.put("fileUrl", fileUrl);
        response.put("type", "photo");
        response.put("size", String.valueOf(file.getSize()));

        return ResponseEntity.ok(response);
    }

    /**
     * Upload un fichier audio (mémo vocal)
     * POST /files/upload/audio
     */
    @PostMapping("/upload/audio")
    @PreAuthorize("hasAnyRole('FERMIER','VETERINAIRE','CONTROLEUR','ADMIN')")
    public ResponseEntity<Map<String, String>> uploadAudio(@RequestParam("file") MultipartFile file) {

        String fileName = fileStorageService.storeFile(file, "audio");

        String fileUrl = "/api/v1/files/audio/" + fileName;

        Map<String, String> response = new HashMap<>();
        response.put("fileName", fileName);
        response.put("fileUrl", fileUrl);
        response.put("type", "audio");
        response.put("size", String.valueOf(file.getSize()));

        return ResponseEntity.ok(response);
    }

    /**
     * Récupérer une photo
     * GET /files/photos/{fileName}
     */
    @GetMapping("/photos/{fileName:.+}")
    public ResponseEntity<Resource> getPhoto(@PathVariable String fileName) {
        Resource file = fileStorageService.loadFileAsResource(fileName, "photos");

        return ResponseEntity.ok()
                .contentType(MediaType.IMAGE_JPEG)
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + file.getFilename() + "\"")
                .body(file);
    }

    /**
     * Récupérer un fichier audio
     * GET /files/audio/{fileName}
     */
    @GetMapping("/audio/{fileName:.+}")
    public ResponseEntity<Resource> getAudio(@PathVariable String fileName) {
        Resource file = fileStorageService.loadFileAsResource(fileName, "audio");

        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType("audio/mpeg"))
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + file.getFilename() + "\"")
                .body(file);
    }
}