package com.animaltracking.backend.service;

import com.animaltracking.backend.entity.User;
import com.animaltracking.backend.entity.UserRole;

import java.util.List;

public interface UserService {

    User createUser(User user);

    User save(User user);

    User getUserById(Long id);

    List<User> getAllUsers();

    List<User> getUsersByRole(UserRole role);

    User updateUser(Long id, User updatedUser);

    void deactivateUser(Long id);

    void deleteUser(Long id);
}