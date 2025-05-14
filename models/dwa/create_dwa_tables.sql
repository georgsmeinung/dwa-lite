-- Script extendido de creación de tablas DWA_ en SQLite basado en un modelo dimensional enriquecido, con trazabilidad UUID

PRAGMA foreign_keys = ON; -- Habilitar las foreign keys

-- Dimensión Categorías
CREATE TABLE DWA_Categories (
    categoryKey INTEGER PRIMARY KEY,
    categoryID TEXT,
    categoryName TEXT,
    description TEXT,
    picture TEXT
);

-- Dimensión Clientes
CREATE TABLE DWA_Customers (
    customerKey INTEGER PRIMARY KEY,
    customerID TEXT,
    companyName TEXT,
    contactName TEXT,
    contactTitle TEXT,
    address TEXT,
    city TEXT,
    postalCode TEXT,
    country TEXT,
    phone TEXT,
    fax TEXT,
    uuid TEXT,
    FOREIGN KEY (country) REFERENCES DWA_WorldData2023(Country)
);

-- Dimensión Territorio de los empleados
CREATE TABLE DWA_EmployeeTerritories (
    employeeKey INTEGER,
    territoryKey INTEGER,
    employeeID INTEGER,
    territoryID INTEGER,
    PRIMARY KEY (employeeKey, territoryKey),
    FOREIGN KEY (territoryID) REFERENCES TMP_Territories(territoryID),
    FOREIGN KEY (employeeID) REFERENCES TMP_Employees(employeeID)
);

-- Dimensión Empleados
CREATE TABLE DWA_Employees (
    employeeKey INTEGER PRIMARY KEY,
    employeeID INTEGER,
    fullName TEXT,
    title TEXT,
    birthDate TEXT,
    hireDate TEXT,
    city TEXT,
    country TEXT,
    territory TEXT,
    region TEXT,
    notes TEXT,
    photoPath TEXT,
    uuid TEXT
);

-- Order details y orders?

-- Dimensión Productos
CREATE TABLE DWA_Products (
    productKey INTEGER PRIMARY KEY,
    productID INTEGER,
    productName TEXT,
    supplier INTEGER,
    categoryName TEXT,
    quantityPerUnit TEXT,
    unitPrice REAL,
    unitsInStock INTEGER,
    unitsOnOrder INTEGER,
    reorderLevel INTEGER,
    discontinued INTEGER,
    uuid TEXT
);

-- Dimensión Regiones
CREATE TABLE DWA_Regions (
    regionKey INTEGER PRIMARY KEY,
    regionID INTEGER,
    regionDescription TEXT
);

-- Dimesión Transportistas
CREATE TABLE DWA_Shippers (
    shipperKey INTEGER PRIMARY KEY,
    shipperID INTEGER,
    companyName TEXT,
    phone TEXT
);

-- Dimensión Proveedores
CREATE TABLE DWA_Suppliers (
    supplierKey INTEGER PRIMARY KEY,
    supplierID INTEGER,
    companyName TEXT,
    postalCode TEXT,
    country TEXT,
    phone TEXT
);

-- Dimensión Territorios
CREATE TABLE DWA_Territories (
    territoryKey INTEGER PRIMARY KEY,
    territoryID TEXT,
    territoryDescription TEXT,
    regionID INTEGER,
    FOREIGN KEY (regionID) REFERENCES DWA_Regions(regionID)
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

-- Dimensión WorldData - Quizas no llevarla a DWA, sino solo usar algún dato que nos sirva en el INSERT y listo.
CREATE TABLE DWA_WorldData2023 (
    Country TEXT,
    Density_PKm2 TEXT, -- Tiene valores con coma
    Abbreviation TEXT,
    Agricultural_Land_PCT TEXT,
    Land_Area_Km2 TEXT,
    Armed_Forces_Size TEXT,
    Birth_Rate REAL,
    Calling_Code INTEGER,
    Capital_Major_City TEXT,
    Co2_Emissions TEXT,
    CPI REAL,
    CPI_Change_PCT TEXT,
    Currency_Code TEXT,
    Fertility_Rate REAL,
    Forested_Area_PCT TEXT,
    Gasoline_Price TEXT, -- No debería ser REAL?
    GDP TEXT, -- No debería ser REAL?
    Primary_Education_Enrollment_PCT TEXT,
    Tertiary_Education_Enrollment_PCT TEXT,
    Infant_Mortality REAL,
    Largest_City TEXT,
    Life_Expectancy REAL,
    Maternal_Mortality_Ratio INTEGER,
    Minimum_Wage TEXT, -- No debería ser REAL?
    Official_Language TEXT,
    Out_of_Pocket_Health_Expenditure TEXT, -- No debería ser REAL?
    Physicians_per_Thousand REAL,
    Population TEXT, -- No debería ser INTEGER?
    Labor_Force_Participation_PCT TEXT,
    Tax_Revenue_PCT TEXT,
    Total_Tax_Rate TEXT,
    Unemployment_Rate TEXT,
    Urban_Population TEXT, -- No debería ser INTEGER?
    Latitude REAL,
    Longitude REAL
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
