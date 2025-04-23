![Universidad Austral](logo-md-austral-1.png)
### Universidad Austral 
### Facultad de Ingeniería
### MCD 2024/2025
### Introducción a Dataware Housing
## TPG01 - Flujo DWA

- CANCELAS, Martín
- NICOLAU, Jorge
- VERDEJO, Manuel
---
## dwa-lite - Solución Liviana de Data Warehouse Automation (DWA)

Este repositorio implementa una solución open source y ligera de Data Warehouse Automation (DWA) utilizando herramientas visuales y de fácil despliegue. El objetivo es desarrollar un flujo end-to-end que permita la ingesta, control de calidad, enriquecimiento, almacenamiento y visualización de datos partiendo de archivos .CSV. La visualización final se realiza mediante Power BI Desktop sobre una base de datos SQLite.

## Herramientas utilizadas

| Herramienta       | Función                                                                 |
|-------------------|-------------------------------------------------------------------------|
| KNIME             | ETL visual, control de calidad, enriquecimiento, carga inicial y actualización de datos |
| SQLite            | Almacén físico con estructura en capas: TMP_, DWA_, DWM_, DQM_, MET_, DP_ |
| Power BI Desktop  | Dashboards interactivos para productos de datos (DP_), calidad (DQM_) y memoria (DWM_) |
| Metabase          | Catálogo vivo y documentado del modelo de datos (tablas y campos)       |

## Estructura del repositorio

```plaintext
dwa-lite/
├── data/                     # Archivos CSV de entrada (ingesta inicial y de novedades)
│   ├── ingesta1/
│   └── ingesta2/
├── sqlite/                   # Base de datos SQLite con todas las capas
│   └── dwa.sqlite
├── knime-flows/              # Flujos .knwf de KNIME (ETL, actualización, productos)
│   ├── carga-ingesta1.knwf
│   ├── actualizacion-ingesta2.knwf
│   └── generar-productos.knwf
├── dashboards/
│   └── powerbi/              # Archivo Power BI Desktop (.pbix) con los dashboards
│       └── dwa-dashboard.pbix
├── metabase/                 # Archivo JSON del catálogo de metadata para importar
│   └── metamodelo_documentado.json
├── .github/
│   └── workflows/            # Automatización del flujo ETL con GitHub Actions (opcional)
│       └── ejecutar-knime.yml
└── README.md                 # Este archivo
```

## Flujo general del DWA

1. Ingesta de CSVs hacia tablas TMP_ en SQLite
2. Validación y control de calidad registrados en DQM_
3. Transformación y enriquecimiento en DWA_ y DWM_
4. Generación de historial completo (SCD tipo 2) en DWM_
5. Documentación del modelo en MET_ y visualización en Metabase
6. Generación de productos de datos en DP_
7. Visualización final en Power BI Desktop mediante dashboards .pbix

## Automatización (opcional)

Si se desea automatizar el proceso, se incluye un workflow para GitHub Actions que:
- Instala KNIME en un runner Ubuntu
- Ejecuta el flujo definido en modo headless
- Puede activarse al hacer push de nuevos archivos CSV

## Conexión Power BI con SQLite

Para conectar Power BI Desktop con SQLite:
1. Instalar el controlador ODBC de SQLite: https://www.ch-werner.de/sqliteodbc/
2. Crear una conexión ODBC apuntando al archivo `dwa.sqlite`
3. En Power BI: Obtener datos > ODBC > Seleccionar DSN configurado
4. Importar tablas DP_, DWM_, DQM_ y otras de interés
5. Crear relaciones, visuales y filtros según los productos de datos generados

## Requisitos

- KNIME Analytics Platform
- SQLiteStudio (opcional para explorar la base de datos)
- Power BI Desktop (Windows)
- Metabase
- Python 3 (solo si se automatiza Superset o se utilizan scripts auxiliares)

## Próximos pasos

- Mejorar el control de calidad (DQM_) con reglas parametrizadas
- Agregar pruebas de validación en KNIME o utilizando Great Expectations
- Extender los dashboards con filtros por período, país, entre otros

## Licencia

Este proyecto está publicado bajo la licencia MIT.