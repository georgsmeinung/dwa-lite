# Cancelas, Martín.
# Nicolau, Jorge.

# Script: validate_quality.py
import os
import sys
from dotenv import load_dotenv
from quality_checks import validate_table_quality

# Establecer working directory como el del script
script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)
sys.path.insert(0, script_dir)

# Cargar variables de entorno desde .env
load_dotenv()

DB_PATH = os.getenv('DB_PATH')  
print(DB_PATH) 

TABLES_TO_VALIDATE = [    
    "DP_EmployeePerformance", "DP_ProductReturns", "DP_SalesByProductMonth", "DP_ShippingDelays", "DP_TopCustomersByRevenue"
]

for table in TABLES_TO_VALIDATE:
    validate_table_quality(DB_PATH, table)
