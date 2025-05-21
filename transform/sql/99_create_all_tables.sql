-- Script actualizado de creación de tablas TMP_ en SQLite basado en los CSV de Ingesta1, con soporte de UUID

PRAGMA foreign_keys = ON; -- Habilitar las foreign keys

CREATE TABLE TMP_Categories (
    categoryID INTEGER PRIMARY KEY,
    categoryName TEXT,
    description TEXT,
    picture TEXT
);

CREATE TABLE TMP_Customers (
    customerID TEXT PRIMARY KEY,
    companyName TEXT,
    contactName TEXT,
    contactTitle TEXT,
    address TEXT,
    city TEXT,
    region TEXT,
    postalCode TEXT, -- Conviene ponerle VARCHAR?
    country TEXT,
    phone TEXT,
    fax TEXT,
    uuid TEXT
);

CREATE TABLE TMP_EmployeeTerritories (
    employeeID INTEGER,
    territoryID INTEGER,
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
    regionDescription TEXT
);

CREATE TABLE TMP_Shippers (
    shipperID INTEGER PRIMARY KEY,
    companyName TEXT,
    phone TEXT
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
    homePage TEXT
);

CREATE TABLE TMP_Territories (
    territoryID INTEGER PRIMARY KEY,
    territoryDescription TEXT,
    regionID INTEGER,
    FOREIGN KEY (regionID) REFERENCES TMP_Regions(regionID)
);

CREATE TABLE TMP_WorldData2023 (
    Country TEXT,
    Density_P_Km2 TEXT, -- Tiene valores con coma
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
    Gasoline_Price TEXT, -- No debería ser REAL?
    GDP TEXT, -- No debería ser REAL?
    Gross_Primary_Education_Enrollment_PCT TEXT,
    Gross_Tertiary_Education_Enrollment_PCT TEXT,
    Infant_Mortality REAL,
    Largest_City TEXT,
    Life_Expectancy REAL,
    Maternal_Mortality_Ratio INTEGER,
    Minimum_Wage TEXT, -- No debería ser REAL?
    Official_Language TEXT,
    Out_Of_Pocket_Health_Expenditure TEXT, -- No debería ser REAL?
    Physicians_Per_Thousand REAL,
    Population TEXT, -- No debería ser INTEGER?
    Population_Labor_Force_Participation_PCT TEXT,
    Tax_Revenue_PCT TEXT,
    Total_Tax_Rate TEXT,
    Unemployment_Rate TEXT,
    Urban_Population TEXT, -- No debería ser INTEGER?
    Latitude REAL,
    Longitude REAL
);

-- Script de creación de la capa MET_ en SQLite con soporte para trazabilidad basada en UUID

-- Registro de tablas en el DWA
CREATE TABLE MET_Tables (
    tableID INTEGER PRIMARY KEY AUTOINCREMENT,
    tableName TEXT,
    layer TEXT, -- TMP, DWA, DWM, DQM, DP
    description TEXT,
    createdAt TEXT,
    createdBy TEXT,
    lastModified TEXT
);

-- Registro de columnas de cada tabla
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

-- Linaje de datos entre entidades
CREATE TABLE MET_Lineage (
    lineageID INTEGER PRIMARY KEY AUTOINCREMENT,
    sourceEntity TEXT, -- puede ser un .CSV, tabla TMP_ o UUID
    targetEntity TEXT, -- tabla DWA_, DWM_, DP_ o UUID
    sourceUUID TEXT, -- opcional: trazabilidad fila a fila
    targetUUID TEXT, -- opcional: trazabilidad fila a fila
    transformationDescription TEXT,
    transformationScript TEXT,
    lineageType TEXT, -- direct, derived, aggregated
    createdAt TEXT
);

-- Registro de ejecuciones de procesos de carga o transformación
CREATE TABLE MET_Executions (
    executionID INTEGER PRIMARY KEY AUTOINCREMENT,
    processName TEXT,
    executedBy TEXT,
    startTime TEXT,
    endTime TEXT,
    status TEXT, -- SUCCESS, FAILURE
    log TEXT
);

-- Versionado de tablas con hash y trazabilidad
CREATE TABLE MET_TableVersions (
    versionID INTEGER PRIMARY KEY AUTOINCREMENT,
    tableName TEXT,
    versionTag TEXT,
    versionDate TEXT,
    sourceFiles TEXT,
    hash TEXT, -- para detectar cambios estructurales o lógicos
    notes TEXT
);

-- Descripción de productos de datos
CREATE TABLE MET_DataProducts (
    dpID INTEGER PRIMARY KEY AUTOINCREMENT,
    dpTable TEXT,
    businessUseCase TEXT,
    targetAudience TEXT,
    relatedDashboards TEXT,
    createdAt TEXT,
    owner TEXT
);


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


-- Script extendido de creación de tablas DWA_ en SQLite basado en un modelo dimensional enriquecido, con trazabilidad UUID

