# PBI_fict

Implementación de búsqueda en proximidad usando permutantes (PBI) y permutantes con ficticios (PBIFP) para espacios métricos con vectores.

## Prerequisitos

EndeavourOS / Arch Linux:

```bash
sudo pacman -Syu
sudo pacman -S base-devel gcc make git gnuplot ghostscript imagemagick bc
```

Ubuntu / Debian:

```bash
sudo apt update
sudo apt install -y build-essential gcc make git gnuplot ghostscript imagemagick bc
```

- **gcc** — compilador C (C11)
- **make** — sistema de compilación
- **gnuplot** — generación de gráficos EPS/PDF
- **ghostscript** (`ps2pdf`) — conversión EPS → PDF
- **imagemagick** (`convert`) — conversión EPS → PNG
- **bc** — cálculos en scripts bash

## Estructura del proyecto

```
permutants/
├── Makefile                            # Compilación de binarios (gcc -std=c11)
├── README.md
│
├── src/                                # Código fuente
│   ├── basics.c                        # Funciones auxiliares
│   ├── basics.h
│   ├── build.c                         # Punto de entrada: construcción de índices
│   ├── query.c                         # Punto de entrada: consultas sobre índices
│   ├── trie.c                          # Implementación de trie
│   ├── trie.h
│   ├── compare_knn_results.py          # Comparar resultados KNN (precisión)
│   ├── compare_knn_results_byline.py   # Comparación línea a línea
│   ├── compare_knn_results_bypercentaje.py  # Comparación por porcentaje
│   ├── showcontent.py                  # Visualizar contenido de archivos
│   ├── showpbi.py                      # Visualizar índice PBI
│   ├── showpbifp.py                    # Visualizar índice PBIFP
│   ├── db/                             # Manejo de bases de datos
│   │   ├── documents/
│   │   │   ├── documents.c
│   │   │   └── documents.h
│   │   ├── strings/
│   │   │   ├── strings.c
│   │   │   └── strings.h
│   │   └── vectors/
│   │       ├── vectors.c               # Lectura/escritura de datasets de vectores
│   │       └── vectors.h
│   ├── include/                        # Utilidades compartidas
│   │   ├── main.c
│   │   ├── pq                          # Cola de prioridad (archivo)
│   │   ├── priorityQueue.c
│   │   └── priorityQueue.h
│   └── index/                          # Implementaciones de índices
│       ├── index.h
│       ├── pbi/
│       │   ├── pbi.c                   # Implementación PBI
│       │   └── pbi.h
│       └── pbifp/
│           ├── pbifp.c                 # Implementación PBIFP (con ficticios)
│           └── pbifp.h
│
├── build/                              # Binarios compilados (generado por make)
│   ├── documents/                      # (vacío)
│   ├── strings/                        # (vacío)
│   └── vectors/
│       ├── build-aesa-vectors          # Construir índice AESA
│       ├── build-pbi-vectors           # Construir índice PBI
│       ├── build-pbifp-vectors         # Construir índice PBIFP
│       ├── query-aesa-vectors          # Consultar índice AESA (exacto)
│       ├── query-pbi-vectors           # Consultar índice PBI
│       └── query-pbifp-vectors         # Consultar índice PBIFP
│
├── data/                               # Datos de entrada
│   ├── binary/                         # Datasets en formato binario
│   │   ├── strings/
│   │   └── vectors/                    # Ej: 10000v_128d.bin, 20000v_256d.bin
│   ├── generator/                      # Generadores de datos y queries
│   │   ├── strings/
│   │   │   ├── Makefile
│   │   │   ├── genqueries.c
│   │   │   └── objstrings.c
│   │   └── vectors/
│   │       ├── Makefile
│   │       ├── convertcoords.c         # Convertir coordenadas texto → binario
│   │       ├── genqueries.c            # Generar archivo de queries
│   │       └── uniform/
│   │           ├── Makefile
│   │           └── gencoords.c         # Generar vectores uniformes
│   └── raw/                            # Datos en texto plano
│       ├── strings/
│       │   ├── wordlist
│       │   └── shuffled_wordlist
│       └── vectors/                    # Ej: 10000v_128d.dat, 10000v_256d.dat
│
├── scripts/                            # Scripts de automatización
│   ├── documents/                      # (vacío)
│   ├── strings/
│   │   ├── build_pbi.sh
│   │   └── build_pbifp.sh
│   └── vectors/
│       ├── run_experiments.sh          # Ejecutar experimentos completos
│       ├── generate_plots.sh           # Generar gráficos desde resultados
│       ├── build_pbi.sh                # Construir índice PBI
│       ├── build_pbifp.sh              # Construir índice PBIFP
│       ├── query_pbi.sh                # Consultar índice PBI
│       ├── query_pbifp.sh              # Consultar índice PBIFP
│       ├── compare_results.sh          # Comparar resultados
│       ├── analyze_results.sh          # Analizar resultados
│       ├── generate_vectors_dbs.sh     # Generar datasets de vectores
│       ├── convert_vectors_dbs.sh      # Convertir datasets a binario
│       ├── check_environment.sh        # Verificar dependencias del sistema
│       ├── clean.sh                    # Limpiar archivos generados
│       ├── help.sh                     # Mostrar ayuda de scripts
│       ├── quick_example.sh            # Ejemplo rápido de uso
│       ├── quickstart.sh              # Inicio rápido
│       └── test_run.sh                 # Prueba de ejecución
│
├── index/                              # Índices generados (generado en ejecución)
│   ├── documents/                      # (vacío)
│   ├── strings/
│   │   ├── aesa/
│   │   ├── fqt/
│   │   ├── pbi/
│   │   └── pbifp/
│   └── vectors/
│       ├── aesa/                       # Índices AESA (referencia exacta)
│       ├── fqt/
│       ├── pbi/                        # Índices PBI generados
│       └── pbifp/                      # Índices PBIFP generados
│
├── queries/                            # Archivos de queries (generado)
│   ├── strings/
│   │   ├── nn/
│   │   └── range/
│   └── vectors/
│       ├── nn/                         # Queries nearest-neighbor
│       └── range/                      # Queries por rango
│
├── output/                             # Salidas de consultas (generado)
│   └── vectors/
│       ├── aesa/                       # Salida AESA (respuesta exacta)
│       ├── pbi/                        # Salida PBI
│       └── pbifp/                      # Salida PBIFP
│
├── results/                            # Resultados de experimentos (generado)
│   └── vectors/
│       └── experiment_<D>d_<P>p_<TIMESTAMP>/
│           ├── summary.txt             # Resumen del experimento
│           ├── experiment.log          # Log de ejecución
│           ├── comparisons/
│           │   ├── pbi_precision_avg.csv       # Precisión PBI promediada
│           │   └── pbifp_precision_avg.csv     # Precisión PBIFP promediada
│           ├── reports/
│           │   └── summary_report.txt
│           ├── plots/
│           │   ├── graficos/                   # Gráficos EPS/PNG/PDF generados
│           │   │   ├── pbi_precision_<D>d_<P>p.{eps,png,pdf}
│           │   │   ├── pbifp_precision_<D>d_<P>p.{eps,png,pdf}
│           │   │   ├── unified_pbi_pbifp_<D>d_<P>p.{eps,png,pdf}
│           │   │   ├── unified_zoom_0_10_<D>d_<P>p.{eps,png,pdf}
│           │   │   ├── pbi_zoom_0_10_<D>d_<P>p.{eps,png,pdf}
│           │   │   ├── pbifp_zoom_0_10_<D>d_<P>p.{eps,png,pdf}
│           │   │   ├── pbifp_improvement_all_<D>d_<P>p.{eps,png,pdf}
│           │   │   ├── pbifp_improvement_best_<D>d_<P>p.{eps,png,pdf}
│           │   │   └── pbi_vs_pbifp_<D>d_<P>p.{eps,png,pdf}
│           │   ├── comparison_table.txt        # Tabla comparativa
│           │   ├── graphics_report.txt
│           │   ├── pbi_precision.data          # Datos PBI para gnuplot
│           │   ├── pbifp_precision_*f.data     # Datos PBIFP por config. ficticia
│           │   ├── improvement_*f.data         # Datos de mejora por config.
│           │   ├── pbifp_improvement_all.data
│           │   ├── pbifp_improvement_best.data
│           │   ├── pbifp_best.data
│           │   └── *.gnu                       # Scripts gnuplot generados
│           ├── exact/                          # Resultados búsqueda exacta
│           ├── pbi/                            # Resultados PBI por instancia
│           ├── pbifp/                          # Resultados PBIFP por instancia
│           ├── queries/                        # Queries usadas
│           └── instance_*/                     # Resultados por instancia (1-5)
│
└── graphics/                           # Gráficos adicionales y configuraciones
    ├── documents/                      # (vacío)
    ├── strings/                        # (vacío)
    └── vectors/
        ├── pbifp.gnu                   # Script gnuplot de referencia
        ├── pbi_vs_aesa_k10.gnu         # PBI vs AESA
        ├── best_configurations.txt     # Mejores configuraciones encontradas
        ├── pbi_vs_pbifp_comparison.txt # Comparación PBI vs PBIFP
        ├── pbifp_*_distance.data       # Datos de distancia
        ├── pbifp_*_frecuency.data      # Datos de frecuencia
        └── *.eps, *.pdf                # Gráficos generados
```

