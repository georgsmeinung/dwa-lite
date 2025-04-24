![Universidad Austral](logo-md-austral-1.png)
### Universidad Austral - Facultad de Ingeniería
### MCD 2024/2025 - Introducción a Dataware Housing
## TPG01 - Flujo DWA

- [CANCELAS, Martín](https://www.linkedin.com/in/mart%C3%ADn-cancelas-2313a1154/)
- [NICOLAU, Jorge](https://jorgenicolau.ar/)
- [VERDEJO, Manuel](https://www.linkedin.com/in/manuel-nicol%C3%A1s-verdejo-b19255126/)
---
# 🧠 DWA Lite – Solución Liviana de Data Warehouse Automation (DWA) con SQLite

Este proyecto implementa una solución lightweight de **Data Warehouse Automation (DWA)** utilizando SQLite como motor, Python para ingesta y control de calidad, SQL para transformaciones y generación de productos analíticos, y Power BI o Metabase para visualización. Todo puede ejecutarse localmente y en modo *headless*.

---

## 🚀 Objetivo

Automatizar de punta a punta el flujo de un DWA académico, incluyendo:

- Carga de datos desde archivos CSV (`TMP_`)
- Transformación y normalización (`DWA_`)
- Versionado histórico con Slowly Changing Dimension Type 2 (`DWM_`)
- Control de calidad de datos (`DQM_`)
- Generación de productos analíticos (`DP_`)
- Trazabilidad y metadata (`MET_`)

---

## 🧱 Estructura del proyecto

```
dwa-lite/
├── dashboards/          # Archivos de Dashboards Power BI
├── data/                # CSVs de entrada (Ingesta1, Ingesta2)
├── db/                  # Base SQLite (dwa.sqlite)
├── knime-flows/         # Diagramas DAG para KNIME
├── models/              # Scripts SQL de creación de capas
│   ├── dp               # Creacion Tablas Data Product (DP_)
│   ├── dqm              # Creacion Tablas Data Quality Mart (DQM_)
│   ├── dwa              # Creacion Tablas Data Warehouse (DWA_)
│   ├── dwm              # Creacion Tablas Memoria SCD2 (DWM_)
│   ├── dwm              # Creacion Tablas Metadata (MET_)
│   └── tmp              # Creacion Tablas Temporales (TMP_)
├── transform/           # Scripts SQL y Python del pipeline
│   ├── *.py             # Scripts de procesamiento (ingesta, calidad, etc.)
│   └── *.sql            # Scripts de transformación y carga
├── run_pipeline.cmd     # Ejecución pipeline completo en Windows
└── README.md            # Este archivo
```

---

## ⚙️ Requisitos

- Python 3.10+
- SQLite 3.x
- Paquetes Python: `pandas`
- Power BI Desktop (opcional)
- Metabase (opcional, para documentación visual del linaje)

Instalación rápida de dependencias:
```bash
pip install pandas
```
Creación inicial de modelos (una única vez):
```cmd
create_all_models.cmd
```

---

## 🧪 Ejecución local

```cmd
run_pipeline.cmd
```
---

## ⚙️ Ejecución Headless (modo automático y sin entorno gráfico)

El proyecto puede ejecutarse de punta a punta en modo completamente automatizado, sin entorno gráfico ni herramientas interactivas como KNIME o Metabase, mediante los scripts alojados en la carpeta `transform/`.

| Paso | Propósito                               | Herramienta   | Script/Artefacto                        | Capa       |
|------|-----------------------------------------|---------------|-----------------------------------------|------------|
| 1    | Cargar CSV en SQLite                    | Python        | `transform/load_csv_to_tmp.py`          | TMP_       |
| 2    | Generar/Extender dimensión de tiempo    | SQL           | `transform/generate_dwa_time.sql`       | DWA_Time   |
| 3    | Transformar TMP_ a modelo dimensional   | SQL           | `transform/transform_tmp_to_dwa.sql`    | DWA_       |
| 4    | Asignar claves temporales a hechos      | SQL           | `transform/assign_date_keys_to_facts.sql`| DWA_      |
| 5    | Aplicar lógica SCD Tipo 2               | Python        | `transform/update_dwm_from_dwa.py`      | DWM_       |
| 6    | Validar calidad y registrar issues      | Python        | `transform/validate_quality.py`         | DQM_       |
| 7    | Generar productos analíticos            | SQL           | `transform/generate_data_products.sql`  | DP_        |
| 8    | Registrar metadata y linaje             | SQL           | `transform/register_metadata.sql`       | MET_       |

---

## 🧬 Trazabilidad completa por UUID

Cada fila de negocio relevante cuenta con un campo `uuid` generado en la ingesta inicial. Este identificador se propaga a lo largo de todas las capas (`DWA_`, `DWM_`, `DP_`, `DQM_`, `MET_`) para garantizar un linaje total desde el `.csv` de origen hasta los dashboards.

---

## 📊 Visualización

Se puede conectar directamente **Power BI Desktop** o **Metabase** a `db/dwa.sqlite` y crear dashboards a partir de las tablas `DP_` o explorar la metadata en `MET_`.

---

## 📄 Licencia

MIT License. Uso libre con atribución.