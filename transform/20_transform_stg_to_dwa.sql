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
--   - INSERT OR REPLACEa datos transformados en las tablas de dimensión (Customers, Products, etc.)
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
-- En primer lugar dimensión WorldData2023 para poder generar la relación con la dimensión de clientes
INSERT OR REPLACE INTO DWA_WorldData2023 (
    Country, Density_PKm2, Abbreviation, Agricultural_Land_PCT, Land_Area_Km2,
    Armed_Forces_Size, Birth_Rate, Calling_Code, Capital_Major_City, Co2_Emissions,
    CPI, CPI_Change_PCT, Currency_Code, Fertility_Rate, Forested_Area_PCT,
    Gasoline_Price, GDP, Primary_Education_Enrollment_PCT, Tertiary_Education_Enrollment_PCT,
    Infant_Mortality, Largest_City, Life_Expectancy, Maternal_Mortality_Ratio,
    Minimum_Wage, Official_Language, Out_of_Pocket_Health_Expenditure,
    Physicians_per_Thousand, Population, Labor_Force_Participation_PCT,
    Tax_Revenue_PCT, Total_Tax_Rate, Unemployment_Rate, Urban_Population,
    Latitude, Longitude
)
SELECT
    Country, Density_P_Km2, Abbreviation, Agricultural_Land_PCT, Land_AreaKm2,
    Armed_Forces_Size, Birth_Rate, Calling_Code, Capital_Major_City, Co2_Emissions,
    CPI, CPI_Change_PCT, Currency_Code, Fertility_Rate, Forested_Area_PCT,
    Gasoline_Price, GDP, Gross_primary_education_enrollment_PCT, Gross_tertiary_education_enrollment_PCT,
    Infant_Mortality, Largest_City, Life_Expectancy, Maternal_Mortality_Ratio,
    Minimum_Wage, Official_Language, Out_of_Pocket_Health_Expenditure,
    Physicians_per_Thousand, Population, Population_Labor_force_participation_PCT,
    Tax_Revenue_PCT, Total_Tax_Rate, Unemployment_Rate, Urban_Population,
    Latitude, Longitude
FROM STG_WorldData2023;

-- Cargar dimensión Clientes
INSERT OR REPLACE INTO DWA_Customers (
    customerID, companyName, contactName, contactTitle,
    address, city, postalCode, country, phone, fax, uuid
)
SELECT
    customerID, companyName, contactName, contactTitle,
    address, city, postalCode, country, phone, fax, uuid
FROM STG_Customers;

-- Cargar dimensión Empleados
INSERT OR REPLACE INTO DWA_Employees (
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
FROM STG_Employees e
LEFT JOIN STG_EmployeeTerritories et ON e.employeeID = et.employeeID
LEFT JOIN STG_Territories t ON et.territoryID = t.territoryID
LEFT JOIN STG_Regions r ON t.regionID = r.regionID;
-- CHATGPT:
-- Usé LEFT JOIN porque puede haber empleados que no tengan territorio asignado, y no queremos excluirlos.
-- Si cada empleado puede tener más de un territorio, este SELECT va a generar varias filas por empleado. Si eso no es deseado, deberíamos agrupar o limitar.

-- Cargar dimensión Productos con categoría unificada
INSERT OR REPLACE INTO DWA_Products (
    productID, productName, categoryName, supplier, countryOrigin,
    quantityPerUnit, unitPrice, discontinued, uuid
)
SELECT
    p.productID,
    p.productName,
    c.categoryName,
    s.companyName AS supplier,
    s.country AS countryOrigin,
    p.quantityPerUnit,
    p.unitPrice,
    p.discontinued,
    p.uuid
FROM STG_Products p
LEFT JOIN STG_Categories c ON p.categoryID = c.categoryID
LEFT JOIN STG_Suppliers s ON p.supplierID = s.supplierID;

-- Tablas de Hechos:
-- Cargar tabla de hechos de ventas
INSERT OR REPLACE INTO DWA_SalesFact (
    orderID, productKey, customerKey, employeeKey,
    territory, orderDateKey, quantity, unitPrice,
    discount, freight, totalAmount, uuid
)
SELECT
    od.orderID,
    p.productKey,
    c.customerKey,
    e.employeeKey,
    e.territory,
    NULL, -- fecha a completar en capa TIME
    od.quantity,
    od.unitPrice,
    od.discount,
    o.freight,
    (od.unitPrice * od.quantity * (1 - od.discount)) AS totalAmount,
    p.uuid
FROM STG_OrderDetails od
JOIN STG_Orders o ON od.orderID = o.orderID
JOIN DWA_Products p ON od.productID = p.productID
JOIN DWA_Customers c ON o.customerID = c.customerID
JOIN DWA_Employees e ON o.employeeID = e.employeeID;


-- Cargar tabla de hechos de entregas
INSERT OR REPLACE INTO DWA_DeliveriesFact (
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
FROM STG_Orders o
JOIN DWA_Customers c ON o.customerID = c.customerID
JOIN DWA_Employees e ON o.employeeID = e.employeeID;
