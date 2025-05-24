-- Cancelas, Martín.
-- Nicolau, Jorge.

-- ================================================================================
-- Script: generate_data_products.sql
-- Descripción:
--   Genera los productos de datos (DP_) a partir de las tablas DWA_ y DWM_.
--   Pensado para consumo analítico en dashboards Power BI / Metabase.
--
-- Funcionalidad:
--   - Ventas por producto y mes
--   - Ranking de clientes por facturación
--   - Ventas por región y trimestre
--   - Desempeño de empleados
--   - Análisis de devoluciones
--   - Entregas demoradas
--
-- Requisitos:
--   - Tablas DWA_ y DWM_ creadas y pobladas
--   - Fechas correctamente asociadas vía DWA_Time
--
-- Recomendación:
--   Ejecutar después de validar calidad y cargar DWM_
-- ================================================================================

-- 1. Ventas por producto y mes
INSERT INTO DP_SalesByProductMonth (uuid, productName, category, countryOrigin, countryDestiny, year, month, totalUnitsSold, totalRevenue)
SELECT
    p.uuid,
    p.productName,
    p.categoryName,
    p.countryOrigin,
    c.country,
    t.year,
    t.month,
    SUM(sf.quantity) AS totalUnitsSold,
    SUM(sf.totalAmount) AS totalRevenue
FROM DWA_SalesFact sf
JOIN DWA_Products p ON sf.productKey = p.productKey
JOIN DWA_Time t ON sf.orderDateKey = t.timeKey
JOIN DWA_Customers c ON sf.customerKey = c.customerKey
GROUP BY p.uuid, p.productName, t.year, t.month;

-- 2. Ranking de clientes por facturación
INSERT INTO DP_TopCustomersByRevenue (uuid, customerID, companyName, country, countryGasolinePrice, countryGDP, countryPopulation, year, totalRevenue, totalOrders, rank)
WITH CustomerSales AS (
    SELECT
        c.uuid,
        c.customerID,
        c.companyName,
        c.country,
        w.Gasoline_Price AS countryGasolinePrice,
        w.GDP AS countryGDP,
        w.Population AS countryPopulation,
        t.year,
        SUM(sf.totalAmount) AS totalRevenue,
        COUNT(sf.orderID) AS totalOrders
    FROM DWA_SalesFact sf
    JOIN DWA_Customers c ON sf.customerKey = c.customerKey
    JOIN DWA_Time t ON sf.orderDateKey = t.timeKey
    LEFT JOIN DWA_WorldData2023 w ON c.country = w.Country
    GROUP BY c.uuid, c.customerID, c.companyName, c.country
)
SELECT
    uuid,
    customerID,
    companyName,
    country,
    countryGasolinePrice,
    countryGDP,
    countryPopulation,
    year,
    totalRevenue,
    totalOrders,
    RANK() OVER (ORDER BY totalRevenue DESC) AS rank
FROM CustomerSales;


-- 3. Desempeño de empleados
INSERT INTO DP_EmployeePerformance (uuid, employeeID, fullName, year, totalOrders, totalRevenue)
SELECT
    e.uuid,
    e.employeeID,
    e.fullName,
    t.year,
    COUNT(sf.orderID) AS totalOrders,
    SUM(sf.totalAmount) AS totalRevenue
FROM DWA_SalesFact sf
JOIN DWA_Employees e ON sf.employeeKey = e.employeeKey
JOIN DWA_Time t ON sf.orderDateKey = t.timeKey
GROUP BY e.uuid, e.employeeID, e.fullName, t.year;

-- 4. Análisis de devoluciones (basado en descuentos)
INSERT INTO DP_ProductReturns (uuid, productID, productName, returnReason, supplier, countryOrigin, categoryName, year, returnCount, totalLostRevenue)
SELECT
    p.uuid,
    p.productID,
    p.productName,
    'Discount applied (possible return)' AS returnReason,
    p.supplier,
    p.countryOrigin,
    p.categoryName,
    t.year,
    COUNT(sf.orderID) AS returnCount,
    SUM(sf.totalAmount * sf.discount) AS totalLostRevenue
FROM DWA_SalesFact sf
JOIN DWA_Products p ON sf.productKey = p.productKey
JOIN DWA_Time t ON sf.orderDateKey = t.timeKey
WHERE sf.discount > 0
GROUP BY p.uuid, p.productID, p.productName;
