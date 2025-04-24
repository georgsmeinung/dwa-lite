## 🔄 Flujo de Actualización Incremental (novedades desde Ingesta2)

El proyecto soporta actualizaciones incrementales mediante la carpeta `data/ingesta2/`, que contiene archivos de novedades con posibles nuevas filas o actualizaciones respecto a `ingesta1`. Este flujo se ejecuta preservando la trazabilidad y el historial mediante SCD Tipo 2.

### ✅ Características

- No borra ni reemplaza datos existentes.
- Agrega nuevas filas a `TMP_` desde archivos con nombres distintos.
- Propaga cambios hacia `DWA_` y `DWM_` con preservación de historial.
- Vuelve a calcular productos analíticos (`DP_`) afectados.
- Registra ejecución y linaje en la capa `MET_`.

### 📂 Nombres de archivos esperados en `data/ingesta2/`

| Archivo                         | Tabla destino  |
|---------------------------------|----------------|
| `customers - novedades.csv`     | `TMP_Customers`|
| `orders - novedades.csv`        | `TMP_Orders`   |
| `order_details - novedades.csv` | `TMP_Order_Details` |

### ⚙️ Script principal

El flujo incremental está orquestado por:

```
run_incremental_pipeline.cmd
```

Este script ejecuta en orden:

1. `11_update_csv_to_tmp.py` – carga novedades a tablas `TMP_`
2. `15_generate_dwa_time.sql` – extiende la tabla de tiempo
3. `20_transform_tmp_to_dwa.sql` – transforma nuevos datos a `DWA_`
4. `25_assign_date_keys_to_facts.sql` – actualiza claves de tiempo
5. `30_update_dwm_from_dwa.py` – aplica SCD Tipo 2 en `DWM_`
6. `40_validate_quality.py` – valida calidad de los datos incrementales
7. `50_generate_data_products.sql` – recalcula productos analíticos
8. `60_register_metadata.sql` – registra linaje y ejecución

> Este flujo puede ejecutarse tantas veces como se necesiten nuevas ingestas
> sin dañar la integridad del DWA ni sobrescribir versiones anteriores.
