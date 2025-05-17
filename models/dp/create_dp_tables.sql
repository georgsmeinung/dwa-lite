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