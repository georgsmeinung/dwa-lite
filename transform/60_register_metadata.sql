-- =============================================================================
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
--   - Traza el linaje entre capas, basado en tablas y procesos ejecutados
--
-- Requisitos:
--   - Las capas del DWA deben estar ya creadas y pobladas.
--   - Se recomienda ejecutar al final de cada pipeline para dejar constancia.
--
-- Uso:
--   Este script puede integrarse al final de una ejecución headless o
--   invocarse manualmente para documentar una nueva versión.
-- =============================================================================

-- Registra algunas tablas claves
INSERT INTO MET_Tables (tableName, dataLayer, description)
VALUES 
  ('TMP_Customers', 'TMP', 'Clientes originales desde CSV'),
  ('DWA_Customers', 'DWA', 'Clientes normalizados'),
  ('DWM_Customers', 'DWM', 'Clientes con versiones históricas'),
  ('DP_TopCustomersByRevenue', 'DP', 'Ranking de clientes por facturación'),
  ('DQM_TableStatistics', 'DQM', 'Indicadores generales de calidad de tabla');

-- Registrar algunas columnas con rol
INSERT INTO MET_Columns (tableName, columnName, columnRole, description, isUUID)
VALUES 
  ('DWA_Customers', 'customerID', 'PK', 'Identificador natural del cliente', 0),
  ('DWA_Customers', 'uuid', 'Trace', 'Identificador de trazabilidad universal', 1),
  ('DWM_Customers', 'validFrom', 'Technical', 'Inicio de vigencia del registro', 0),
  ('DP_TopCustomersByRevenue', 'totalRevenue', 'Metric', 'Monto total de ventas por cliente', 0);

-- Registrar una ejecución de pipeline
INSERT INTO MET_Executions (executionID, startTime, endTime, executedBy, description)
VALUES 
  ('exec_' || strftime('%Y%m%d%H%M%S', 'now'), datetime('now', '-10 minutes'), datetime('now'), 'headless', 'Ejecución completa del pipeline');

-- Registrar linaje de ejemplo
INSERT INTO MET_Lineage (sourceType, sourceName, targetType, targetName, recordCount, loadDateTime, sourceUUID, targetUUID)
SELECT 
  'TABLE', 'TMP_Customers', 'TABLE', 'DWA_Customers', COUNT(*), datetime('now'), uuid, uuid
FROM DWA_Customers;
