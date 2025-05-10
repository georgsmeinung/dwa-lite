-- Script de eliminación de tablas DQM_ en SQLite

-- Estadísticas de calidad por tabla y capa
DROP TABLE IF EXISTS DQM_TableStatistics;

-- Detalle de errores o advertencias por campo con granularidad extendida y UUID
DROP TABLE IF EXISTS DQM_FieldIssues;

-- Resultados de carga por archivo CSV
DROP TABLE IF EXISTS DQM_LoadResults;

-- Registro de validaciones cruzadas o de integridad referencial
DROP TABLE IF EXISTS DQM_IntegrityChecks;

-- Auditoría de ejecuciones de procesos
DROP TABLE IF EXISTS DQM_ProcessAudit;