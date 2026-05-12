package com.dzcheptel.backend.entity;

public enum HealthStatus {
    Healthy,
    UnderTreatment,
    Critical,
    Quarantined;

    public static final HealthStatus HEALTHY = Healthy;
    public static final HealthStatus UNDER_TREATMENT = UnderTreatment;
    public static final HealthStatus CRITICAL = Critical;
    public static final HealthStatus QUARANTINED = Quarantined;
}
