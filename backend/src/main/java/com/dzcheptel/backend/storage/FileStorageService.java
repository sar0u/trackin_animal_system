package com.dzcheptel.backend.storage;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Service
public class FileStorageService {

    @Value("${file.upload-dir}")
    private String uploadDir;

    private Path rootLocation;

    @PostConstruct
    public void init() {
        try {
            this.rootLocation = Paths.get(uploadDir).toAbsolutePath().normalize();
            Files.createDirectories(rootLocation);
            Files.createDirectories(rootLocation.resolve("photos"));
            Files.createDirectories(rootLocation.resolve("audio"));
            System.out.println("Upload dir initialised: " + rootLocation);
        } catch (IOException e) {
            throw new RuntimeException("Impossible de créer le dossier upload", e);
        }
    }

    public String storeFile(MultipartFile file, String subFolder) {
        if (file.isEmpty()) {
            throw new RuntimeException("Le fichier est vide");
        }

        try {
            String originalFileName = file.getOriginalFilename();
            if (originalFileName == null) originalFileName = "file";

            String extension = "";
            int dotIndex = originalFileName.lastIndexOf('.');
            if (dotIndex > 0) {
                extension = originalFileName.substring(dotIndex);
            }

            String uniqueFileName = UUID.randomUUID() + extension;
            Path targetLocation = rootLocation.resolve(subFolder).resolve(uniqueFileName);
            Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);
            return uniqueFileName;
        } catch (IOException e) {
            throw new RuntimeException("Erreur lors du stockage du fichier", e);
        }
    }

    public Resource loadFileAsResource(String fileName, String subFolder) {
        try {
            Path filePath = rootLocation.resolve(subFolder).resolve(fileName).normalize();
            Resource resource = new UrlResource(filePath.toUri());
            if (resource.exists() && resource.isReadable()) return resource;
            throw new RuntimeException("Fichier introuvable: " + fileName);
        } catch (MalformedURLException e) {
            throw new RuntimeException("Fichier introuvable: " + fileName, e);
        }
    }

    public boolean deleteFile(String fileName, String subFolder) {
        try {
            Path filePath = rootLocation.resolve(subFolder).resolve(fileName).normalize();
            return Files.deleteIfExists(filePath);
        } catch (IOException e) {
            return false;
        }
    }
}
