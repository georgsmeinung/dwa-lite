-- Cancelas, Martín.
-- Nicolau, Jorge. 

-- =============================================================================
-- Script: assign_date_keys_to_facts.sql
-- Descripción:
--   Este script asigna claves de fecha (`timeKey`) a las tablas de hechos
--   `DWA_SalesFact` y `DWA_DeliveriesFact`, utilizando la tabla de dimensión 
--   temporal `DWA_Time`, contemplando valores nulos mediante una fecha especial.
--
-- Funcionalidad:
--   - Hace join entre las fechas de las tablas de hechos (`orderDate`, `shippedDate`,
--     `requiredDate`) y la tabla `DWA_Time` para obtener su correspondiente `timeKey`.
--   - Si una fecha está ausente (NULL), asigna el `timeKey` correspondiente a la
--     fecha especial '1900-01-01' en `DWA_Time`.
--   - Actualiza los campos `orderDateKey`, `shippedDateKey` y `requiredDateKey`
--     en las tablas de hechos, asegurando que no queden claves de fecha nulas.
--
-- Requisitos:
--   - La tabla `DWA_Time` debe estar previamente generada, incluyendo todas las fechas
--     necesarias más la fecha especial '1900-01-01' para valores desconocidos.
--   - Las tablas de hechos deben tener cargadas las fechas originales (`orderDate`, etc.).
--
-- Consideraciones:
--   - Este script no modifica los valores originales de fecha; sólo agrega las claves
--     para análisis dimensional eficiente.
--   - Las fechas nulas o sin correspondencia exacta utilizarán la clave especial
--     para "Fecha desconocida" evitando problemas de integridad referencial.
--
-- Recomendación:
--   Ejecutar este script luego de cargar las tablas de hechos y antes de generar 
--   productos analíticos o construir visualizaciones, garantizando consistencia
--   temporal en los modelos de análisis.
-- =============================================================================

-- orderDateKey en DWA_SalesFact
UPDATE DWA_SalesFact
SET orderDateKey = COALESCE(
    (SELECT T.timeKey
     FROM DWA_Time T
     JOIN STG_Orders O ON O.orderID = DWA_SalesFact.orderID
     WHERE T.date = DATE(O.orderDate)),
    (SELECT timeKey FROM DWA_Time WHERE date = '1900-01-01')
)
WHERE orderDateKey IS NULL;

-- shippedDateKey en DWA_DeliveriesFact
UPDATE DWA_DeliveriesFact
SET shippedDateKey = COALESCE(
    (SELECT T.timeKey
     FROM DWA_Time T
     JOIN STG_Orders O ON O.orderID = DWA_DeliveriesFact.orderID
     WHERE T.date = DATE(O.shippedDate)),
    (SELECT timeKey FROM DWA_Time WHERE date = '1900-01-01')
)
WHERE shippedDateKey IS NULL;

-- requiredDateKey en DWA_DeliveriesFact
UPDATE DWA_DeliveriesFact
SET requiredDateKey = COALESCE(
    (SELECT T.timeKey
     FROM DWA_Time T
     JOIN STG_Orders O ON O.orderID = DWA_DeliveriesFact.orderID
     WHERE T.date = DATE(O.requiredDate)),
    (SELECT timeKey FROM DWA_Time WHERE date = '1900-01-01')
)
WHERE requiredDateKey IS NULL;