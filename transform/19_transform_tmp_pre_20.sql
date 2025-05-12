UPDATE TMP_Customers
SET country = 'United Kingdom'
WHERE country = 'UK';

UPDATE TMP_Customers
SET country = 'United States'
WHERE country = 'USA';

SELECT DISTINCT country
FROM TMP_Customers
WHERE country NOT IN (
    SELECT DISTINCT Country FROM TMP_WorldData2023
);