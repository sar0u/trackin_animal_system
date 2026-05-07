package com.animaltracking.backend.audit;

// Stocke l'ID utilisateur et l'IP pour la requête courante
// Utilisé avec ThreadLocal pour éviter les fuites entre requêtes
public final class AuditRequestContext {

    private static final ThreadLocal<Long> userId = new ThreadLocal<>();
    private static final ThreadLocal<String> ipAddress = new ThreadLocal<>();

    private AuditRequestContext() {}

    public static void setUserId(Long id) { userId.set(id); }
    public static Long getUserId() { return userId.get(); }

    public static void setIpAddress(String ip) { ipAddress.set(ip); }
    public static String getIpAddress() { return ipAddress.get(); }

    public static void clear() {
        userId.remove();
        ipAddress.remove();
    }
}
