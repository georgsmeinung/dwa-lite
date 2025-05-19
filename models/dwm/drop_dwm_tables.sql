-- Script para eliminación de tablas DWM_ en SQLite

-- Clientes con historial y trazabilidad
DROP TABLE IF EXISTS DWM_Customers;

-- Empleados con historial y trazabilidad
DROP TABLE IF EXISTS DWM_Employees;

-- Productos con historial y trazabilidad
DROP TABLE IF EXISTS DWM_Products;

-- Categorías con historial y trazabilidad
DROP TABLE IF EXISTS DWM_WorldData2023;

-- Territorios con historial y trazabilidad
DROP TABLE IF EXISTS DWM_SalesFact;

-- Regiones con historial y trazabilidad
DROP TABLE IF EXISTS DWM_DeliveriesFact;