package com.animaltracking.backend.service;

import com.animaltracking.backend.entity.RfidTag;
import java.util.List;

public interface RfidTagService {
    List<RfidTag> getAllTags();
    RfidTag getTagById(Integer id);
    RfidTag createTag(RfidTag tag);
    RfidTag updateTag(Integer id, RfidTag tagDetails);
    void deleteTag(Integer id);
}