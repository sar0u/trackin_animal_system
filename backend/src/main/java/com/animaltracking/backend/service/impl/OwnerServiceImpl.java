package com.animaltracking.backend.service.impl;

import com.animaltracking.backend.entity.Owner;
import com.animaltracking.backend.repository.OwnerRepository;
import com.animaltracking.backend.service.OwnerService;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@Transactional
public class OwnerServiceImpl implements OwnerService {

    @Autowired
    private OwnerRepository ownerRepository;

    @Override
    public List<Owner> getAllOwners() {
        return ownerRepository.findAll();
    }

    @Override
    public Owner getOwnerById(Integer id) {
        return ownerRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Propriétaire non trouvé (ID: " + id + ")"));
    }

    @Override
    public Owner createOwner(Owner owner) {
        return ownerRepository.save(owner);
    }

    @Override
    public Owner updateOwner(Integer id, Owner ownerDetails) {
        Owner owner = getOwnerById(id);
        owner.setFullOwnerName(ownerDetails.getFullOwnerName());
        owner.setContactPhoneNumber(ownerDetails.getContactPhoneNumber());

        if (ownerDetails.getUser() != null) {
            owner.setUser(ownerDetails.getUser());
        }

        return ownerRepository.save(owner);
    }

    @Override
    public void deleteOwner(Integer id) {
        Owner owner = getOwnerById(id);
        ownerRepository.delete(owner);
    }
}