## Compilación

```bash
# Compilar solo los binarios de vectores
make all-vectors

# Compilar todo (vectores, strings, documents)
make all

# Limpiar y recompilar
make rebuild

# Ver ayuda del Makefile
make help
```

Binarios generados en `build/vectors/`:
- `build-pbi-vectors` — construir índice PBI
- `query-pbi-vectors` — consultar índice PBI
- `build-pbifp-vectors` — construir índice PBIFP
- `query-pbifp-vectors` — consultar índice PBIFP

## Generación de datos

### Generar dataset de vectores uniformes

```bash
cd data/generator/vectors/uniform
make
# gencoords <n_vectores> <dimensiones> > archivo.txt
./gencoords 10000 128 > 10000v_128d.txt
```

### Convertir a formato binario

```bash
cd data/generator/vectors
make
# convertcoords <archivo_texto> <archivo_binario> <n_vectores> <dimensiones>
./convertcoords uniform/10000v_128d.txt ../../binary/vectors/10000v_128d.bin 10000 128
```

### Generar queries

```bash
cd data/generator/vectors
# genqueries <dataset_binario> <n_queries> <n_vectores> <dimensiones> > queries.bin
./genqueries ../../binary/vectors/10000v_128d.bin 100 10000 128 > ../../binary/vectors/queries_10000v_128d.bin
```

