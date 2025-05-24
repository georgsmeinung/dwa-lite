-- Cancelas, Martín.
-- Nicolau, Jorge.

-- Creación de todas las tablas: TMP, DWA, DWM, DQM, DP y MET.
-- Las tablas STG se crean durante el pipeline.
-- Los detalles de cada tabla pueden ser revisados en sus scripts individuales ubicados en la carpeta "models".

PRAGMA foreign_keys = ON; -- Habilitación de Foreign Keys

-- Tablas TMP_
CREATE TABLE TMP_Categories (
    categoryID INTEGER PRIMARY KEY,
    categoryName TEXT,
    description TEXT,
    picture TEXT,
    uuid TEXT
);

CREATE TABLE TMP_Customers (
    customerID TEXT PRIMARY KEY,
    companyName TEXT,
    contactName TEXT,
    contactTitle TEXT,
    address TEXT,
    city TEXT,
    region TEXT,
    postalCode TEXT,
    country TEXT,
    phone TEXT,
    fax TEXT,
    uuid TEXT
);

CREATE TABLE TMP_EmployeeTerritories (
    employeeID INTEGER,
    territoryID INTEGER,
    uuid TEXT,
    PRIMARY KEY (employeeID, territoryID),
    FOREIGN KEY (territoryID) REFERENCES TMP_Territories(territoryID),
    FOREIGN KEY (employeeID) REFERENCES TMP_Employees(employeeID)
);

CREATE TABLE TMP_Employees (
    employeeID INTEGER PRIMARY KEY,
    lastName TEXT,
    firstName TEXT,
    title TEXT,
    titleOfCourtesy TEXT,
    birthDate TEXT,
    hireDate TEXT,
    address TEXT,
    city TEXT,
    region TEXT,
    postalCode TEXT,
    country TEXT,
    homePhone TEXT,
    extension TEXT,
    photo TEXT,
    notes TEXT,
    reportsTo INTEGER,
    photoPath TEXT,
    uuid TEXT
);

CREATE TABLE TMP_OrderDetails (
    orderID INTEGER,
    productID INTEGER,
    unitPrice REAL,
    quantity INTEGER,
    discount REAL,
    uuid TEXT,
    PRIMARY KEY (orderID, productID),
    FOREIGN KEY (orderID) REFERENCES TMP_Orders(orderID),
    FOREIGN KEY (productID) REFERENCES TMP_Products(productID)
);

CREATE TABLE TMP_Orders (
    orderID INTEGER PRIMARY KEY,
    customerID TEXT,
    employeeID INTEGER,
    orderDate TEXT,
    requiredDate TEXT,
    shippedDate TEXT,
    shipVia INTEGER,
    freight REAL,
    shipName TEXT,
    shipAddress TEXT,
    shipCity TEXT,
    shipRegion TEXT,
    shipPostalCode TEXT,
    shipCountry TEXT,
    uuid TEXT,
    FOREIGN KEY (customerID) REFERENCES TMP_Customers(customerID),
    FOREIGN KEY (employeeID) REFERENCES TMP_Employees(employeeID),
    FOREIGN KEY (shipVia) REFERENCES TMP_Shippers(shipperID)
);

CREATE TABLE TMP_Products (
    productID INTEGER PRIMARY KEY,
    productName TEXT,
    supplierID INTEGER,
    categoryID INTEGER,
    quantityPerUnit TEXT,
    unitPrice REAL,
    unitsInStock INTEGER,
    unitsOnOrder INTEGER,
    reorderLevel INTEGER,
    discontinued INTEGER,
    uuid TEXT,
    FOREIGN KEY (categoryID) REFERENCES TMP_Categories(categoryID),
    FOREIGN KEY (supplierID) REFERENCES TMP_Suppliers(supplierID)
);

CREATE TABLE TMP_Regions (
    regionID INTEGER PRIMARY KEY,
    regionDescription TEXT,
    uuid TEXT
);

CREATE TABLE TMP_Shippers (
    shipperID INTEGER PRIMARY KEY,
    companyName TEXT,
    phone TEXT,
    uuid TEXT
);

CREATE TABLE TMP_Suppliers (
    supplierID INTEGER PRIMARY KEY,
    companyName TEXT,
    contactName TEXT,
    contactTitle TEXT,
    address TEXT,
    city TEXT,
    region TEXT,
    postalCode TEXT,
    country TEXT,
    phone TEXT,
    fax TEXT,
    homePage TEXT,
    uuid TEXT
);

CREATE TABLE TMP_Territories (
    territoryID INTEGER PRIMARY KEY,
    territoryDescription TEXT,
    regionID INTEGER,
    uuid TEXT,
    FOREIGN KEY (regionID) REFERENCES TMP_Regions(regionID)
);

CREATE TABLE TMP_WorldData2023 (
    Country TEXT,
    Density_P_Km2 TEXT,
    Abbreviation TEXT,
    Agricultural_Land_PCT TEXT,
    Land_AreaKm2 TEXT,
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
    Gross_Primary_Education_Enrollment_PCT TEXT,
    Gross_Tertiary_Education_Enrollment_PCT TEXT,
    Infant_Mortality REAL,
    Largest_City TEXT,
    Life_Expectancy REAL,
    Maternal_Mortality_Ratio INTEGER,
    Minimum_Wage TEXT,
    Official_Language TEXT,
    Out_Of_Pocket_Health_Expenditure TEXT,
    Physicians_Per_Thousand REAL,
    Population TEXT,
    Population_Labor_Force_Participation_PCT TEXT,
    Tax_Revenue_PCT TEXT,
    Total_Tax_Rate TEXT,
    Unemployment_Rate TEXT,
    Urban_Population TEXT,
    Latitude REAL,
    Longitude REAL,
    uuid TEXT
);


