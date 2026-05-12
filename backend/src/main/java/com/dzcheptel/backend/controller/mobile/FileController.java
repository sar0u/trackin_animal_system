package com.dzcheptel.backend.controller.mobile;

import com.dzcheptel.backend.storage.FileStorageService;
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
@RequestMapping("/mobile/files")
public class FileController {

    private final FileStorageService fileStorageService;

    public FileController(FileStorageService fileStorageService) {
        this.fileStorageService = fileStorageService;
    }

    @PostMapping("/upload/photo")
    @PreAuthorize("hasAnyRole('Farmer','Veterinarian','Inspector','Administrator')")
    public ResponseEntity<Map<String, String>> uploadPhoto(@RequestParam("file") MultipartFile file) {
        String fileName = fileStorageService.storeFile(file, "photos");
        Map<String, String> response = new HashMap<>();
        response.put("fileName", fileName);
        response.put("fileUrl", "/api/v1/mobile/files/photos/" + fileName);
        response.put("type", "photo");
        response.put("size", String.valueOf(file.getSize()));
        return ResponseEntity.ok(response);
    }

    @PostMapping("/upload/audio")
    @PreAuthorize("hasAnyRole('Farmer','Veterinarian','Inspector','Administrator')")
    public ResponseEntity<Map<String, String>> uploadAudio(@RequestParam("file") MultipartFile file) {
        String fileName = fileStorageService.storeFile(file, "audio");
        Map<String, String> response = new HashMap<>();
        response.put("fileName", fileName);
        response.put("fileUrl", "/api/v1/mobile/files/audio/" + fileName);
        response.put("type", "audio");
        response.put("size", String.valueOf(file.getSize()));
        return ResponseEntity.ok(response);
    }

    @GetMapping("/photos/{fileName:.+}")
    public ResponseEntity<Resource> getPhoto(@PathVariable String fileName) {
        Resource file = fileStorageService.loadFileAsResource(fileName, "photos");
        return ResponseEntity.ok()
                .contentType(MediaType.IMAGE_JPEG)
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + file.getFilename() + "\"")
                .body(file);
    }

    @GetMapping("/audio/{fileName:.+}")
    public ResponseEntity<Resource> getAudio(@PathVariable String fileName) {
        Resource file = fileStorageService.loadFileAsResource(fileName, "audio");
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType("audio/mpeg"))
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + file.getFilename() + "\"")
                .body(file);
    }
}
