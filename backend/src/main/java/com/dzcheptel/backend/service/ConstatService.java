package com.dzcheptel.backend.service;

import com.dzcheptel.backend.entity.Constat;
import com.dzcheptel.backend.entity.ConstatImage;
import com.dzcheptel.backend.entity.ConstatStatus;

import java.util.List;

public interface ConstatService {
    List<Constat> getAll();
    Constat getById(Long id);
    Constat create(Constat constat);
    Constat update(Long id, Constat payload);
    Constat updateStatus(Long id, ConstatStatus status);
    void delete(Long id);
    List<Constat> getBySession(Long sessionId);
    ConstatImage addImage(Long constatId, String imageUrl);
    void deleteImage(Long constatId, Long imageId);
    List<ConstatImage> getImages(Long constatId);
}