PRAGMA foreign_keys = ON; -- Habilitar las foreign keys

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

-- Dimensión WorldData - Quizas no llevarla a DWA, sino solo usar algún dato que nos sirva en el INSERT y listo.
CREATE TABLE DWA_WorldData2023 (
    Country TEXT PRIMARY KEY,
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
    uuid TEXT,
    FOREIGN KEY (customerKey) REFERENCES DWA_Customers(customerKey),
    FOREIGN KEY (employeeKey) REFERENCES DWA_Employees(employeeKey)
);


-- Script de creación de tablas DQM_ en SQLite con trazabilidad UUID

-- Estadísticas de calidad por tabla y capa
CREATE TABLE DQM_TableStatistics (
    dqmID INTEGER PRIMARY KEY AUTOINCREMENT,
    tableName TEXT,
    dataLayer TEXT, -- TMP, DWA, DWM
    rowCount INTEGER,
    nullCount INTEGER,
    duplicateCount INTEGER,
    outlierCount INTEGER,
    createdAt TEXT
);

-- Detalle de errores o advertencias por campo con granularidad extendida y UUID
CREATE TABLE DQM_FieldIssues (
    issueID INTEGER PRIMARY KEY AUTOINCREMENT,
    tableName TEXT,
    dataLayer TEXT, -- TMP, DWA, DWM
    fieldName TEXT,
    issueType TEXT, -- NULL_VALUE, OUTLIER, FORMAT_ERROR, DOMAIN_VIOLATION
    issueSample TEXT, -- valor de ejemplo con error
    uuid TEXT, -- trazabilidad fila a fila
    issueCount INTEGER,
    issueThreshold REAL, -- umbral esperado
    severity TEXT, -- LOW, MEDIUM, HIGH
    createdAt TEXT
);

-- Resultados de carga por archivo CSV
CREATE TABLE DQM_LoadResults (
    loadID INTEGER PRIMARY KEY AUTOINCREMENT,
    sourceFile TEXT,
    tableTarget TEXT,
    rowCountSource INTEGER,
    rowCountLoaded INTEGER,
    rejectedRows INTEGER,
    loadStatus TEXT, -- SUCCESS, PARTIAL, FAILURE
    loadMessage TEXT,
    createdAt TEXT
);

-- Registro de validaciones cruzadas o de integridad referencial
CREATE TABLE DQM_IntegrityChecks (
    checkID INTEGER PRIMARY KEY AUTOINCREMENT,
    checkName TEXT,
    sourceTable TEXT,
    referenceTable TEXT,
    passed INTEGER, -- 1 = TRUE, 0 = FALSE
    issueCount INTEGER,
    createdAt TEXT
);

-- Auditoría de ejecuciones de procesos
CREATE TABLE DQM_ProcessAudit (
    auditID INTEGER PRIMARY KEY AUTOINCREMENT,
    processName TEXT,
    startTime TEXT,
    endTime TEXT,
    status TEXT, -- SUCCESS, FAILURE
    message TEXT
);

-- Script de creación de tablas DP_ en SQLite con trazabilidad UUID

-- Producto 1: Ventas consolidadas por producto y mes
CREATE TABLE DP_SalesByProductMonth (
    dpID INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT, -- UUID del producto
    productName TEXT,
    year INTEGER,
    month INTEGER,
    totalUnitsSold INTEGER,
    totalRevenue REAL
);

-- Producto 2: Ranking de clientes por facturación
CREATE TABLE DP_TopCustomersByRevenue (
    dpID INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT, -- UUID del cliente
    customerID TEXT,
    companyName TEXT,
    country TEXT,
    totalRevenue REAL,
    totalOrders INTEGER,
    rank INTEGER
);

-- Producto 4: Desempeño de empleados por año
CREATE TABLE DP_EmployeePerformance (
    dpID INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT, -- UUID del empleado
    employeeID INTEGER,
    fullName TEXT,
    year INTEGER,
    totalOrders INTEGER,
    totalRevenue REAL
);

-- Producto 5: Productos con devoluciones o cancelaciones
CREATE TABLE DP_ProductReturns (
    dpID INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT, -- UUID del producto
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

-- Producto 6: Retrasos en entregas
CREATE TABLE DP_ShippingDelays (
    dpID INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT, -- UUID del pedido
    orderID INTEGER,
    customerID TEXT,
    orderDate TEXT,
    requiredDate TEXT,
    shippedDate TEXT,
    deliveryDelayDays INTEGER
);

CREATE INDEX IF NOT EXISTS idx_stg_orders_orderid ON STG_Orders(orderID);
CREATE INDEX IF NOT EXISTS idx_dwa_salesfact_orderid ON DWA_SalesFact(orderID);
CREATE INDEX IF NOT EXISTS idx_dwa_deliveriesfact_orderid ON DWA_DeliveriesFact(orderID);
CREATE INDEX IF NOT EXISTS idx_dwa_time_date ON DWA_Time(date);