## Ejecución de experimentos

El script `run_experiments.sh` automatiza todo el flujo: construye índices, ejecuta queries con distintos porcentajes de revisión, compara contra respuesta exacta y genera CSVs de precisión.

### Uso básico

```bash
# Con valores por defecto (dataset 10000v_128d.bin, permutantes = dimensiones)
./scripts/vectors/run_experiments.sh

# Especificando dataset y permutantes
./scripts/vectors/run_experiments.sh -d 10000v_128d.bin -m 128

# Configuración completa
./scripts/vectors/run_experiments.sh \
  -d 10000v_128d.bin \
  -m 128 \
  -k 5 \
  -n 100 \
  -p "1 2 3 4 5 10 15 20 30 50" \
  -f "1 2 3 4 5 6 8"
```

### Opciones

| Opción | Descripción | Default |
|--------|-------------|---------|
| `-d` | Dataset binario (en `data/binary/vectors/`) | `10000v_128d.bin` |
| `-m` | Número de permutantes | dimensiones del dataset |
| `-k` | Valor de K para K-NN | `5` |
| `-n` | Número de queries | `100` |
| `-p` | Porcentajes de revisión | `"1 2 3 4 5 ... 15 20"` |
| `-f` | Valores ficticios para PBIFP | `"1 2 3 4 5"` |
| `-o` | Directorio de salida | `results/vectors/experiment_<DIM>d_<PERM>p_<TIMESTAMP>` |
| `-s` | Ejecutar solo 1 instancia (en lugar de 5) | desactivado |

## Generación de gráficos

Después de ejecutar un experimento, generar los gráficos con:

```bash
./scripts/vectors/generate_plots.sh results/vectors/experiment_128d_128p_20251126_025431
```

### Gráficos generados

Salida en `results/vectors/experiment_*/plots/graficos/`:

| Archivo | Descripción |
|---------|-------------|
| `pbi_precision_<D>d_<P>p.eps` | Precisión PBI vs % revisión |
| `pbifp_precision_<D>d_<P>p.eps` | Precisión PBIFP (todas las config.) + PBI |
| `unified_pbi_pbifp_<D>d_<P>p.eps` | PBI vs PBIFP unificado |
| `unified_zoom_0_10_<D>d_<P>p.eps` | Zoom 0-10% del unificado |
| `pbi_zoom_0_10_<D>d_<P>p.eps` | Zoom 0-10% solo PBI |
| `pbifp_improvement_all_<D>d_<P>p.eps` | Mejora de PBIFP sobre PBI (todas) |
| `pbifp_improvement_best_<D>d_<P>p.eps` | Mejora de PBIFP sobre PBI (mejor) |
| `pbi_vs_pbifp_<D>d_<P>p.eps` | Comparación directa PBI vs mejor PBIFP |
| `pbifp_zoom_0_10_<D>d_<P>p.eps` | Zoom 0-10% PBIFP |

