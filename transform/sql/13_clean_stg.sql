-- Cancelas, Martín.
-- Nicolau, Jorge.A

-- ================================================================================
-- Script: clean_stg.sql
-- Descripción:
--
-- Funcionalidad:
--
-- Requisitos:
--
-- Uso:
--
-- ================================================================================

-- Verificación de paises que se encuentren en Clientes pero no en WorldData o que no coincidan las claves.
SELECT DISTINCT country
FROM STG_Customers
WHERE country NOT IN (
    SELECT DISTINCT Country FROM STG_WorldData2023
);

-- Actualizaciones para que coincidan las claves de las tablas de Clientes, Proveedores y WorldData
UPDATE STG_Customers
SET country = 'United Kingdom'
WHERE country = 'UK';

UPDATE STG_Customers
SET country = 'United States'
WHERE country = 'USA';

UPDATE STG_Suppliers
SET country = 'United Kingdom'
WHERE country = 'UK';

UPDATE STG_Suppliers
SET country = 'United States'
WHERE country = 'USA';

-- Inclusión de países faltantes en WorldData, con datos de interés para la creación de productos.
INSERT INTO STG_WorldData2023 (Country, GDP, Gasoline_Price, Population)
VALUES ('Ireland', '$551,395,000,000', '$1.8425', '5,233,461');

-- Modificación del precio del combustible en Venezuela por no considerarse correcto.
-- Fuente: https://www.bloomberglinea.com/2024/01/05/precio-de-la-gasolina-en-latinoamerica-los-paises-con-el-litro-mas-caro-en-2024/
UPDATE STG_WorldData2023
SET Gasoline_Price = '$0.50'
WHERE Country = 'Venezuela';

-- Eliminación de países con símbolos en su nombre que pudieran generar problemas a futuro.
DELETE FROM STG_WorldData2023
WHERE Country GLOB '*[^ -~]*';

-- Verificación de paises que se encuentren en Clientes pero no en WorldData o que no coincidan las claves.
SELECT DISTINCT country
FROM STG_Customers
WHERE country NOT IN (
    SELECT DISTINCT Country FROM STG_WorldData2023
);

-- Verificación de correcto formato de la columna discount del detalle de ordenes. Si sus datos se encuentran entre 0 y 1, el formato es correcto.
SELECT *
FROM STG_OrderDetails
WHERE discount < 0 
    OR discount > 1 
    OR discount IS NULL; 
    