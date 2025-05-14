-- =============================================================================
-- Script: transform_tmp_to_dwa.sql
-- Descripción:
--   Este script transforma los datos crudos de la capa TMP_ y los carga
--   en las tablas de la capa DWA_ aplicando reglas de limpieza, enriquecimiento
--   y normalización según el modelo dimensional del DWA.
--
-- Funcionalidad:
--   - Elimina duplicados, normaliza formatos y filtra columnas irrelevantes.
--   - Aplica joins necesarios entre TMP_ y tablas auxiliares (e.g., categorías).
--   - Propaga los UUID de trazabilidad desde TMP_ hacia DWA_.
--   - Inserta datos transformados en las tablas de dimensión (Customers, Products, etc.)
--     y en las tablas de hechos (SalesFact, DeliveriesFact).
--   - Calcula métricas derivadas como `totalAmount` en ventas.
--
-- Supuestos:
--   - Las tablas TMP_ ya están pobladas.
--   - La tabla DWA_Time fue generada previamente con las fechas necesarias.
--
-- Recomendación:
--   Ejecutar este script después de la carga de CSV y la generación de DWA_Time,
--   y antes de aplicar SCD2 en la capa DWM_.
--
-- Uso:
--   Se puede ejecutar en forma automática como parte del pipeline o manualmente
--   durante el desarrollo y testing.
-- =============================================================================

-- Tablas de Dimensiones:
-- Cargar dimensión Clientes
INSERT INTO DWA_Customers (
    customerID, companyName, contactName, contactTitle,
    address, city, postalCode, country, phone, fax, uuid
)
SELECT
    customerID, companyName, contactName, contactTitle,
    address, city, postalCode, country, phone, fax, uuid
FROM TMP_Customers;

-- Cargar dimensión Empleados
INSERT INTO DWA_Employees (
    employeeID, fullName, title, birthDate, hireDate,
    city, country, territory, region, notes, photoPath, uuid
)
SELECT
    e.employeeID,
    e.firstName || ' ' || e.lastName AS fullName,
    e.title,
    e.birthDate,
    e.hireDate,
    e.city,
    e.country,
    t.territoryDescription AS territory,
    r.regionDescription AS region,
    e.notes,
    e.photoPath,
    e.uuid
FROM TMP_Employees e
LEFT JOIN TMP_EmployeeTerritories et ON e.employeeID = et.employeeID
LEFT JOIN TMP_Territories t ON et.territoryID = t.territoryID
LEFT JOIN TMP_Regions r ON t.regionID = r.regionID;
-- CHATGPT:
-- Usé LEFT JOIN porque puede haber empleados que no tengan territorio asignado, y no queremos excluirlos.
-- Si cada empleado puede tener más de un territorio, este SELECT va a generar varias filas por empleado. Si eso no es deseado, deberíamos agrupar o limitar.

-- Cargar dimensión Productos con categoría unificada
INSERT INTO DWA_Products (
    productID, productName, categoryName, supplier,
    quantityPerUnit, unitPrice, discontinued, uuid
)
SELECT
    p.productID,
    p.productName,
    c.categoryName,
    s.companyName AS supplier,
    p.quantityPerUnit,
    p.unitPrice,
    p.discontinued,
    p.uuid
FROM TMP_Products p
LEFT JOIN TMP_Categories c ON p.categoryID = c.categoryID
LEFT JOIN TMP_Suppliers s ON p.supplierID = s.supplierID;

-- Cargar dimensión Regiones
INSERT INTO DWA_Regions (
    regionID, regionDescription
)
SELECT
    regionID, regionDescription
FROM TMP_Regions;

-- Cargar dimensión Proveedores
INSERT INTO DWA_Suppliers (
    supplierID, companyName, country
)
SELECT
    supplierID, companyName, country
FROM TMP_Suppliers;

-- Cargar dimensión Territorios
INSERT INTO DWA_Territories (
    territoryID, territoryDescription, regionID
)
SELECT
    territoryID, territoryDescription, regionID
FROM TMP_Territories;

-- Tablas de Hechos:
-- Cargar tabla de hechos de ventas
INSERT INTO DWA_SalesFact (
    orderID, productKey, customerKey, employeeKey,
    territoryKey, orderDateKey, quantity, unitPrice,
    discount, freight, totalAmount, uuid
)
SELECT
    od.orderID,
    p.productKey,
    c.customerKey,
    e.employeeKey,
    NULL, -- territorio no mapeado directamente
    NULL, -- fecha a completar en capa TIME
    od.quantity,
    od.unitPrice,
    od.discount,
    o.freight,
    (od.unitPrice * od.quantity * (1 - od.discount)) AS totalAmount,
    p.uuid
FROM TMP_OrderDetails od
JOIN TMP_Orders o ON od.orderID = o.orderID
JOIN DWA_Products p ON od.productID = p.productID
JOIN DWA_Customers c ON o.customerID = c.customerID
JOIN DWA_Employees e ON o.employeeID = e.employeeID;

-- Cargar tabla de hechos de entregas
INSERT INTO DWA_DeliveriesFact (
    orderID, customerKey, employeeKey, shipperID,
    shippedDateKey, requiredDateKey, deliveryDelayDays,
    freight, isDelivered, uuid
)
SELECT
    o.orderID,
    c.customerKey,
    e.employeeKey,
    o.shipVia,
    NULL, -- dateKey de envío a mapear
    NULL, -- dateKey de requerido a mapear
    CASE
        WHEN o.shippedDate IS NOT NULL AND o.requiredDate IS NOT NULL
        THEN julianday(o.shippedDate) - julianday(o.requiredDate)
        ELSE NULL
    END AS delay,
    o.freight,
    CASE WHEN o.shippedDate IS NOT NULL THEN 1 ELSE 0 END,
    c.uuid
FROM TMP_Orders o
JOIN DWA_Customers c ON o.customerID = c.customerID
JOIN DWA_Employees e ON o.employeeID = e.employeeID;
