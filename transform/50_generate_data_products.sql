-- =============================================================================
-- Script: generate_data_products.sql
-- Descripción:
--   Este script genera y carga los productos de datos (DP_) a partir de las
--   tablas de hechos y dimensiones del DWA o DWM. Estos productos están
--   diseñados para ser consumidos por dashboards de negocio en Power BI
--   u otras herramientas analíticas.
--
-- Funcionalidad:
--   - Crea e inserta datos en 6 productos de datos:
--     1. Ventas por producto y mes
--     2. Ranking de clientes por facturación
--     3. Ventas por región y trimestre
--     4. Desempeño de empleados
--     5. Análisis de devoluciones
--     6. Entregas demoradas
--
-- Requisitos:
--   - Las tablas DWA_, DWM_ y DWA_Time deben estar correctamente pobladas.
--   - Las claves de fecha deben estar asociadas a timeKey.
--
-- Recomendación:
--   Ejecutar este script luego de validar la calidad de datos
--   y antes de actualizar la metadata.
-- =============================================================================


-- 1. Ventas por producto y mes
INSERT INTO DP_SalesByProductMonth (productID, productName, year, month, totalAmount, uuid)
SELECT
    p.productID,
    p.productName,
    t.year,
    t.month,
    SUM(sf.totalAmount) AS totalAmount,
    p.uuid
FROM DWA_SalesFact sf
JOIN DWA_Products p ON sf.productID = p.productID
JOIN DWA_Time t ON sf.orderDateKey = t.timeKey
GROUP BY p.productID, t.year, t.month;

-- 2. Top clientes por facturación
INSERT INTO DP_TopCustomersByRevenue (customerID, customerName, totalRevenue, uuid)
SELECT
    c.customerID,
    c.companyName,
    SUM(sf.totalAmount) AS totalRevenue,
    c.uuid
FROM DWA_SalesFact sf
JOIN DWA_Customers c ON sf.customerID = c.customerID
GROUP BY c.customerID
ORDER BY totalRevenue DESC;

-- 3. Ventas por región y trimestre
INSERT INTO DP_RegionalSalesByQuarter (regionID, regionName, year, quarter, totalAmount)
SELECT
    r.regionID,
    r.regionDescription,
    t.year,
    t.quarter,
    SUM(sf.totalAmount) AS totalAmount
FROM DWA_SalesFact sf
JOIN DWA_Time t ON sf.orderDateKey = t.timeKey
JOIN DWA_Territories tt ON sf.territoryID = tt.territoryID
JOIN DWA_Regions r ON tt.regionID = r.regionID
GROUP BY r.regionID, t.year, t.quarter;

-- 4. Desempeño de empleados
INSERT INTO DP_EmployeePerformance (employeeID, employeeName, year, totalSales, uuid)
SELECT
    e.employeeID,
    e.lastName || ', ' || e.firstName,
    t.year,
    SUM(sf.totalAmount) AS totalSales,
    e.uuid
FROM DWA_SalesFact sf
JOIN DWA_Employees e ON sf.employeeID = e.employeeID
JOIN DWA_Time t ON sf.orderDateKey = t.timeKey
GROUP BY e.employeeID, t.year;

-- 5. Análisis de devoluciones (placeholder: ventas con descuento > 0 como proxy)
INSERT INTO DP_ProductReturns (orderID, productID, discount, reason)
SELECT
    sf.orderID,
    sf.productID,
    sf.discount,
    'Discount > 0 (posible devolución)' AS reason
FROM DWA_SalesFact sf
WHERE sf.discount > 0;

-- 6. Entregas demoradas
INSERT INTO DP_ShippingDelays (orderID, customerID, delayDays, isDelayed)
SELECT
    df.orderID,
    df.customerID,
    df.deliveryDelayDays,
    CASE WHEN df.deliveryDelayDays > 0 THEN 1 ELSE 0 END AS isDelayed
FROM DWA_DeliveriesFact df
WHERE df.isDelivered = 1;
