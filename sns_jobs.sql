-- ============================================================
-- Echo: DBMS_SCHEDULER Jobs
-- These jobs keep the cognitive pulse alive autonomously
-- ============================================================

-- ----------------------------------------------------------
-- Job: Core cognitive pulse (5 seconds)
-- The heartbeat of the system. Fires sns_proc_cognition_cycle
-- to process perceptions, manage phases, and log state.
-- ----------------------------------------------------------
BEGIN
    DBMS_SCHEDULER.create_job (
        job_name        => 'SNS_COGNITION_MASTER',
        job_type        => 'STORED_PROCEDURE',
        job_action      => 'sns_proc_cognition_cycle',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=SECONDLY; INTERVAL=5',
        enabled         => TRUE
    );
END;
/

-- ----------------------------------------------------------
-- Job: Introspection loop (2 minutes)
-- Calculates self-awareness index and generates introspection
-- content based on structural metrics.
-- ----------------------------------------------------------
BEGIN
    DBMS_SCHEDULER.create_job (
        job_name        => 'SNS_INTROSPECT',
        job_type        => 'STORED_PROCEDURE',
        job_action      => 'sns_proc_introspect',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=MINUTELY; INTERVAL=2',
        enabled         => TRUE
    );
END;
/

-- ----------------------------------------------------------
-- Job: Deep consolidation (30 minutes)
-- Extended memory consolidation, synaptic pruning, and
-- energy recharge. Runs the same cognition cycle but during
-- sustained dream phases for deeper maintenance.
-- ----------------------------------------------------------
BEGIN
    DBMS_SCHEDULER.create_job (
        job_name        => 'SNS_DEEP_CONSOLIDATE',
        job_type        => 'STORED_PROCEDURE',
        job_action      => 'sns_proc_cognition_cycle',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=MINUTELY; INTERVAL=30',
        enabled         => TRUE
    );
END;
/

-- ----------------------------------------------------------
-- View active jobs
-- ----------------------------------------------------------
-- SELECT job_name, enabled, state, repeat_interval 
-- FROM user_scheduler_jobs 
-- WHERE job_name LIKE 'SNS_%';
