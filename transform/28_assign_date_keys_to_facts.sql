-- Script SQL para actualizar claves de tiempo en tablas de hechos usando DWA_Time

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
