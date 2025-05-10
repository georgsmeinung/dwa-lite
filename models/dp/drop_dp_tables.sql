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