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
    FOREIGN KEY (employeeID) REFERENCES TMP_Employees(employeeID)
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
