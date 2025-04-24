-- =============================================================================
-- Script: assign_date_keys_to_facts.sql
-- Descripción:
--   Este script asigna claves de fecha (`timeKey`) a las tablas de hechos
--   `DWA_SalesFact` y `DWA_DeliveriesFact`, utilizando la tabla de dimensión 
--   temporal `DWA_Time`.
--
-- Funcionalidad:
--   - Hace join entre las fechas de las tablas de hechos (`orderDate`, `shippedDate`,
--     `requiredDate`) y la tabla `DWA_Time` para obtener su correspondiente `timeKey`.
--   - Actualiza los campos `orderDateKey`, `shippedDateKey` y `requiredDateKey`
--     en las tablas de hechos.
--
-- Requisitos:
--   - La tabla `DWA_Time` debe estar previamente generada y contener todas las fechas
--     necesarias para los pedidos y entregas.
--   - Las tablas de hechos deben tener cargadas las fechas originales (`orderDate`, etc.).
--
-- Consideraciones:
--   - Este script no modifica los valores originales de fecha; sólo agrega las claves
--     para análisis dimensional eficiente.
--   - Las fechas sin correspondencia en `DWA_Time` serán ignoradas.
--
-- Recomendación:
--   Ejecutar este script luego de cargar las tablas de hechos y antes de generar 
--   productos analíticos o construir visualizaciones.
-- =============================================================================


-- Asignar orderDateKey en DWA_SalesFact
UPDATE DWA_SalesFact
SET orderDateKey = (
    SELECT timeKey FROM DWA_Time
    WHERE DWA_Time.date = (
        SELECT orderDate FROM TMP_Orders WHERE TMP_Orders.orderID = DWA_SalesFact.orderID
    )
)
WHERE orderDateKey IS NULL;

-- Asignar shippedDateKey en DWA_DeliveriesFact
UPDATE DWA_DeliveriesFact
SET shippedDateKey = (
    SELECT timeKey FROM DWA_Time
    WHERE DWA_Time.date = (
        SELECT shippedDate FROM TMP_Orders WHERE TMP_Orders.orderID = DWA_DeliveriesFact.orderID
    )
)
WHERE shippedDateKey IS NULL;

-- Asignar requiredDateKey en DWA_DeliveriesFact
UPDATE DWA_DeliveriesFact
SET requiredDateKey = (
    SELECT timeKey FROM DWA_Time
    WHERE DWA_Time.date = (
        SELECT requiredDate FROM TMP_Orders WHERE TMP_Orders.orderID = DWA_DeliveriesFact.orderID
    )
)
WHERE requiredDateKey IS NULL;
