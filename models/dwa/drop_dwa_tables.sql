-- Script para eliminación de tablas DWA_ en SQLite

-- Dimensión Clientes
DROP TABLE IF EXISTS DWA_Customers;

-- Dimensión Productos
DROP TABLE IF EXISTS DWA_Products;

-- Dimensión Empleados
DROP TABLE IF EXISTS DWA_Employees;

-- Dimensión Tiempo
DROP TABLE IF EXISTS DWA_Time;

-- Dimensión WorldData
DROP TABLE IF EXISTS DWA_WorldData2023;

-- Tabla de hechos Ventas 
DROP TABLE IF EXISTS DWA_SalesFact;

-- Tabla de hechos Entregas
DROP TABLE IF EXISTS DWA_DeliveriesFact;