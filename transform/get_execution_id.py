import os
import sys
from datetime import datetime
from pathlib import Path

def get_or_create_execution_id(file_path="current_execution.txt"):
    """
    Si el script llamador es uno autorizado, usa o genera y guarda execution_id.
    Si no, solo genera uno nuevo sin guardarlo.
    """
    authorized_scripts = {"00a_run_start_pipeline.py", "00b_run_update_pipeline.py"}
    caller_script = Path(sys.argv[0]).name

    if caller_script in authorized_scripts:
        if os.path.exists(file_path):
            with open(file_path, "r") as f:
                execution_id = f.read().strip()
        else:
            execution_id = datetime.now().strftime("%Y%m%dT%H%M%S")
            with open(file_path, "w") as f:
                f.write(execution_id)
    else:
        execution_id = datetime.now().strftime("%Y%m%dT%H%M%S")

    return execution_id

def clear_execution_id(file_path="current_execution.txt"):
    """
    Elimina el archivo que contiene el execution_id si existe.
    """
    if os.path.exists(file_path):
        os.remove(file_path)
        print(f"Execution ID eliminado: {file_path}")
    else:
        print("No hay execution_id para eliminar.")
