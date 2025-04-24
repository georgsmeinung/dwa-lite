-- Script de creación de tablas DQM_ en SQLite con trazabilidad UUID

-- Estadísticas de calidad por tabla y capa
CREATE TABLE DQM_TableStatistics (
    dqmID INTEGER PRIMARY KEY AUTOINCREMENT,
    tableName TEXT,
    dataLayer TEXT, -- TMP, DWA, DWM
    rowCount INTEGER,
    nullCount INTEGER,
    duplicateCount INTEGER,
    outlierCount INTEGER,
    createdAt TEXT
);

-- Detalle de errores o advertencias por campo con granularidad extendida y UUID
CREATE TABLE DQM_FieldIssues (
    issueID INTEGER PRIMARY KEY AUTOINCREMENT,
    tableName TEXT,
    dataLayer TEXT, -- TMP, DWA, DWM
    fieldName TEXT,
    issueType TEXT, -- NULL_VALUE, OUTLIER, FORMAT_ERROR, DOMAIN_VIOLATION
    issueSample TEXT, -- valor de ejemplo con error
    uuid TEXT, -- trazabilidad fila a fila
    issueCount INTEGER,
    issueThreshold REAL, -- umbral esperado
    severity TEXT, -- LOW, MEDIUM, HIGH
    createdAt TEXT
);

-- Resultados de carga por archivo CSV
CREATE TABLE DQM_LoadResults (
    loadID INTEGER PRIMARY KEY AUTOINCREMENT,
    sourceFile TEXT,
    tableTarget TEXT,
    rowCountSource INTEGER,
    rowCountLoaded INTEGER,
    rejectedRows INTEGER,
    loadStatus TEXT, -- SUCCESS, PARTIAL, FAILURE
    loadMessage TEXT,
    createdAt TEXT
);

-- Registro de validaciones cruzadas o de integridad referencial
CREATE TABLE DQM_IntegrityChecks (
    checkID INTEGER PRIMARY KEY AUTOINCREMENT,
    checkName TEXT,
    sourceTable TEXT,
    referenceTable TEXT,
    passed INTEGER, -- 1 = TRUE, 0 = FALSE
    issueCount INTEGER,
    createdAt TEXT
);

-- Auditoría de ejecuciones de procesos
CREATE TABLE DQM_ProcessAudit (
    auditID INTEGER PRIMARY KEY AUTOINCREMENT,
    processName TEXT,
    startTime TEXT,
    endTime TEXT,
    status TEXT, -- SUCCESS, FAILURE
    message TEXT
);