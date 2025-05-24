-- Cancelas, Martín.
-- Nicolau, Jorge.

-- =============================================================================
-- Script modificado: STG → DWA sin join con DWA_
-- =============================================================================

-- Tablas de Dimensiones
INSERT OR REPLACE INTO DWA_Customers (
    customerID, companyName, contactName, contactTitle,
    address, city, postalCode, country, phone, fax, uuid
)
SELECT
    customerID, companyName, contactName, contactTitle,
    address, city, postalCode, country, phone, fax,
    lower(hex(randomblob(16)))
FROM STG_Customers;

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
    lower(hex(randomblob(16)))
FROM STG_Employees e
LEFT JOIN STG_EmployeeTerritories et ON e.employeeID = et.employeeID
LEFT JOIN STG_Territories t ON et.territoryID = t.territoryID
LEFT JOIN STG_Regions r ON t.regionID = r.regionID;

INSERT OR REPLACE INTO DWA_Products (
    productID, productName, categoryName, supplier, countryOrigin,
    quantityPerUnit, unitPrice, unitsInStock, unitsOnOrder, 
    reorderLevel, discontinued, uuid
)
SELECT
    p.productID,
    p.productName,
    c.categoryName,
    s.companyName AS supplier,
    s.country AS countryOrigin,
    p.quantityPerUnit,
    p.unitPrice,
    p.unitsInStock, 
    p.unitsOnOrder, 
    p.reorderLevel,
    p.discontinued,
    lower(hex(randomblob(16)))
FROM STG_Products p
LEFT JOIN STG_Categories c ON p.categoryID = c.categoryID
LEFT JOIN STG_Suppliers s ON p.supplierID = s.supplierID;

-- Tabla WorldData
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

-- Tablas de Hechos
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
