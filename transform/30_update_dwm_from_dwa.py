# Cancelas, Martín.
# Nicolau, Jorge.

"""
Script: update_dwm_from_dwa.py
Descripción:
  Este script actualiza las tablas de la capa DWM_ aplicando la lógica
  de Slowly Changing Dimensions Tipo 2 (SCD2). Detecta cambios en las
  entidades provenientes de la capa DWA_ y mantiene un historial completo
  de las versiones en la capa DWM_.

Funcionalidad:
  - Compara registros actuales en DWM_ (isCurrent = 1) con los datos nuevos de DWA_.
  - Si se detectan cambios:
      - Se cierra el registro actual (validTo = fecha actual, isCurrent = 0).
      - Se inserta una nueva versión con validFrom = fecha actual, isCurrent = 1.
  - Si el registro no existe, se inserta como nueva fila con fecha de inicio vigente.
  - El campo `uuid` se usa para identificar la entidad lógica a lo largo de sus versiones.

Entidades soportadas:
  - Customers, Employees, Products
  (puede extenderse fácilmente a otras dimensiones versionadas)

Requisitos:
  - Las tablas DWA_ y DWM_ deben estar correctamente pobladas y tener el campo `uuid`.
  - El script debe tener acceso a un motor SQLite con las tablas ya creadas.

Recomendación:
  Ejecutar este script después de poblar la capa DWA_ y antes de generar productos
  analíticos o validar la calidad de datos.

Uso:
  Este script puede integrarse a un pipeline automático o ejecutarse manualmente.
"""

import sqlite3
import os
from datetime import datetime
from dotenv import load_dotenv

# Ruta del directorio donde está este script (no el CWD desde donde lo llamás)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Cargar .env relativo a este script también
load_dotenv(dotenv_path=os.path.join(BASE_DIR, ".env"))

# Cargar variable 
DB_PATH = os.getenv("DB_PATH", "")

now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

conn = sqlite3.connect(DB_PATH)
cursor = conn.cursor()

# Tablas y claves para aplicar SCD2
scd_tables = [
    {
        'dwa': 'DWA_Customers',
        'dwm': 'DWM_Customers',
        'business_key': 'customerID',
        'columns': [
            'companyName', 'contactName', 'contactTitle',
            'address', 'city', 'postalCode', 'country', 
            'phone', 'fax', 'uuid'
        ]
    },
    {
        'dwa': 'DWA_Employees',
        'dwm': 'DWM_Employees',
        'business_key': 'employeeID',
        'columns': [
            'fullName', 'title', 'birthDate', 'hireDate', 'city', 
            'country', 'territory', 'region', 'notes', 'photoPath', 'uuid'
        ]
    },
    {
        'dwa': 'DWA_Products',
        'dwm': 'DWM_Products',
        'business_key': 'productID',
        'columns': [
            'productName', 'supplier', 'countryOrigin', 'categoryName', 
            'quantityPerUnit', 'unitPrice', 'unitsInStock', 'unitsOnOrder', 
            'reorderLevel', 'discontinued', 'uuid'
        ]
    },
    {
        'dwa': 'DWA_WorldData2023',
        'dwm': 'DWM_WorldData2023',
        'business_key': 'Country',
        'columns': [
            'Density_PKm2', 'Abbreviation', 'Agricultural_Land_PCT', 'Land_Area_Km2', 
            'Armed_Forces_Size', 'Birth_Rate', 'Calling_Code', 'Capital_Major_City', 'Co2_Emissions',
            'CPI', 'CPI_Change_PCT', 'Currency_Code', 'Fertility_Rate', 'Forested_Area_PCT',
            'Gasoline_Price', 'GDP', 'Primary_Education_Enrollment_PCT', 'Tertiary_Education_Enrollment_PCT', 
            'Infant_Mortality', 'Largest_City', 'Life_Expectancy', 'Maternal_Mortality_Ratio', 'Minimum_Wage', 
            'Official_Language', 'Out_of_Pocket_Health_Expenditure', 'Physicians_per_Thousand', 'Population', 
            'Labor_Force_Participation_PCT', 'Tax_Revenue_PCT', 'Total_Tax_Rate', 'Unemployment_Rate', 
            'Urban_Population', 'Latitude', 'Longitude'
        ]
    },
    {
        'dwa': 'DWA_SalesFact',
        'dwm': 'DWM_SalesFact',
        'business_key': 'salesKey',
        'columns': [
            'orderID', 'productKey', 'customerKey', 'employeeKey', 'territory', 'orderDateKey', 
            'quantity', 'unitPrice', 'discount', 'freight', 'totalAmount', 'uuid'
        ]
    },
    {
        'dwa': 'DWA_DeliveriesFact',
        'dwm': 'DWM_DeliveriesFact',
        'business_key': 'deliveryKey',
        'columns': [
            'orderID', 'customerKey', 'employeeKey', 'shipperID', 'shippedDateKey', 
            'requiredDateKey', 'deliveryDelayDays', 'freight', 'isDelivered', 'uuid'
        ]
    }
]

def row_differs(row1, row2):
    return any(a != b for a, b in zip(row1, row2))

for table in scd_tables:
    print(f"Procesando SCD2 para {table['dwa']} -> {table['dwm']}")

    cursor.execute(f"SELECT {table['business_key']}, {', '.join(table['columns'])} FROM {table['dwa']}")
    for record in cursor.fetchall():
        business_id = record[0]
        values = record[1:]

        cursor.execute(f"""
            SELECT {', '.join(table['columns'])}
            FROM {table['dwm']}
            WHERE {table['business_key']} = ? AND isCurrent = 1
        """, (business_id,))
        current = cursor.fetchone()

        if current is None:
            # Nueva entrada
            cursor.execute(f"""
                INSERT INTO {table['dwm']} (
                    {table['business_key']}, {', '.join(table['columns'])},
                    validFrom, validTo, isCurrent
                ) VALUES ({', '.join(['?'] * (1 + len(values) + 3))})
            """, (business_id, *values, now, '9999-12-31', 1))
        elif row_differs(values, current):
            print(f"Actualizando {table['dwm']} para {business_id}")
            # Cierre versión actual
            cursor.execute(f"""
                UPDATE {table['dwm']}
                SET validTo = ?, isCurrent = 0
                WHERE {table['business_key']} = ? AND isCurrent = 1
            """, (now, business_id))

            # Insertar nueva versión
            placeholders = ', '.join(['?'] * (1 + len(values) + 3))
            cursor.execute(f"""
                INSERT INTO {table['dwm']} (
                    {table['business_key']}, {', '.join(table['columns'])},
                    validFrom, validTo, isCurrent
                ) VALUES ({placeholders})
            """, (business_id, *values, now, '9999-12-31', 1))


conn.commit()
conn.close()
print("Actualización SCD2 completada.")
