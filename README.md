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

Este repositorio implementa una solución open source y ligera de Data Warehouse Automation (DWA) utilizando herramientas visuales y de fácil despliegue. El objetivo es desarrollar un flujo end-to-end que permita la ingesta, control de calidad, enriquecimiento, almacenamiento y visualización de datos partiendo de archivos .CSV.

## Herramientas utilizadas

| Herramienta       | Función                                                                 |
|-------------------|-------------------------------------------------------------------------|
| KNIME             | ETL visual, control de calidad, enriquecimiento, carga inicial y actualización de datos |
| SQLite            | Almacén físico con estructura en capas: TMP_, DWA_, DWM_, DQM_, MET_, DP_ |
| Metabase          | Catálogo vivo y documentado del modelo de datos (tablas y campos)       |
| Apache Superset   | Dashboards interactivos para datos finales (DP_), calidad (DQM_) y memoria (DWM_) |

## Estructura del repositorio

```plaintext
dwa-light/
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
│   └── superset/             # Configuraciones y assets de Superset (JSON opcional)
├── metabase/                 # Archivo JSON del catálogo de metadata para importar
│   └── metamodelo_documentado.json
├── .github/
│   └── workflows/            # Automatización del flujo ETL con GitHub Actions (opcional)
│       └── ejecutar-knime.yml
├── README.md                 # Este archivo
```

## Flujo general del DWA

1. Ingesta de CSVs hacia tablas TMP_ en SQLite
2. Validación y control de calidad registrados en DQM_
3. Transformación y enriquecimiento en DWA_ y DWM_
4. Generación de historial completo (SCD tipo 2) en DWM_
5. Documentación del modelo en MET_ y visualización en Metabase
6. Generación de productos de datos en DP_
7. Visualización final en dashboards con Superset

## Automatización (opcional)

Si se desea automatizar el proceso, se incluye un workflow para GitHub Actions que:
- Instala KNIME en un runner Ubuntu
- Ejecuta el flujo definido en modo headless
- Puede activarse al hacer push de nuevos archivos CSV

## Requisitos

- KNIME Analytics Platform
- DBeaver (opcional para explorar la base de datos)
- Apache Superset
- Metabase
- Python 3 (solo si se automatiza Superset o se utilizan scripts auxiliares)

## Licencia

Este proyecto está publicado bajo la licencia MIT.
