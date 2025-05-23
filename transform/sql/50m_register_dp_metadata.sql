-- Cancelas, Martín.
-- Nicolau, Jorge.A

-- ================================================================================
-- Script: register_metadata.sql
-- Descripción:
--   Este script actualiza la capa MET_ de metadata, registrando:
--     - Las tablas de todas las capas (TMP_, DWA_, DWM_, DQM_, DP_, MET_)
--     - Columnas clave y su rol (PK, FK, UUID)
--     - Ejecuciones de procesos automatizados
--     - Relación de linaje entre orígenes y destinos
--
-- Funcionalidad:
--   - Inserta descripciones básicas en `MET_Tables`
--   - Registra campos con trazabilidad y clasificación en `MET_Columns`
--   - Documenta la ejecución del pipeline en `MET_Executions`
--   - Traza el linaje entre capas basado en UUID y entidades
--
-- Requisitos:
--   - Las capas del DWA deben estar ya creadas y pobladas.
--   - Se recomienda ejecutar al final de cada pipeline.
--
-- Uso:
--   Integrar al final de una ejecución headless o manualmente.
-- ================================================================================

-- Registro de tablas claves.
INSERT INTO MET_Tables (tableName, layer, description, createdAt, createdBy, lastModified)
VALUES 
  ('TMP_Customers', 'TMP', 'Clientes originales desde CSV', datetime('now'), 'headless', datetime('now')),
  ('DWA_Customers', 'DWA', 'Clientes normalizados', datetime('now'), 'headless', datetime('now')),
  ('DWM_Customers', 'DWM', 'Clientes con versiones históricas', datetime('now'), 'headless', datetime('now')),
  ('DP_TopCustomersByRevenue', 'DP', 'Ranking de clientes por facturación', datetime('now'), 'headless', datetime('now')),
  ('DQM_TableStatistics', 'DQM', 'Indicadores generales de calidad de tabla', datetime('now'), 'headless', datetime('now'));

-- Registro de columnas con su rol.
INSERT INTO MET_Columns (tableName, columnName, dataType, isPrimaryKey, isForeignKey, isUUID, description)
VALUES 
  ('DWA_Customers', 'customerID', 'TEXT', 1, 0, 0, 'Identificador natural del cliente'),
  ('DWA_Customers', 'uuid', 'TEXT', 0, 0, 1, 'Identificador de trazabilidad universal'),
  ('DWM_Customers', 'validFrom', 'TEXT', 0, 0, 0, 'Inicio de vigencia del registro'),
  ('DP_TopCustomersByRevenue', 'totalRevenue', 'REAL', 0, 0, 0, 'Monto total de ventas por cliente');

-- Registrao de una ejecución del pipeline.
INSERT INTO MET_Executions (processName, executedBy, startTime, endTime, status, log)
VALUES 
  ('Full Pipeline Execution', 'headless', datetime('now', '-10 minutes'), datetime('now'), 'SUCCESS', 'Pipeline ejecutado en modo automático.');

-- Registrao del linaje de carga.
INSERT INTO MET_Lineage (sourceEntity, targetEntity, sourceUUID, targetUUID, transformationDescription, transformationScript, lineageType, createdAt)
SELECT 
  'TMP_Customers', 
  'DWA_Customers', 
  uuid, 
  uuid,
  'Carga directa desde TMP_Customers hacia DWA_Customers',
  NULL,
  'direct',
  datetime('now')
FROM DWA_Customers;
