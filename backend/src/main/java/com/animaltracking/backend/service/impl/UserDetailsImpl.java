package com.animaltracking.backend.security; // Ajuste le package selon ton dossier

import com.animaltracking.backend.entity.User;
import com.fasterxml.jackson.annotation.JsonIgnore;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;

public class UserDetailsImpl implements UserDetails {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String username;
    private String email;
    private String firstName;
    private String lastName;

    @JsonIgnore
    private String password;

    private Collection<? extends GrantedAuthority> authorities;

    public UserDetailsImpl(Long id, String username, String email, String password,
                           String firstName, String lastName,
                           Collection<? extends GrantedAuthority> authorities) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.password = password;
        this.firstName = firstName;
        this.lastName = lastName;
        this.authorities = authorities;
    }

    // 🟢 C'est cette méthode qui transforme ton "User" MySQL en "UserDetails" Spring
    public static UserDetailsImpl build(User user) {
        // On transforme ton Rôle en "Autorité" comprise par Spring Security (ex: ROLE_Administrator)
        GrantedAuthority authority = new SimpleGrantedAuthority("ROLE_" + user.getUserRole().name());

        return new UserDetailsImpl(
                Long.valueOf(user.getId()),
                user.getUsername(),
                user.getEmailAddress(),
                user.getEncryptedPassword(),
                user.getFirstName(),
                user.getLastName(),
                Collections.singletonList(authority)
        );
    }

    // Getters personnalisés pour que tu puisses récupérer ces infos plus tard
    public Long getId() { return id; }
    public String getEmail() { return email; }
    public String getFirstName() { return firstName; }
    public String getLastName() { return lastName; }

    // --- Méthodes obligatoires de l'interface UserDetails ---
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() { return authorities; }

    @Override
    public String getPassword() { return password; }

    @Override
    public String getUsername() { return username; }

    @Override
    public boolean isAccountNonExpired() { return true; }

    @Override
    public boolean isAccountNonLocked() { return true; }

    @Override
    public boolean isCredentialsNonExpired() { return true; }

    @Override
    public boolean isEnabled() { return true; }
}