![Universidad Austral](logo-md-austral-1.png)
### Universidad Austral - Facultad de Ingeniería
### MCD 2024/2025 - Introducción a Dataware Housing
## TPG01 - Flujo DWA3

- [CANCELAS, Martín](https://www.linkedin.com/in/mart%C3%ADn-cancelas-2313a1154/)
- [NICOLAU, Jorge](https://jorgenicolau.ar/)
---
# 🧠 DWA Lite – Solución Liviana de Data Warehouse Automation (DWA) con SQLite

Este proyecto implementa una solución lightweight de **Data Warehouse Automation (DWA)** utilizando SQLite como motor, Python para ingesta y control de calidad, SQL para transformaciones y generación de productos analíticos, y Power BI o Metabase para visualización. Todo puede ejecutarse localmente y en modo *headless*.

Esta es la solución propuesta al [Trabajo Práctico TPGO1 de Introducción al Data Warehousing](MCD_2025_IDW-TPG01_Flujo_DWA-1e.md).

---

## 🚀 Objetivo

Automatizar de punta a punta el flujo de un DWA académico, incluyendo:

- Carga de datos desde archivos CSV (`TMP_`)
- Limpieza inicial de datos cargados (`STG_`)
- Transformación y normalización (`DWA_`)
- Versionado histórico con Slowly Changing Dimension Type 2 (`DWM_`)
- Control de calidad de datos (`DQM_`)
- Generación de productos analíticos (`DP_`)
- Trazabilidad y metadata (`MET_`)

---

## 🧱 Estructura del proyecto

```
dwa-lite/
├── dashboards/                      # Archivos de Dashboards Power BI
├── data/                            # CSVs de entrada (Ingesta1, Ingesta2)
├── db/                              # Base SQLite (dwa.sqlite)
├── models/                          # Scripts SQL de creación de capas
│   ├── dp                           # Creacion Tablas Data Product (DP_)
│   ├── dqm                          # Creacion Tablas Data Quality Mart (DQM_)
│   ├── dwa                          # Creacion Tablas Data Warehouse (DWA_)
│   ├── dwm                          # Creacion Tablas Memoria SCD2 (DWM_)
│   ├── met                          # Creacion Tablas Metadata (MET_) y diccionarios
│   ├── tmp                          # Creacion Tablas Temporales (TMP_)
│   └── stg                          # Creacion Tablas de Staging (STG_)
├── transform/                       # Scripts SQL y Python del pipeline
│   ├── sql                          
│   │   └── *.sql                    # Scripts de transformación y carga
│   └── *.py                         # Scripts de procesamiento (ingesta, calidad, etc.)
└── README.md                        # Este archivo
```

---

## ✅ Requisitos

- Python 3.10+
- SQLite 3.x
- Power BI Desktop (opcional)
- DBgate (opcional)

Instalación rápida de dependencias:
```bash
pip install pandas
```
Creación inicial de modelos (una única vez):
```cmd
cd transform
python 99_create_tables.py
```
Limpieza de tablas (para ejecutar el flujo completo):
```cmd
cd transform
python 98_drop_tables.py
```

---

## 💻 Ejecución local

Carga inicial de `data/ingesta1`
```cmd
cd transform
python 00a_run_start_pipeline.py
```

Carga [incremetnal](INCREMENTAL.md) de `data/ingesta2`
```cmd
cd transform
python 00b_run_update_pipeline.py
```

---

## ⚙️ Ejecución Headless (modo automático y sin entorno gráfico)

El proyecto puede ejecutarse de punta a punta en modo completamente automatizado, sin entorno gráfico ni herramientas interactivas, mediante los scripts alojados en la carpeta `transform/`: antes de iniciar la carga es necesario posicionarse en la carpeta

| Paso | Propósito                               | Herramienta   | Script/Artefacto                        | Capa       |
|------|-----------------------------------------|---------------|-----------------------------------------|------------|
| 0.a  | Pipeline completo inicial               | Python        | `00a_run_start_pipeline.py`             | Todas      |
| 0.b  | Pipeline completo incremental           | Python        | `00b_run_update_pipeline.py`            | Todas      |
| 1.a  | Cargar inicial CSV en SQLite            | Python        | `10a_load_new_csv_to_tmp.py`            | TMP_       |
| 1.b  | Cargar [incremetnal](INCREMENTAL.md) CSV en SQLite        | Python        | `10b_load_update_csv_to_tmp.py`          | TMP_       |
| 1.m  | Metadata y linaje para TMP_             | Python        | `10m_register_tmp_metadata.py`          | MET_       |
| 1.q  | Estadísticas de calidad para TMP_       | Python        | `10q_tmp_quality_check.py`              | DQM_       |
| 1.1  | Generación de capa de staging           | Python        | `12_copy_tmp_to_stg.py`                 | STG_       |
| 1.2  | Limpieza de datos en  staging           | Python        | `13_clean_stg.py`                       | STG_       |
| 1.5  | Generar/Extender dimensión de tiempo    | Python+SQL    | `15_generate_dwa_time.sql`              | DWA        |
| 2    | Transformar STG_ a modelo dimensional   | Python+SQL    | `20_transform_stg_to_dwa.py`            | DWA_       |
| 2.5  | Asignar claves temporales a hechos      | Python+SQL    | `25_assign_date_keys_to_facts.py`       | DWA_       |
| 2.m  | Metadata y linaje  para DWA_            | Python        | `25m_register_dwa_metadata.py`          | MET_       |
| 2.q  | Estadísticas de calidad para DWA_       | Python        | `25q_dwa_quality_check.py`              | DQM_       |
| 3    | Aplicar lógica SCD Tipo 2               | Python        | `30_update_dwm_from_dwa.py`             | DWM_       |
| 3.m  | Metadata y linaje  para DWM_            | Python        | `30m_register_dwm_metadata.py`          | MET_       |
| 3.q  | Estadísticas de calidad para DWM_       | Python        | `30q_dwm_quality_check.py`              | DQM_       |
| 5    | Generar productos analíticos            | Python+SQL    | `50_generate_data_products.py`          | DP_        |
| 5.m  | Metadata y linaje  para DP_             | Python        | `50m_register_dp_metadata.py`           | MET_       |
| 5.q  | Estadísticas de calidad para DP_        | Python        | `50q_dp_quality_check.py`               | DQM_       |

---

## 🧬 Trazabilidad completa por UUID

Cada fila de negocio relevante cuenta con un campo `uuid` generado en la ingesta inicial. Este identificador se propaga a lo largo de todas las capas (`DWA_`, `DWM_`, `DP_`, `DQM_`, `MET_`) para garantizar un linaje total desde el `.csv` de origen hasta los dashboards.

---

## 📊 Visualización

Se puede conectar directamente **Power BI Desktop** a `db/dwa.sqlite` y crear dashboards a partir de las tablas `DP_` o explorar la metadata en `MET_`.

## 📦 Productos de Datos Generados (DP_)

Al final del pipeline se generan seis productos de datos que resumen información clave para análisis de negocio. Estas tablas se pueden consumir directamente desde Power BI, Metabase u otra herramienta de visualización conectada a `db/dwa.sqlite`.

### 🧾 Descripción de cada producto

| Tabla                        | Descripción                                                                 |
|-----------------------------|-----------------------------------------------------------------------------|
| `DP_SalesByProductMonth`    | Ventas agregadas por producto y mes calendario (año, mes, total vendido).  |
| `DP_TopCustomersByRevenue`  | Ranking de clientes por facturación acumulada.                             |
| `DP_RegionalSalesByQuarter` | Ventas totales por región geográfica y trimestre calendario.               |
| `DP_EmployeePerformance`    | Monto total vendido por empleado por año (rendimiento comercial).          |
| `DP_ProductReturns`         | Órdenes con descuentos como proxy de devoluciones o promociones.           |

### 🧩 Ejemplo de visualizaciones posibles

- Ranking de vendedores por su facturación y facturación media.
- Evolución de unidades y facturación a lo largo del período.
- Países de origen que representan la mayor pérdida de facturación por descuentos o devoluciones.
- Participación de mercado del origen y destino de las unidades vendidas.
- Principales clientes por país, nivel de ingreso y costos de transporte.

> Todos estos DP_ están trazados hasta el origen con `uuid`, permitiendo
> rastrear cada métrica hasta los registros originales de ingreso (`.csv`).

---

## 📄 Licencia

MIT License. Uso libre con atribución.
