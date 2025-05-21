-- Script de eliminación de tablas DP_ en SQLite

-- Producto 1: Ventas consolidadas por producto y mes
DROP TABLE IF EXISTS DP_SalesByProductMonth;

-- Producto 2: Ranking de clientes por facturación
DROP TABLE IF EXISTS DP_TopCustomersByRevenue;

-- Producto 3: Ventas por región y trimestre
DROP TABLE IF EXISTS DP_RegionalSalesByQuarter;

-- Producto 4: Desempeño de empleados por año
DROP TABLE IF EXISTS DP_EmployeePerformance;

-- Producto 5: Productos con devoluciones o cancelaciones
DROP TABLE IF EXISTS DP_ProductReturns;

-- Producto 6: Retrasos en entregas
DROP TABLE IF EXISTS DP_ShippingDelays;

-- Script de eliminación de tablas DQM_ en SQLite

-- Estadísticas de calidad por tabla y capa
DROP TABLE IF EXISTS DQM_TableStatistics;

-- Detalle de errores o advertencias por campo con granularidad extendida y UUID
DROP TABLE IF EXISTS DQM_FieldIssues;

-- Resultados de carga por archivo CSV
DROP TABLE IF EXISTS DQM_LoadResults;

-- Registro de validaciones cruzadas o de integridad referencial
DROP TABLE IF EXISTS DQM_IntegrityChecks;

-- Auditoría de ejecuciones de procesos
DROP TABLE IF EXISTS DQM_ProcessAudit;

-- Script para eliminación de tablas DWA_ en SQLite

-- Tabla de hechos Ventas 
DROP TABLE IF EXISTS DWA_SalesFact;

-- Tabla de hechos Entregas
DROP TABLE IF EXISTS DWA_DeliveriesFact;

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

-- Script para eliminación de tablas TMP_ en SQLite

DROP TABLE IF EXISTS TMP_EmployeeTerritories;

DROP TABLE IF EXISTS TMP_OrderDetails;

DROP TABLE IF EXISTS TMP_Orders;

DROP TABLE IF EXISTS TMP_Products;

DROP TABLE IF EXISTS TMP_Shippers;

DROP TABLE IF EXISTS TMP_Suppliers;

DROP TABLE IF EXISTS TMP_Territories;

DROP TABLE IF EXISTS TMP_WorldData2023;

DROP TABLE IF EXISTS TMP_Categories;

DROP TABLE IF EXISTS TMP_Regions;

DROP TABLE IF EXISTS TMP_Customers;

DROP TABLE IF EXISTS TMP_Employees;
