-- =============================================================================
-- Script: generate_dwa_time.sql
-- Descripción:
--   Este script genera y/o extiende la tabla DWA_Time, que actúa como 
--   dimensión de tiempo en el modelo dimensional del DWA (Data Warehouse Automation).
--
-- Funcionalidad:
--   - Crea la tabla DWA_Time si no existe (se asume creada previamente o fuera de este script).
--   - Detecta la fecha máxima en STG_Orders, considerando orderDate, 
--     requiredDate y shippedDate.
--   - Compara contra la última fecha cargada en DWA_Time.
--   - Calcula dinámicamente el rango a cubrir, extendiéndolo en al menos 18 meses
--     más allá de la fecha máxima encontrada, para contemplar eventos futuros.
--   - Genera e inserta automáticamente nuevas fechas faltantes hasta completar el rango.
--   - Calcula atributos derivados por fecha: año, trimestre, mes numérico, 
--     nombre del mes, día del mes, día de la semana, semana del año y si es fin de semana.
--   - No sobrescribe datos existentes; sólo agrega fechas nuevas si es necesario.
--
-- Recomendación:
--   Ejecutar este script como paso previo a la carga de tablas de hechos,
--   para asegurar que todas las claves de fecha requeridas estén disponibles.
--   Se recomienda también ejecutarlo periódicamente como tarea automática para
--   mantener actualizada la dimensión de tiempo frente a nuevos eventos futuros.
--
-- Uso:
--   Puede invocarse manualmente o como parte de un pipeline ETL/ELT automatizado.
--   Es especialmente útil en entornos donde se registran eventos futuros,
--   como órdenes, entregas programadas o fechas estimadas de ejecución.
--
-- Notas:
--   - El rango de fechas generado se basa tanto en los datos existentes como en
--     la proyección automática de 18 meses adicionales.
--   - La fecha especial "1900-01-01" puede ser utilizada en DWA_Time para representar
--     eventos aún no ocurridos o fechas desconocidas, si se desea.
-- =============================================================================

-- =============================================================================
-- Script: generate_dwa_time.sql (versión corregida)
-- Genera o extiende la tabla DWA_Time con fechas desde datos en STG_Orders
-- =============================================================================

PRAGMA recursive_triggers = ON;
PRAGMA cte_recursion_limit = 10000;

-- Obtener fechas mínimas y máximas de interés
WITH bounds AS (
    SELECT
        MIN(DATE(orderDate)) AS min_date,
        MAX(DATE(COALESCE(shippedDate, requiredDate, orderDate))) AS max_date
    FROM STG_Orders
),
latest AS (
    SELECT COALESCE(MAX(date), '1900-01-01') AS current_max FROM DWA_Time
),
range AS (
    SELECT
        DATE(MIN(min_date)) AS start_date,
        DATE(MAX(DATE(max_date, '+18 months'), current_max)) AS end_date
    FROM bounds, latest
),
dates(date) AS (
    SELECT start_date FROM range
    UNION ALL
    SELECT DATE(date, '+1 day')
    FROM dates, range
    WHERE date < range.end_date
)
-- Solo insertar las fechas que no existen
INSERT INTO DWA_Time (
    date, year, quarter, month, monthName,
    day, dayOfWeek, weekOfYear, isWeekend
)
SELECT
    date,
    CAST(STRFTIME('%Y', date) AS INTEGER),
    CAST(((CAST(STRFTIME('%m', date) AS INTEGER)-1)/3)+1 AS INTEGER) AS quarter,
    CAST(STRFTIME('%m', date) AS INTEGER),
    CASE STRFTIME('%m', date)
        WHEN '01' THEN 'January'
        WHEN '02' THEN 'February'
        WHEN '03' THEN 'March'
        WHEN '04' THEN 'April'
        WHEN '05' THEN 'May'
        WHEN '06' THEN 'June'
        WHEN '07' THEN 'July'
        WHEN '08' THEN 'August'
        WHEN '09' THEN 'September'
        WHEN '10' THEN 'October'
        WHEN '11' THEN 'November'
        WHEN '12' THEN 'December'
    END AS monthName,
    CAST(STRFTIME('%d', date) AS INTEGER),
    CAST(STRFTIME('%w', date) AS INTEGER),
    CAST(STRFTIME('%W', date) AS INTEGER),
    CASE WHEN STRFTIME('%w', date) IN ('0','6') THEN 1 ELSE 0 END
FROM dates
WHERE date NOT IN (SELECT date FROM DWA_Time);
