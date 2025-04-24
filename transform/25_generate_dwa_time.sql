-- Script SQL para extender automáticamente DWA_Time según las fechas presentes en TMP_Orders

-- Obtener fechas mínimas y máximas de interés
WITH bounds AS (
    SELECT
        MIN(date(orderDate)) AS min_date,
        MAX(date(COALESCE(shippedDate, requiredDate, orderDate))) AS max_date
    FROM TMP_Orders
),
latest AS (
    SELECT MAX(date) AS current_max FROM DWA_Time
),
range AS (
    SELECT date(min_date) AS start_date,
           date(MAX(max_date, current_max)) AS end_date
    FROM bounds, latest
),
dates(date) AS (
    SELECT start_date FROM range
    UNION ALL
    SELECT date(date, '+1 day')
    FROM dates, range
    WHERE date < end_date
    AND date NOT IN (SELECT date FROM DWA_Time)
)
INSERT INTO DWA_Time (
    date, year, quarter, month, monthName,
    day, dayOfWeek, weekOfYear, isWeekend
)
SELECT
    date,
    CAST(strftime('%Y', date) AS INTEGER),
    CAST(((CAST(strftime('%m', date) AS INTEGER)-1)/3)+1 AS INTEGER) AS quarter,
    CAST(strftime('%m', date) AS INTEGER),
    CASE strftime('%m', date)
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
    CAST(strftime('%d', date) AS INTEGER),
    CAST(strftime('%w', date) AS INTEGER),
    CAST(strftime('%W', date) AS INTEGER),
    CASE WHEN strftime('%w', date) IN ('0','6') THEN 1 ELSE 0 END
FROM dates;