Cada `.eps` se convierte automáticamente a `.png` y `.pdf`.

## Ubicación de resultados

Cada experimento genera un directorio con la siguiente estructura:

```
results/vectors/experiment_128d_128p_20251126_025431/
├── summary.txt                          # Resumen del experimento
├── comparisons/
│   ├── pbi_precision_avg.csv            # Precisión PBI promediada
│   └── pbifp_precision_avg.csv          # Precisión PBIFP promediada
├── plots/
│   ├── graficos/                        # Gráficos EPS/PNG/PDF
│   ├── comparison_table.txt             # Tabla comparativa texto
│   ├── pbi_precision.data               # Datos para gnuplot
│   ├── pbifp_precision_*f.data          # Datos PBIFP por config.
│   └── *.gnu                            # Scripts gnuplot generados
└── instance_*/                          # Resultados por instancia
```

## Ejecución directa de binarios (sin script)

Los binarios se pueden usar directamente sin el script de automatización.

### Construir índice PBI

```bash
# build-pbi-vectors <dataset> <índice_salida> <n_vectores> <n_permutantes>
build/vectors/build-pbi-vectors data/binary/vectors/10000v_128d.bin index/vectors/pbi/10000v_128d_128p.idx 10000 128
```

### Construir índice PBIFP

```bash
# build-pbifp-vectors <dataset> <índice_salida> <n_vectores> <n_permutantes> <n_ficticios> <método>
# método: 0 o 1
build/vectors/build-pbifp-vectors data/binary/vectors/10000v_128d.bin index/vectors/pbifp/10000v_128d_128p_4f.idx 10000 128 4 0
```

### Consultar índice PBI

```bash
# query-pbi-vectors <índice> <porcentaje_revisión> < <archivo_queries> > <salida>
# porcentaje_revisión: valor decimal (0.05 = 5%)
build/vectors/query-pbi-vectors index/vectors/pbi/10000v_128d_128p.idx 0.05 < queries/vectors/nn/queries_1.bin > output/pbi_5p.txt
```

### Consultar índice PBIFP

```bash
# query-pbifp-vectors <índice> <porcentaje_revisión> < <archivo_queries> > <salida>
build/vectors/query-pbifp-vectors index/vectors/pbifp/10000v_128d_128p_4f.idx 0.05 < queries/vectors/nn/queries_1.bin > output/pbifp_5p_4f.txt
```

### Comparar resultados con respuesta exacta (AESA)

```bash
# compare_knn_results.py <resultado_exacto> <resultado_aproximado> <k>
python src/compare_knn_results.py output/vectors/aesa/128d/128d_1 output/pbi_5p.txt 5
```

Esto imprime el porcentaje de recuperación (precisión) comparando la salida aproximada contra la exacta.

## Flujo de trabajo completo (ejemplo)

```bash
# 1. Compilar
make all-vectors

# 2. Ejecutar experimento
./scripts/vectors/run_experiments.sh -d 10000v_128d.bin -m 128

# 3. Generar gráficos (usar la ruta que imprime el paso 2)
./scripts/vectors/generate_plots.sh results/vectors/experiment_128d_128p_YYYYMMDD_HHMMSS

# 4. Ver gráficos
eog results/vectors/experiment_128d_128p_YYYYMMDD_HHMMSS/plots/graficos/*.png
```

## Notas importantes

- Para **reconstruir índices PBIFP** con otra configuración, borrar los índices existentes:
  ```bash
  rm -rf index/vectors/pbifp/*
  ```
- El método de construcción PBIFP se pasa como argumento (0 o 1) en `build-pbifp-vectors`.
- La línea **PBI** se dibuja al final en los gráficos combinados para quedar encima de las curvas PBIFP.
- Los gráficos EPS usan `set terminal postscript eps enhanced color` para generar en color.
- El gráfico de mejoras (`improvement_all`) limita el eje Y positivo a un máximo de 3%.
