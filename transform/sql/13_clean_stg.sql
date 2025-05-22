-- Se verifica si hay paises que se encuentren en Clientes pero no en WorldData o que no coincidan las claves
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

INSERT INTO STG_WorldData2023 (Country, GDP, Gasoline_Price, Population)
VALUES ('Ireland', '$551,395,000,000', '$1.8425', '5,233,461');

-- Debido a que el precio del combustible en Venezuela no parece correcto, se modifica de acuerdo a lo obtenido.
-- Fuente: https://www.bloomberglinea.com/2024/01/05/precio-de-la-gasolina-en-latinoamerica-los-paises-con-el-litro-mas-caro-en-2024/
UPDATE STG_WorldData2023
SET Gasoline_Price = '$0.50'
WHERE Country = 'Venezuela';

-- Por error en el nombre de un país, se eliminan aquellos con símbolos que pueden generar problemas a futuro
DELETE FROM STG_WorldData2023
WHERE Country GLOB '*[^ -~]*';

-- Se verifica si quedan pendientes paises que se encuentren en Clientes pero no en WorldData
SELECT DISTINCT country
FROM STG_Customers
WHERE country NOT IN (
    SELECT DISTINCT Country FROM STG_WorldData2023
);

-- Si la respuesta es vacía, los datos de discount se encuentran entre 0 y 1 y es correcto
SELECT *
FROM STG_OrderDetails
WHERE discount < 0 
    OR discount > 1 
    OR discount IS NULL; 
    