-- Tablas DWA
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


-- Tablas DWM
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


-- Tablas DQM
CREATE TABLE DQM_TableStatistics (
    dqmID INTEGER PRIMARY KEY AUTOINCREMENT,
    tableName TEXT,
    dataLayer TEXT,
    columnCount INTEGER,
    rowCount INTEGER,
    nullCount INTEGER,
    duplicateCount INTEGER,
    outlierCount INTEGER,
    createdAt TEXT
);

CREATE TABLE DQM_FieldIssues (
    issueID INTEGER PRIMARY KEY AUTOINCREMENT,
    tableName TEXT,
    dataLayer TEXT,
    fieldName TEXT,
    issueType TEXT,
    issueSample TEXT,
    uuid TEXT,
    issueCount INTEGER,
    issueThreshold REAL,
    severity TEXT,
    createdAt TEXT
);

CREATE TABLE DQM_LoadResults (
    loadID INTEGER PRIMARY KEY AUTOINCREMENT,
    sourceFile TEXT,
    tableTarget TEXT,
    rowCountSource INTEGER,
    rowCountLoaded INTEGER,
    rejectedRows INTEGER,
    loadStatus TEXT,
    loadMessage TEXT,
    createdAt TEXT
);

CREATE TABLE DQM_IntegrityChecks (
    checkID INTEGER PRIMARY KEY AUTOINCREMENT,
    checkName TEXT,
    sourceTable TEXT,
    referenceTable TEXT,
    passed INTEGER,
    issueCount INTEGER,
    createdAt TEXT
);

CREATE TABLE DQM_ProcessAudit (
    auditID INTEGER PRIMARY KEY AUTOINCREMENT,
    processName TEXT,
    startTime TEXT,
    endTime TEXT,
    status TEXT,
    message TEXT
);


-- Tablas DP
CREATE TABLE DP_SalesByProductMonth (
    dpID INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT,
    productName TEXT,
    category TEXT,
    countryOrigin TEXT,
    countryDestiny TEXT,
    year INTEGER,
    month INTEGER,
    totalUnitsSold INTEGER,
    totalRevenue REAL
);

CREATE TABLE DP_TopCustomersByRevenue (
    dpID INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT,
    customerID TEXT,
    companyName TEXT,
    country TEXT,
    countryGasolinePrice TEXT, 
    countryGDP TEXT,
    countryPopulation TEXT,
    year TEXT,
    totalRevenue REAL,
    totalOrders INTEGER,
    rank INTEGER
);

CREATE TABLE DP_EmployeePerformance (
    dpID INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT,
    employeeID INTEGER,
    fullName TEXT,
    year INTEGER,
    totalOrders INTEGER,
    totalRevenue REAL
);

CREATE TABLE DP_ProductReturns (
    dpID INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT,
    productID INTEGER,
    productName TEXT,
    returnReason TEXT,
    supplier TEXT,
    countryOrigin TEXT,
    categoryName TEXT,
    year INTEGER, 
    returnCount INTEGER,
    totalLostRevenue REAL
);


-- Tablas MET
CREATE TABLE MET_Tables (
    tableID INTEGER PRIMARY KEY AUTOINCREMENT,
    tableName TEXT,
    layer TEXT,
    description TEXT,
    createdAt TEXT,
    createdBy TEXT,
    lastModified TEXT
);

CREATE TABLE MET_Columns (
    columnID INTEGER PRIMARY KEY AUTOINCREMENT,
    tableName TEXT,
    columnName TEXT,
    dataType TEXT,
    isPrimaryKey BOOLEAN,
    isForeignKey BOOLEAN,
    isUUID BOOLEAN DEFAULT 0,
    description TEXT
);

CREATE TABLE MET_Lineage (
    lineageID INTEGER PRIMARY KEY AUTOINCREMENT,
    sourceEntity TEXT,
    targetEntity TEXT,
    sourceUUID TEXT,
    targetUUID TEXT,
    transformationDescription TEXT,
    transformationScript TEXT,
    lineageType TEXT,
    createdAt TEXT
);

CREATE TABLE MET_Executions (
    executionID INTEGER PRIMARY KEY AUTOINCREMENT,
    processName TEXT,
    executedBy TEXT,
    startTime TEXT,
    endTime TEXT,
    status TEXT,
    log TEXT
);

CREATE TABLE MET_TableVersions (
    versionID INTEGER PRIMARY KEY AUTOINCREMENT,
    tableName TEXT,
    versionTag TEXT,
    versionDate TEXT,
    sourceFiles TEXT,
    hash TEXT,
    notes TEXT
);

CREATE TABLE MET_DataProducts (
    dpID INTEGER PRIMARY KEY AUTOINCREMENT,
    dpTable TEXT,
    businessUseCase TEXT,
    targetAudience TEXT,
    relatedDashboards TEXT,
    createdAt TEXT,
    owner TEXT
);


-- Indices para optimización
CREATE INDEX IF NOT EXISTS idx_stg_orders_orderid ON STG_Orders(orderID);
CREATE INDEX IF NOT EXISTS idx_dwa_salesfact_orderid ON DWA_SalesFact(orderID);
CREATE INDEX IF NOT EXISTS idx_dwa_deliveriesfact_orderid ON DWA_DeliveriesFact(orderID);
CREATE INDEX IF NOT EXISTS idx_dwa_time_date ON DWA_Time(date);
