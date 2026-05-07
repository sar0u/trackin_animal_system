package com.animaltracking.backend.service.impl;

import com.animaltracking.backend.entity.Constat;
import com.animaltracking.backend.entity.ConstatImage;
import com.animaltracking.backend.entity.ConstatStatus;
import com.animaltracking.backend.repository.ConstatImageRepository;
import com.animaltracking.backend.repository.ConstatRepository;
import com.animaltracking.backend.service.ConstatService;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class ConstatServiceImpl implements ConstatService {

    private final ConstatRepository repo;
    private final ConstatImageRepository imageRepo;

    @Override
    @Transactional(readOnly = true)
    public List<Constat> getAll() {
        return repo.findAllFetched();
    }

    @Override
    @Transactional(readOnly = true)
    public Constat getById(Long id) {
        return repo.findFetchedById(id)
                .orElseThrow(() -> new EntityNotFoundException("Constat introuvable : " + id));
    }

    @Override
    public Constat create(Constat constat) {
        return repo.save(constat);
    }

    @Override
    public Constat update(Long id, Constat payload) {
        Constat existing = getById(id);
        existing.setType(payload.getType());
        existing.setDescription(payload.getDescription());
        existing.setStatus(payload.getStatus());
        if (payload.getStatus() == ConstatStatus.RESOLVED && existing.getResolvedAt() == null) {
            existing.setResolvedAt(LocalDateTime.now());
        }
        return repo.save(existing);
    }

    @Override
    public Constat updateStatus(Long id, ConstatStatus status) {
        Constat existing = getById(id);
        existing.setStatus(status);
        if (status == ConstatStatus.RESOLVED && existing.getResolvedAt() == null) {
            existing.setResolvedAt(LocalDateTime.now());
        }
        return repo.save(existing);
    }

    @Override
    public void delete(Long id) {
        repo.deleteById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Constat> getBySession(Long sessionId) {
        return repo.findByControlSessionId(sessionId);
    }

    @Override
    public ConstatImage addImage(Long constatId, String imageUrl) {
        Constat constat = repo.findById(constatId)
                .orElseThrow(() -> new EntityNotFoundException("Constat introuvable : " + constatId));
        ConstatImage image = new ConstatImage();
        image.setConstat(constat);
        image.setImageUrl(imageUrl);
        return imageRepo.save(image);
    }

    @Override
    public void deleteImage(Long constatId, Long imageId) {
        ConstatImage image = imageRepo.findById(imageId)
                .orElseThrow(() -> new EntityNotFoundException("Image introuvable : " + imageId));
        if (!image.getConstat().getId().equals(constatId)) {
            throw new IllegalArgumentException("L'image n'appartient pas au constat " + constatId);
        }
        imageRepo.delete(image);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ConstatImage> getImages(Long constatId) {
        return imageRepo.findByConstatId(constatId);
    }
}
