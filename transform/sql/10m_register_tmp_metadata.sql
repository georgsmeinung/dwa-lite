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

-- Borra la metadata exisente
DELETE FROM MET_Tables WHERE layer = 'TMP';

-- Registra metadta para tablas claves
INSERT INTO MET_Tables (tableName, layer, description, createdAt, createdBy, lastModified)
VALUES ('TMP_Categories', 'TMP', 'Datos originales de Categories', datetime('now'), 'headless', datetime('now'));
INSERT INTO MET_Tables (tableName, layer, description, createdAt, createdBy, lastModified)
VALUES ('TMP_Customers', 'TMP', 'Datos originales de Customers', datetime('now'), 'headless', datetime('now'));
INSERT INTO MET_Tables (tableName, layer, description, createdAt, createdBy, lastModified)
VALUES ('TMP_EmployeeTerritories', 'TMP', 'Datos originales de Employeeterritories', datetime('now'), 'headless', datetime('now'));
INSERT INTO MET_Tables (tableName, layer, description, createdAt, createdBy, lastModified)
VALUES ('TMP_Employees', 'TMP', 'Datos originales de Employees', datetime('now'), 'headless', datetime('now'));
INSERT INTO MET_Tables (tableName, layer, description, createdAt, createdBy, lastModified)
VALUES ('TMP_OrderDetails', 'TMP', 'Datos originales de Orderdetails', datetime('now'), 'headless', datetime('now'));
INSERT INTO MET_Tables (tableName, layer, description, createdAt, createdBy, lastModified)
VALUES ('TMP_Orders', 'TMP', 'Datos originales de Orders', datetime('now'), 'headless', datetime('now'));
INSERT INTO MET_Tables (tableName, layer, description, createdAt, createdBy, lastModified)
VALUES ('TMP_Products', 'TMP', 'Datos originales de Products', datetime('now'), 'headless', datetime('now'));
INSERT INTO MET_Tables (tableName, layer, description, createdAt, createdBy, lastModified)
VALUES ('TMP_Regions', 'TMP', 'Datos originales de Regions', datetime('now'), 'headless', datetime('now'));
INSERT INTO MET_Tables (tableName, layer, description, createdAt, createdBy, lastModified)
VALUES ('TMP_Shippers', 'TMP', 'Datos originales de Shippers', datetime('now'), 'headless', datetime('now'));
INSERT INTO MET_Tables (tableName, layer, description, createdAt, createdBy, lastModified)
VALUES ('TMP_Suppliers', 'TMP', 'Datos originales de Suppliers', datetime('now'), 'headless', datetime('now'));
INSERT INTO MET_Tables (tableName, layer, description, createdAt, createdBy, lastModified)
VALUES ('TMP_Territories', 'TMP', 'Datos originales de Territories', datetime('now'), 'headless', datetime('now'));
INSERT INTO MET_Tables (tableName, layer, description, createdAt, createdBy, lastModified)
VALUES ('TMP_WorldData2023', 'TMP', 'Datos originales de Worlddata2023', datetime('now'), 'headless', datetime('now'));

-- Registrar columnas con su rol
INSERT INTO MET_Columns (tableName, columnName, dataType, isPrimaryKey, isForeignKey, isUUID, description)
VALUES 
  ('DWA_Customers', 'customerID', 'TEXT', 1, 0, 0, 'Identificador natural del cliente'),
  ('DWA_Customers', 'uuid', 'TEXT', 0, 0, 1, 'Identificador de trazabilidad universal'),
  ('DWM_Customers', 'validFrom', 'TEXT', 0, 0, 0, 'Inicio de vigencia del registro'),
  ('DP_TopCustomersByRevenue', 'totalRevenue', 'REAL', 0, 0, 0, 'Monto total de ventas por cliente');

-- Registrar una ejecución del pipeline
INSERT INTO MET_Executions (processName, executedBy, startTime, endTime, status, log)
VALUES 
  ('Full Pipeline Execution', 'headless', datetime('now', '-10 minutes'), datetime('now'), 'SUCCESS', 'Pipeline ejecutado en modo automático.');

-- Registrar linaje de carga
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
