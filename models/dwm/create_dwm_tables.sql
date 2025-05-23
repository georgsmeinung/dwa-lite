-- Cancelas, Martín.
-- Nicolau, Jorge.A

-- Creación de tablas DWM_ con soporte para SCD Tipo 2 y trazabilidad UUID

-- Clientes con historial y trazabilidad
CREATE TABLE DWM_Customers (
    customerSCDKey INTEGER PRIMARY KEY AUTOINCREMENT,
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
    birthDate TEXT,
    hireDate TEXT,
    city TEXT,
    country TEXT,
    territory TEXT,
    region TEXT,
    notes TEXT,
    photoPath TEXT,
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
    validFrom TEXT,
    validTo TEXT,
    isCurrent BOOLEAN
);

-- Datos de países con historial y trazabilidad
CREATE TABLE DWM_WorldData2023 (
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
    Longitude REAL,
    validFrom TEXT,
    validTo TEXT,
    isCurrent BOOLEAN
);

-- Ventas con historial y trazabilidad
CREATE TABLE DWM_SalesFact (
    SalesKey INTEGER PRIMARY KEY AUTOINCREMENT,
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
    validFrom TEXT,
    validTo TEXT,
    isCurrent BOOLEAN
);

-- Entregas con historial y trazabilidad
CREATE TABLE DWM_DeliveriesFact (
    DeliveryKey INTEGER PRIMARY KEY AUTOINCREMENT,
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
    validFrom TEXT,
    validTo TEXT,
    isCurrent BOOLEAN
);
