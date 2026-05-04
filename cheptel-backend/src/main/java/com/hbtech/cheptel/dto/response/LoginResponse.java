package com.hbtech.cheptel.dto.response;

public class LoginResponse {

    private String token;
    private String role;
    private String username;
    private Long farmId;
    private String farmName;
    private String message;

    public LoginResponse() {
    }

    public LoginResponse(
            String token,
            String role,
            String username,
            Long farmId,
            String farmName,
            String message
    ) {
        this.token = token;
        this.role = role;
        this.username = username;
        this.farmId = farmId;
        this.farmName = farmName;
        this.message = message;
    }

    public static LoginResponse success(
            String token,
            String role,
            String username,
            Long farmId,
            String farmName
    ) {
        return new LoginResponse(
                token,
                role,
                username,
                farmId,
                farmName,
                "Connexion réussie"
        );
    }

    public static LoginResponse error(String message) {
        return new LoginResponse(
                null,
                null,
                null,
                null,
                null,
                message
        );
    }

    public String getToken() {
        return token;
    }

    public String getRole() {
        return role;
    }

    public String getUsername() {
        return username;
    }

    public Long getFarmId() {
        return farmId;
    }

    public String getFarmName() {
        return farmName;
    }

    public String getMessage() {
        return message;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public void setFarmId(Long farmId) {
        this.farmId = farmId;
    }

    public void setFarmName(String farmName) {
        this.farmName = farmName;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}