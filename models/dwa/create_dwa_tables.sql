-- Script extendido de creación de tablas DWA_ en SQLite basado en un modelo dimensional enriquecido, con trazabilidad UUID

-- Dimensión Clientes
CREATE TABLE DWA_Customers (
    customerKey INTEGER PRIMARY KEY,
    customerID TEXT,
    companyName TEXT,
    contactName TEXT,
    contactTitle TEXT,
    address TEXT,
    city TEXT,
    region TEXT,
    postalCode TEXT,
    country TEXT,
    uuid TEXT
);

-- Dimensión Productos
CREATE TABLE DWA_Products (
    productKey INTEGER PRIMARY KEY,
    productID INTEGER,
    productName TEXT,
    categoryName TEXT,
    quantityPerUnit TEXT,
    unitPrice REAL,
    discontinued INTEGER,
    uuid TEXT
);

-- Dimensión Proveedores
CREATE TABLE DWA_Suppliers (
    supplierKey INTEGER PRIMARY KEY,
    supplierID INTEGER,
    companyName TEXT,
    country TEXT
);

-- Dimensión Empleados
CREATE TABLE DWA_Employees (
    employeeKey INTEGER PRIMARY KEY,
    employeeID INTEGER,
    fullName TEXT,
    title TEXT,
    city TEXT,
    country TEXT,
    uuid TEXT
);

-- Dimensión Territorios
CREATE TABLE DWA_Territories (
    territoryKey INTEGER PRIMARY KEY,
    territoryID TEXT,
    territoryDescription TEXT,
    regionID INTEGER
);

-- Dimensión Regiones
CREATE TABLE DWA_Regions (
    regionKey INTEGER PRIMARY KEY,
    regionID INTEGER,
    regionDescription TEXT
);

-- Dimensión Tiempo (extendida)
CREATE TABLE DWA_Time (
    timeKey INTEGER PRIMARY KEY,
    date TEXT,
    year INTEGER,
    quarter INTEGER,
    month INTEGER,
    monthName TEXT,
    day INTEGER,
    dayOfWeek INTEGER,
    weekOfYear INTEGER,
    isWeekend BOOLEAN
);

-- Tabla de hechos Ventas (momento de la orden)
CREATE TABLE DWA_SalesFact (
    salesKey INTEGER PRIMARY KEY,
    orderID INTEGER,
    productKey INTEGER,
    customerKey INTEGER,
    employeeKey INTEGER,
    territoryKey INTEGER,
    orderDateKey INTEGER,
    quantity INTEGER,
    unitPrice REAL,
    discount REAL,
    freight REAL,
    totalAmount REAL,
    uuid TEXT
);

-- Tabla de hechos Entregas (momento del despacho)
CREATE TABLE DWA_DeliveriesFact (
    deliveryKey INTEGER PRIMARY KEY,
    orderID INTEGER,
    customerKey INTEGER,
    employeeKey INTEGER,
    shipperID INTEGER,
    shippedDateKey INTEGER,
    requiredDateKey INTEGER,
    deliveryDelayDays INTEGER,
    freight REAL,
    isDelivered BOOLEAN,
    uuid TEXT
);
