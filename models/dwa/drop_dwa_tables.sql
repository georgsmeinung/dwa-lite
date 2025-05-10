-- Script para eliminación de tablas DWA_ en SQLite

-- Dimensión Clientes
DROP TABLE IF EXISTS DWA_Customers;

-- Dimensión Productos
DROP TABLE IF EXISTS DWA_Products;

-- Dimensión Proveedores
DROP TABLE IF EXISTS DWA_Suppliers;

-- Dimensión Empleados
DROP TABLE IF EXISTS DWA_Employees;

-- Dimensión Territorios
DROP TABLE IF EXISTS DWA_Territories;

-- Dimensión Regiones
DROP TABLE IF EXISTS DWA_Regions;

-- Dimensión Tiempo
DROP TABLE IF EXISTS DWA_Time;

-- Tabla de hechos Ventas 
DROP TABLE IF EXISTS DWA_SalesFact;

-- Tabla de hechos Entregas
DROP TABLE IF EXISTS DWA_DeliveriesFact;