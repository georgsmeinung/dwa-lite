-- Se verifica si hay paises que se encuentren en Clientes pero no en WorldData o que no coincidan las claves
SELECT DISTINCT country
FROM TMP_Customers
WHERE country NOT IN (
    SELECT DISTINCT Country FROM TMP_WorldData2023
);

-- Actualizaciones para que coincidan las claves de las tablas de Clientes y WorldData
UPDATE TMP_Customers
SET country = 'United Kingdom'
WHERE country = 'UK';

UPDATE TMP_Customers
SET country = 'United States'
WHERE country = 'USA';

INSERT INTO TMP_WorldData2023 (Country)
VALUES ('Ireland');

-- Por error en el nombre de un país, se eliminan aquellos con símbolos que pueden generar problemas a futuro
DELETE FROM TMP_WorldData2023
WHERE Country GLOB '*[^ -~]*';

-- Se verifica si quedan pendientes paises que se encuentren en Clientes pero no en WorldData
SELECT DISTINCT country
FROM TMP_Customers
WHERE country NOT IN (
    SELECT DISTINCT Country FROM TMP_WorldData2023
);

-- Si la respuesta es vacía, los datos de discount se encuentran entre 0 y 1 y es correcto
SELECT *
FROM TMP_OrderDetails
WHERE discount < 0 
    OR discount > 1 
    OR discount IS NULL; 
    