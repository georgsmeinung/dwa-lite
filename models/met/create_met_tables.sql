-- Script de creación de la capa MET_ en SQLite con soporte para trazabilidad basada en UUID

-- Registro de tablas en el DWA
CREATE TABLE MET_Tables (
    tableID INTEGER PRIMARY KEY AUTOINCREMENT,
    tableName TEXT,
    layer TEXT, -- TMP, DWA, DWM, DQM, DP
    description TEXT,
    createdAt TEXT,
    createdBy TEXT,
    lastModified TEXT
);

-- Registro de columnas de cada tabla
CREATE TABLE MET_Columns (
    columnID INTEGER PRIMARY KEY AUTOINCREMENT,
    tableName TEXT,
    columnName TEXT,
    dataType TEXT,
    isPrimaryKey BOOLEAN,
    isForeignKey BOOLEAN,
    isUUID BOOLEAN DEFAULT 0,
    description TEXT
);

-- Linaje de datos entre entidades
CREATE TABLE MET_Lineage (
    lineageID INTEGER PRIMARY KEY AUTOINCREMENT,
    sourceEntity TEXT, -- puede ser un .CSV, tabla TMP_ o UUID
    targetEntity TEXT, -- tabla DWA_, DWM_, DP_ o UUID
    sourceUUID TEXT, -- opcional: trazabilidad fila a fila
    targetUUID TEXT, -- opcional: trazabilidad fila a fila
    transformationDescription TEXT,
    transformationScript TEXT,
    lineageType TEXT, -- direct, derived, aggregated
    createdAt TEXT
);

-- Registro de ejecuciones de procesos de carga o transformación
CREATE TABLE MET_Executions (
    executionID INTEGER PRIMARY KEY AUTOINCREMENT,
    processName TEXT,
    executedBy TEXT,
    startTime TEXT,
    endTime TEXT,
    status TEXT, -- SUCCESS, FAILURE
    log TEXT
);

-- Versionado de tablas con hash y trazabilidad
CREATE TABLE MET_TableVersions (
    versionID INTEGER PRIMARY KEY AUTOINCREMENT,
    tableName TEXT,
    versionTag TEXT,
    versionDate TEXT,
    sourceFiles TEXT,
    hash TEXT, -- para detectar cambios estructurales o lógicos
    notes TEXT
);

-- Descripción de productos de datos
CREATE TABLE MET_DataProducts (
    dpID INTEGER PRIMARY KEY AUTOINCREMENT,
    dpTable TEXT,
    businessUseCase TEXT,
    targetAudience TEXT,
    relatedDashboards TEXT,
    createdAt TEXT,
    owner TEXT
);
