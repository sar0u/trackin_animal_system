package com.animaltracking.backend.service;

import com.animaltracking.backend.entity.RfidTag;
import java.util.List;

public interface RfidTagService {
    List<RfidTag> getAllTags();
    RfidTag getTagById(Long id);
    RfidTag createTag(RfidTag tag);
    RfidTag updateTag(Long id, RfidTag tagDetails);
    void deleteTag(Long id);
}