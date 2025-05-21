# 00a_run_start_pipeline.py
import subprocess
import sys
import os

# Determinar ruta base: el directorio donde está este archivo
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Lista de scripts a ejecutar (relativos al BASE_DIR)
scripts = [
    "10a_load_new_csv_to_tmp.py",
    "12_copy_tmp_to_stg.py",
    "13_clean_stg.py",
    "15_generate_dwa_time.py",
    "20_transform_stg_to_dwa.py",
    "25_assign_date_keys_to_facts.py",
    "30_update_dwm_from_dwa.py",
    "50_generate_data_products.py"
]

# Modo de ejecución: True = detener al primer error, False = continuar
modo_estricto = True

def ejecutar_scripts(scripts, detener_si_falla=True):
    for script in scripts:
        script_path = os.path.join(BASE_DIR, script)
        print(f"\n▶️ Ejecutando: {script}")
        try:
            resultado = subprocess.run(
                [sys.executable, script_path],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            print(f"✅ Ejecución correcta de {script}")
            print(resultado.stdout)
        except subprocess.CalledProcessError as e:
            print(f"❌ Error ejecutando {script}")
            print(e.stderr)
            if detener_si_falla:
                print("Ejecución detenida.")
                break

if __name__ == "__main__":
    ejecutar_scripts(scripts, detener_si_falla=modo_estricto)
