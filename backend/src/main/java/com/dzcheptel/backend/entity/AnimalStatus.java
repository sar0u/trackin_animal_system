package com.dzcheptel.backend.entity;

public enum AnimalStatus {
    Active,
    Sold,
    Lost,
    Dead,
    Slaughtered;

    public static final AnimalStatus ACTIVE = Active;
    public static final AnimalStatus SOLD = Sold;
    public static final AnimalStatus LOST = Lost;
    public static final AnimalStatus DEAD = Dead;
    public static final AnimalStatus SLAUGHTERED = Slaughtered;

    public static AnimalStatus fromInput(String value) {
        if (value == null) {
            return null;
        }
        return switch (value.trim().toUpperCase()) {
            case "ACTIVE" -> Active;
            case "SOLD" -> Sold;
            case "LOST" -> Lost;
            case "DEAD" -> Dead;
            case "SLAUGHTERED" -> Slaughtered;
            default -> AnimalStatus.valueOf(value.trim());
        };
    }
}
