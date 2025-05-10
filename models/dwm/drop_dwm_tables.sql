-- Script para eliminación de tablas DWM_ en SQLite

-- Clientes con historial y trazabilidad
DROP TABLE IF EXISTS DWM_Customers;

-- Empleados con historial y trazabilidad
DROP TABLE IF EXISTS DWM_Employees;

-- Proveedores con historial y trazabilidad
DROP TABLE IF EXISTS DWM_Suppliers;

-- Productos con historial y trazabilidad
DROP TABLE IF EXISTS DWM_Products;

-- Categorías con historial y trazabilidad
DROP TABLE IF EXISTS DWM_Categories;

-- Territorios con historial y trazabilidad
DROP TABLE IF EXISTS DWM_Territories;

-- Regiones con historial y trazabilidad
DROP TABLE IF EXISTS DWM_Regions;