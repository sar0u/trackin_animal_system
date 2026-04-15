package com.animaltracking.backend.service;

import com.animaltracking.backend.entity.Owner;
import java.util.List;

public interface OwnerService {
    List<Owner> getAllOwners();
    Owner getOwnerById(Integer id);
    Owner createOwner(Owner owner);
    Owner updateOwner(Integer id, Owner ownerDetails);
    void deleteOwner(Integer id);
}