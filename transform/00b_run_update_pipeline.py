# Cancelas, Martín.
# Nicolau, Jorge.

# 00b_run_update_pipeline.py
import subprocess
import sys
import os
import get_execution_id as pid

# Determinar ruta base: el directorio donde está este archivo
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

execution_id = pid.get_or_create_execution_id()

# Lista de scripts a ejecutar (relativos al BASE_DIR)
scripts = [
    "10b_load_update_csv_to_tmp.py",
    "10m_register_tmp_metadata.py",
    "10q_tmp_quality_check.py",
    "12_copy_tmp_to_stg.py",
    "13_clean_stg.py",
    "13m_register_stg_metadata.py",
    "13q_stg_quality_check.py",
    "15_generate_dwa_time.py",
    "20_transform_stg_to_dwa.py",
    "25_assign_date_keys_to_facts.py",
    "25m_register_dwa_metadata.py",
    "25q_dwa_quality_check.py",
    "30_update_dwm_from_dwa.py",
    "30m_register_dwm_metadata.py",
    "30q_dwm_quality_check.py",
    "50_generate_data_products.py",
    "50m_register_dp_metadata.py",
    "50q_dp_quality_check.py"
]

# Modo de ejecución: True = detener al primer error, False = continuar
modo_estricto = True

def ejecutar_scripts(scripts, detener_si_falla=True):
    for script in scripts:
        script_path = os.path.join(BASE_DIR, script)
        print(f"\n-> Ejecutando: {script}")
        try:
            resultado = subprocess.run(
                [sys.executable, script_path],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            print(f"[i] Ejecución correcta de {script}")
            print(resultado.stdout)
        except subprocess.CalledProcessError as e:
            print(f"[x] Error ejecutando {script}")
            print(e.stderr)
            if detener_si_falla:
                print("Ejecución detenida.")
                break

if __name__ == "__main__":
    ejecutar_scripts(scripts, detener_si_falla=modo_estricto)
    pid.clear_execution_id()