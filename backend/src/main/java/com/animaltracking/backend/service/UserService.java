package com.animaltracking.backend.service;

import com.animaltracking.backend.entity.User;
import com.animaltracking.backend.entity.UserRole;

import java.util.List;

public interface UserService {

    User createUser(User user);

    User save(User user);

    User getUserById(Integer id);

    List<User> getAllUsers();

    List<User> getUsersByRole(UserRole role);

    User updateUser(Integer id, User updatedUser);

    void deactivateUser(Integer id);

    void deleteUser(Integer id);
}