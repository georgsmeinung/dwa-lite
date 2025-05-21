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
INSERT INTO DP_SalesByProductMonth (uuid, productName, year, month, totalUnitsSold, totalRevenue)
SELECT
    p.uuid,
    p.productName,
    t.year,
    t.month,
    SUM(sf.quantity) AS totalUnitsSold,
    SUM(sf.totalAmount) AS totalRevenue
FROM DWA_SalesFact sf
JOIN DWA_Products p ON sf.productKey = p.productKey
JOIN DWA_Time t ON sf.orderDateKey = t.timeKey
GROUP BY p.uuid, p.productName, t.year, t.month;

-- 2. Ranking de clientes por facturación
INSERT INTO DP_TopCustomersByRevenue (uuid, customerID, companyName, country, totalRevenue, totalOrders, rank)
WITH CustomerSales AS (
    SELECT
        c.uuid,
        c.customerID,
        c.companyName,
        c.country,
        SUM(sf.totalAmount) AS totalRevenue,
        COUNT(sf.orderID) AS totalOrders
    FROM DWA_SalesFact sf
    JOIN DWA_Customers c ON sf.customerKey = c.customerKey
    GROUP BY c.uuid, c.customerID, c.companyName, c.country
)
SELECT
    uuid,
    customerID,
    companyName,
    country,
    totalRevenue,
    totalOrders,
    RANK() OVER (ORDER BY totalRevenue DESC) AS rank
FROM CustomerSales;


-- 4. Desempeño de empleados
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

-- 5. Análisis de devoluciones (basado en descuentos)
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

-- 6. Entregas demoradas
INSERT INTO DP_ShippingDelays (uuid, orderID, customerID, orderDate, requiredDate, shippedDate, deliveryDelayDays)
SELECT
    df.uuid,
    df.orderID,
    c.customerID,
    t_shipped.date AS shippedDate,
    t_required.date AS requiredDate,
    t_order.date AS orderDate,
    df.deliveryDelayDays
FROM DWA_DeliveriesFact df
JOIN DWA_Customers c ON df.customerKey = c.customerKey
LEFT JOIN DWA_Time t_shipped ON df.shippedDateKey = t_shipped.timeKey
LEFT JOIN DWA_Time t_required ON df.requiredDateKey = t_required.timeKey
LEFT JOIN DWA_Time t_order ON df.shippedDateKey = t_order.timeKey
WHERE df.isDelivered = 1;
