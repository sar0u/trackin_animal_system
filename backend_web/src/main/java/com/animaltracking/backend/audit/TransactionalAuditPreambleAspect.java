package com.animaltracking.backend.audit;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.annotation.Order;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

// Définit les variables user_id et IP dans chaque transaction MySQL
// Les triggers de la DB vont lire ces variables pour logger automatiquement
// On utilise AOP au lieu d'un Filter car la vraie connexion s'ouvre dans la transaction
@Aspect
@Component
@Order(0)
public class TransactionalAuditPreambleAspect {

    private final JdbcTemplate jdbc;
    private final boolean enabled;

    public TransactionalAuditPreambleAspect(
            JdbcTemplate jdbc,
            @Value("${audit.use-db-triggers:false}") boolean enabled) {
        this.jdbc = jdbc;
        this.enabled = enabled;
    }

    @Around("@annotation(org.springframework.transaction.annotation.Transactional) "
          + "|| @within(org.springframework.transaction.annotation.Transactional)")
    public Object setAuditVars(ProceedingJoinPoint pjp) throws Throwable {
        if (enabled) {
            Long userId = AuditRequestContext.getUserId();
            String ip = AuditRequestContext.getIpAddress();
            if (ip == null || ip.isBlank()) ip = "SYSTEM";
            jdbc.update("SET @audit_user_id := ?, @audit_ip := ?", userId, ip);
        }
        return pjp.proceed();
    }
}
