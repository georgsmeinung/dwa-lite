-- Script de creación de tablas DWM_ en SQLite con soporte para SCD Tipo 2 y trazabilidad UUID

-- Clientes con historial y trazabilidad
CREATE TABLE DWM_Customers (
    customerSCDKey INTEGER PRIMARY KEY AUTOINCREMENT,
    customerID TEXT,
    companyName TEXT,
    contactName TEXT,
    contactTitle TEXT,
    address TEXT,
    city TEXT,
    region TEXT,
    postalCode TEXT,
    country TEXT,
    uuid TEXT,
    validFrom TEXT,
    validTo TEXT,
    isCurrent BOOLEAN
);

-- Empleados con historial y trazabilidad
CREATE TABLE DWM_Employees (
    employeeSCDKey INTEGER PRIMARY KEY AUTOINCREMENT,
    employeeID INTEGER,
    fullName TEXT,
    title TEXT,
    address TEXT,
    city TEXT,
    region TEXT,
    postalCode TEXT,
    country TEXT,
    uuid TEXT,
    validFrom TEXT,
    validTo TEXT,
    isCurrent BOOLEAN
);

-- Proveedores con historial y trazabilidad
CREATE TABLE DWM_Suppliers (
    supplierSCDKey INTEGER PRIMARY KEY AUTOINCREMENT,
    supplierID INTEGER,
    companyName TEXT,
    contactName TEXT,
    contactTitle TEXT,
    address TEXT,
    city TEXT,
    region TEXT,
    postalCode TEXT,
    country TEXT,
    uuid TEXT,
    validFrom TEXT,
    validTo TEXT,
    isCurrent BOOLEAN
);

-- Productos con historial y trazabilidad
CREATE TABLE DWM_Products (
    productSCDKey INTEGER PRIMARY KEY AUTOINCREMENT,
    productID INTEGER,
    productName TEXT,
    categoryID INTEGER,
    categoryName TEXT,
    quantityPerUnit TEXT,
    unitPrice REAL,
    discontinued INTEGER,
    uuid TEXT,
    validFrom TEXT,
    validTo TEXT,
    isCurrent BOOLEAN
);

-- Categorías con historial y trazabilidad
CREATE TABLE DWM_Categories (
    categorySCDKey INTEGER PRIMARY KEY AUTOINCREMENT,
    categoryID INTEGER,
    categoryName TEXT,
    description TEXT,
    uuid TEXT,
    validFrom TEXT,
    validTo TEXT,
    isCurrent BOOLEAN
);

-- Territorios con historial y trazabilidad
CREATE TABLE DWM_Territories (
    territorySCDKey INTEGER PRIMARY KEY AUTOINCREMENT,
    territoryID TEXT,
    territoryDescription TEXT,
    regionID INTEGER,
    uuid TEXT,
    validFrom TEXT,
    validTo TEXT,
    isCurrent BOOLEAN
);

-- Regiones con historial y trazabilidad
CREATE TABLE DWM_Regions (
    regionSCDKey INTEGER PRIMARY KEY AUTOINCREMENT,
    regionID INTEGER,
    regionDescription TEXT,
    uuid TEXT,
    validFrom TEXT,
    validTo TEXT,
    isCurrent BOOLEAN
);
