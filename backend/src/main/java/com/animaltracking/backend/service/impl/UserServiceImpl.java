package com.animaltracking.backend.service.impl;

import com.animaltracking.backend.entity.User;
import com.animaltracking.backend.entity.UserRole;
import com.animaltracking.backend.repository.UserRepository;
import com.animaltracking.backend.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;

    @Override
    public User createUser(User user) {
        return userRepository.save(user);
    }

    @Override
    public User getUserById(Integer id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    @Override
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @Override
    public List<User> getUsersByRole(UserRole role) {
        return userRepository.findByUserRole(role);
    }

    @Override
    public User updateUser(Integer id, User updatedUser) {
        User existing = getUserById(id);
        existing.setFirstName(updatedUser.getFirstName());
        existing.setLastName(updatedUser.getLastName());
        existing.setEmailAddress(updatedUser.getEmailAddress());
        existing.setUserRole(updatedUser.getUserRole());
        return userRepository.save(existing);
    }

    @Override
    public void deactivateUser(Integer id) {
        User user = getUserById(id);
        userRepository.save(user);
    }

    @Override
    public void deleteUser(Integer id) {
        userRepository.deleteById(id);
    }

    @Override
    public User save(User user) {
        return userRepository.save(user);
    }

}