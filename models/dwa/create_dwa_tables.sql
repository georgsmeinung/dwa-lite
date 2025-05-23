-- Cancelas, Martín.
-- Nicolau, Jorge.A

-- SCreación de tablas DWA_ basado en un modelo dimensional enriquecido, con trazabilidad UUID
PRAGMA foreign_keys = ON; -- Habilición de Foreign Keys

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

-- Dimensión Productos
CREATE TABLE DWA_Products (
    productKey INTEGER PRIMARY KEY,
    productID INTEGER,
    productName TEXT,
    supplier INTEGER,
    countryOrigin TEXT,
    categoryName TEXT,
    quantityPerUnit TEXT,
    unitPrice REAL,
    unitsInStock INTEGER,
    unitsOnOrder INTEGER,
    reorderLevel INTEGER,
    discontinued INTEGER,
    uuid TEXT,
    FOREIGN KEY (countryOrigin) REFERENCES DWA_WorldData2023(Country)
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

-- Dimensión WorldData
CREATE TABLE DWA_WorldData2023 (
    Country TEXT PRIMARY KEY,
    Density_PKm2 TEXT,
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
    Gasoline_Price TEXT,
    GDP TEXT,
    Primary_Education_Enrollment_PCT TEXT,
    Tertiary_Education_Enrollment_PCT TEXT,
    Infant_Mortality REAL,
    Largest_City TEXT,
    Life_Expectancy REAL,
    Maternal_Mortality_Ratio INTEGER,
    Minimum_Wage TEXT,
    Official_Language TEXT,
    Out_of_Pocket_Health_Expenditure TEXT,
    Physicians_per_Thousand REAL,
    Population TEXT,
    Labor_Force_Participation_PCT TEXT,
    Tax_Revenue_PCT TEXT,
    Total_Tax_Rate TEXT,
    Unemployment_Rate TEXT,
    Urban_Population TEXT,
    Latitude REAL,
    Longitude REAL
);

-- Tabla de hechos Ventas
CREATE TABLE DWA_SalesFact (
    salesKey INTEGER PRIMARY KEY,
    orderID INTEGER,
    productKey INTEGER,
    customerKey INTEGER,
    employeeKey INTEGER,
    territory TEXT,
    orderDateKey INTEGER,
    quantity INTEGER,
    unitPrice REAL,
    discount REAL,
    freight REAL,
    totalAmount REAL,
    uuid TEXT,
    FOREIGN KEY (productKey) REFERENCES DWA_Products(productKey),
    FOREIGN KEY (employeeKey) REFERENCES DWA_Employees(employeeKey),
    FOREIGN KEY (customerKey) REFERENCES DWA_Customers(customerKey),
    FOREIGN KEY (orderDateKey) REFERENCES DWA_Time(timeKey)
);

-- Tabla de hechos Entregas
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
    uuid TEXT,
    FOREIGN KEY (customerKey) REFERENCES DWA_Customers(customerKey),
    FOREIGN KEY (employeeKey) REFERENCES DWA_Employees(employeeKey)
);
