package com.geosaas.audit;

import com.geosaas.modules.system.entity.SystemAuditLog;
import com.geosaas.modules.system.mapper.SystemAuditLogMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuditLogService {

    private final SystemAuditLogMapper auditLogMapper;

    @Async
    public void saveAuditLog(SystemAuditLog auditLog) {
        try {
            auditLogMapper.insert(auditLog);
        } catch (Exception e) {
            log.error("保存审计日志失败", e);
        }
    }
}