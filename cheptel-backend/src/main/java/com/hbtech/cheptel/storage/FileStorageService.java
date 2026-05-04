package com.hbtech.cheptel.storage;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.*;
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

            // Créer les sous-dossiers
            Files.createDirectories(rootLocation.resolve("photos"));
            Files.createDirectories(rootLocation.resolve("audio"));

            System.out.println("✅ Dossier upload initialisé: " + rootLocation);
        } catch (IOException e) {
            throw new RuntimeException("Impossible de créer le dossier upload", e);
        }
    }

    /**
     * Sauvegarde un fichier et retourne le nom unique généré
     * @param file fichier reçu
     * @param subFolder "photos" ou "audio"
     * @return nom unique du fichier (ex: abc123.jpg)
     */
    public String storeFile(MultipartFile file, String subFolder) {
        if (file.isEmpty()) {
            throw new RuntimeException("Le fichier est vide");
        }

        try {
            // Nom original du fichier
            String originalFileName = file.getOriginalFilename();
            if (originalFileName == null) originalFileName = "file";

            // Extraire l'extension (.jpg, .mp3, etc.)
            String extension = "";
            int dotIndex = originalFileName.lastIndexOf('.');
            if (dotIndex > 0) {
                extension = originalFileName.substring(dotIndex);
            }

            // Générer un nom unique
            String uniqueFileName = UUID.randomUUID().toString() + extension;

            // Chemin de destination
            Path targetLocation = rootLocation.resolve(subFolder).resolve(uniqueFileName);

            // Sauvegarder
            Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);

            return uniqueFileName;

        } catch (IOException e) {
            throw new RuntimeException("Erreur lors du stockage du fichier", e);
        }
    }

    /**
     * Charger un fichier pour le téléchargement
     */
    public Resource loadFileAsResource(String fileName, String subFolder) {
        try {
            Path filePath = rootLocation.resolve(subFolder).resolve(fileName).normalize();
            Resource resource = new UrlResource(filePath.toUri());

            if (resource.exists() && resource.isReadable()) {
                return resource;
            } else {
                throw new RuntimeException("Fichier introuvable: " + fileName);
            }
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