-- Cancelas, Martín.
-- Nicolau, Jorge.

-- ================================================================================
-- Script: copy_tmp_to_stg.sql
-- Descripción:
--
-- Funcionalidad:
--
-- Requisitos:
--
-- Uso:
--
-- ================================================================================

-- Eliminación y creación de tablas STG.
-- Desactivación de Foreign Keys.
PRAGMA foreign_keys = OFF;

DROP TABLE IF EXISTS STG_Categories;
CREATE TABLE STG_Categories AS SELECT * FROM TMP_Categories;

DROP TABLE IF EXISTS STG_Customers;
CREATE TABLE STG_Customers AS SELECT * FROM TMP_Customers;

DROP TABLE IF EXISTS STG_EmployeeTerritories;
CREATE TABLE STG_EmployeeTerritories AS SELECT * FROM TMP_EmployeeTerritories;

DROP TABLE IF EXISTS STG_Employees;
CREATE TABLE STG_Employees AS SELECT * FROM TMP_Employees;

DROP TABLE IF EXISTS STG_OrderDetails;
CREATE TABLE STG_OrderDetails AS SELECT * FROM TMP_OrderDetails;

DROP TABLE IF EXISTS STG_Orders;
CREATE TABLE STG_Orders AS SELECT * FROM TMP_Orders;

DROP TABLE IF EXISTS STG_Products;
CREATE TABLE STG_Products AS SELECT * FROM TMP_Products;

DROP TABLE IF EXISTS STG_Regions;
CREATE TABLE STG_Regions AS SELECT * FROM TMP_Regions;

DROP TABLE IF EXISTS STG_Shippers;
CREATE TABLE STG_Shippers AS SELECT * FROM TMP_Shippers;

DROP TABLE IF EXISTS STG_Suppliers;
CREATE TABLE STG_Suppliers AS SELECT * FROM TMP_Suppliers;

DROP TABLE IF EXISTS STG_Territories;
CREATE TABLE STG_Territories AS SELECT * FROM TMP_Territories;

DROP TABLE IF EXISTS STG_WorldData2023;
CREATE TABLE STG_WorldData2023 AS SELECT * FROM TMP_WorldData2023;

-- Reactivación de Foreign Keys.
PRAGMA foreign_keys = ON;
