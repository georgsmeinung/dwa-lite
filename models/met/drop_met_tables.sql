-- Script para eliminación de tablas MET_ en SQLite

-- Registro de tablas en el DWA
DROP TABLE IF EXISTS MET_Tables;

-- Registro de columnas de cada tabla
DROP TABLE IF EXISTS MET_Columns;

-- Linaje de datos entre entidades
DROP TABLE IF EXISTS MET_Lineage;

-- Registro de ejecuciones de procesos de carga o transformación
DROP TABLE IF EXISTS MET_Executions;

-- Versionado de tablas con hash y trazabilidad
DROP TABLE IF EXISTS MET_TableVersions;

-- Descripción de productos de datos
DROP TABLE IF EXISTS MET_DataProducts;