-- Script actualizado de creación de tablas TMP_ en SQLite basado en los CSV de Ingesta1, con soporte de UUID

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
    postalCode TEXT,
    country TEXT,
    phone TEXT,
    fax TEXT,
    uuid TEXT
);

CREATE TABLE TMP_EmployeeTerritories (
    employeeID INTEGER,
    territoryID TEXT,
    PRIMARY KEY (employeeID, territoryID)
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
    PRIMARY KEY (orderID, productID)
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
    shipCountry TEXT
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
    uuid TEXT
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
    territoryID TEXT PRIMARY KEY,
    territoryDescription TEXT,
    regionID INTEGER
);

CREATE TABLE TMP_WorldData2023 (
    Country TEXT,
    Density_PKm2 INTEGER,
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
