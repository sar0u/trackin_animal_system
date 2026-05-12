package com.dzcheptel.backend.service;

import com.dzcheptel.backend.entity.User;
import com.dzcheptel.backend.repository.UserRepository;
import com.dzcheptel.backend.service.impl.UserDetailsImpl;
import org.springframework.security.authentication.DisabledException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;


@Service
public class CustomUserDetailsService implements UserDetailsService { // C'est ce "implements" qui manquait !

    @Autowired
    private UserRepository userRepository;

    @Override
    @Transactional
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsername(username)
                .or(() -> userRepository.findByEmail(username))
                .orElseThrow(() -> new UsernameNotFoundException("Utilisateur ou email non trouvé : " + username));

        if (Boolean.FALSE.equals(user.getIsActive())) {
            throw new DisabledException("Compte utilisateur désactivé");
        }

        return UserDetailsImpl.build(user);
    }
}