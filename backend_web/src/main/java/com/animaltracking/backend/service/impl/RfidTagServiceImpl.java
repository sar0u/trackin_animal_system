package com.animaltracking.backend.service.impl;

import com.animaltracking.backend.entity.RfidTag;
import com.animaltracking.backend.repository.RfidTagRepository;
import com.animaltracking.backend.service.RfidTagService;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@Transactional
public class RfidTagServiceImpl implements RfidTagService {

    @Autowired
    private RfidTagRepository rfidTagRepository;

    @Override
    public List<RfidTag> getAllTags() {
        return rfidTagRepository.findAll();
    }

    @Override
    public RfidTag getTagById(Long id) {
        return rfidTagRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Tag RFID non trouvé (ID: " + id + ")"));
    }

    @Override
    public RfidTag createTag(RfidTag tag) {
        return rfidTagRepository.save(tag);
    }

    @Override
    public RfidTag updateTag(Long id, RfidTag tagDetails) {
        RfidTag tag = getTagById(id);
        tag.setRfidCode(tagDetails.getRfidCode());
        tag.setTagType(tagDetails.getTagType());
        tag.setTagStatus(tagDetails.getTagStatus());
        return rfidTagRepository.save(tag);
    }

    @Override
    public void deleteTag(Long id) {
        RfidTag tag = getTagById(id);
        rfidTagRepository.delete(tag);
    }
}