-- Cancelas, Martín.
-- Nicolau, Jorge.A

-- Creación de tablas STG_ para corregir datos de TMP, con soporte de UUID
PRAGMA foreign_keys = ON; -- Habilitación de Foreign Keys

-- Categorías
CREATE TABLE STG_Categories (
    categoryID INTEGER PRIMARY KEY,
    categoryName TEXT,
    description TEXT,
    picture TEXT
);

-- Clientes
CREATE TABLE STG_Customers (
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

-- Territorio de los Empleados
CREATE TABLE STG_EmployeeTerritories (
    employeeID INTEGER,
    territoryID INTEGER,
    PRIMARY KEY (employeeID, territoryID),
    FOREIGN KEY (territoryID) REFERENCES STG_Territories(territoryID),
    FOREIGN KEY (employeeID) REFERENCES STG_Employees(employeeID)
);

-- Empleados
CREATE TABLE STG_Employees (
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

 -- Detalle de las ordenes de venta
CREATE TABLE STG_OrderDetails (
    orderID INTEGER,
    productID INTEGER,
    unitPrice REAL,
    quantity INTEGER,
    discount REAL,
    PRIMARY KEY (orderID, productID),
    FOREIGN KEY (orderID) REFERENCES STG_Orders(orderID),
    FOREIGN KEY (productID) REFERENCES STG_Products(productID)
);

-- Ordenes de venta
CREATE TABLE STG_Orders (
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
    FOREIGN KEY (customerID) REFERENCES STG_Customers(customerID),
    FOREIGN KEY (employeeID) REFERENCES STG_Employees(employeeID),
    FOREIGN KEY (shipVia) REFERENCES STG_Shippers(shipperID)
);

-- Productos
CREATE TABLE STG_Products (
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
    FOREIGN KEY (categoryID) REFERENCES STG_Categories(categoryID),
    FOREIGN KEY (supplierID) REFERENCES STG_Suppliers(supplierID)
);

-- Regiones
CREATE TABLE STG_Regions (
    regionID INTEGER PRIMARY KEY,
    regionDescription TEXT
);

-- Transportistas
CREATE TABLE STG_Shippers (
    shipperID INTEGER PRIMARY KEY,
    companyName TEXT,
    phone TEXT
);

-- Proveedores
CREATE TABLE STG_Suppliers (
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

-- Territorios
CREATE TABLE STG_Territories (
    territoryID INTEGER PRIMARY KEY,
    territoryDescription TEXT,
    regionID INTEGER,
    FOREIGN KEY (regionID) REFERENCES STG_Regions(regionID)
);

-- Datos de países al 2023
CREATE TABLE STG_WorldData2023 (
    Country TEXT,
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
    Out_Of_Pocket_Health_Expenditure TEXT,
    Physicians_Per_Thousand REAL,
    Population TEXT,
    Labor_Force_Participation_PCT TEXT,
    Tax_Revenue_PCT TEXT,
    Total_Tax_Rate TEXT,
    Unemployment_Rate TEXT,
    Urban_Population TEXT,
    Latitude REAL,
    Longitude REAL
);
