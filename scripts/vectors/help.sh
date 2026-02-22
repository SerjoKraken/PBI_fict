#!/bin/bash

###############################################################################
# Script de ayuda para ejecutar experimentos
###############################################################################

cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════╗
║                    SISTEMA DE EXPERIMENTOS AUTOMÁTICOS                ║
║                           PBI / PBIFP Indexing                         ║
╚════════════════════════════════════════════════════════════════════════╝

SCRIPTS DISPONIBLES:
─────────────────────────────────────────────────────────────────────────

1. run_all_experiments.sh
   ├─ Ejecuta TODO el pipeline de experimentos automáticamente
   ├─ Compila, construye índices, ejecuta consultas y compara
   └─ Uso: ./run_all_experiments.sh

2. analyze_results.sh
   ├─ Analiza los resultados de los experimentos
   ├─ Genera tablas comparativas y datos para gráficos
   └─ Uso: ./analyze_results.sh

3. build_pbi.sh
   ├─ Construye solo índices PBI
   └─ Uso: ./build_pbi.sh <EXECUTABLE> <DB> <INDEX-DIR> <SIZE> [-p "128 256"]

4. build_pbifp.sh
   ├─ Construye solo índices PBIFP
   └─ Uso: ./build_pbifp.sh <EXECUTABLE> <DB> <INDEX-DIR> <SIZE>
           [-p "128 256"] [-f "0 4 8 12"] [-m "0 1 2"]

5. query_pbi.sh / query_pbifp.sh
   ├─ Ejecuta consultas sobre índices específicos
   └─ Uso: ./query_pbi.sh <EXECUTABLE> <INDEX-FILE> <OUTPUT-DIR> <QUERY-FILES...>

6. compare_results.sh
   ├─ Compara resultados exactos vs aproximados
   └─ Uso: ./compare_results.sh <EXACT-DIR> <INEXACT-DIR> <DIMS> <K>

─────────────────────────────────────────────────────────────────────────
FLUJO DE TRABAJO TÍPICO:
─────────────────────────────────────────────────────────────────────────

OPCIÓN A - Automático (Recomendado):
  
  1. Ejecutar todo:
     $ ./run_all_experiments.sh
  
  2. Analizar resultados:
     $ ./analyze_results.sh
  
  3. Ver reportes en:
     - results/vectors/comparisons/
     - graphics/vectors/

OPCIÓN B - Manual (Control granular):

  1. Compilar:
     $ cd ../../
     $ make

  2. Construir índices PBI:
     $ ./build_pbi.sh \
         ../../build/vectors/build-pbi-vectors \
         ../../data/binary/vectors/10000v_128d.bin \
         ../../index/vectors/pbi \
         10000 \
         -p "128 256 512"

  3. Construir índices PBIFP:
     $ ./build_pbifp.sh \
         ../../build/vectors/build-pbifp-vectors \
         ../../data/binary/vectors/10000v_128d.bin \
         ../../index/vectors/pbifp \
         10000 \
         -p "128 256" \
         -f "0 4 8 12 16 20" \
         -m "0 1 2"

  4. Ejecutar consultas:
     $ ./query_pbifp.sh \
         ../../build/vectors/query-pbifp-vectors \
         ../../index/vectors/pbifp/pbifp_128p_8f_1m_10000v_128d.bin \
         ../../output/vectors/pbifp \
         ../../queries/vectors/nn/*.txt

  5. Comparar resultados:
     $ ./compare_results.sh \
         ../../output/vectors/exact \
         ../../output/vectors/pbifp \
         128 \
         10

─────────────────────────────────────────────────────────────────────────
PARÁMETROS DE CONFIGURACIÓN:
─────────────────────────────────────────────────────────────────────────

PBIFP - Métodos de generación de distancias ficticias:
  0 = Por Distancia    (distance-based)
  1 = Por Frecuencia   (frequency-based)
  2 = Por Media        (mean-based)

PBI - Permutantes:
  Valores comunes: 128, 256, 512, 1024

PBIFP - Ficticios:
  Valores comunes: 0, 4, 8, 12, 16, 20, 24, 28, 32

Porcentajes de revisión:
  Valores: 0.01, 0.02, 0.05, 0.10, 0.15, 0.20, 0.30, 0.40, 0.50

─────────────────────────────────────────────────────────────────────────
ESTRUCTURA DE DIRECTORIOS:
─────────────────────────────────────────────────────────────────────────

permutants/
├── data/
│   └── binary/vectors/           # Datasets de entrada
├── queries/vectors/              # Archivos de consultas
├── index/vectors/
│   ├── pbi/                      # Índices PBI
│   └── pbifp/                    # Índices PBIFP
├── output/vectors/
│   ├── pbi/                      # Resultados de consultas PBI
│   ├── pbifp/                    # Resultados de consultas PBIFP
│   └── exact/                    # Resultados exactos (ground truth)
├── results/vectors/
│   ├── comparisons/              # CSVs de comparación
│   ├── build_pbi.log             # Logs de construcción
│   └── build_pbifp.log
└── graphics/vectors/             # Gráficos y reportes

─────────────────────────────────────────────────────────────────────────
EJEMPLOS PRÁCTICOS:
─────────────────────────────────────────────────────────────────────────

# Experimento rápido con configuración pequeña:
$ ./run_all_experiments.sh

# Ver mejores configuraciones:
$ cat ../../graphics/vectors/best_configurations.txt

# Ver comparación PBI vs PBIFP:
$ cat ../../graphics/vectors/pbi_vs_pbifp_comparison.txt

# Consultar un índice específico interactivamente:
$ ../../build/vectors/query-pbifp-vectors \
    ../../index/vectors/pbifp/pbifp_128p_8f_1m_10000v_128d.bin \
    0.10

  Luego ingresa consultas en formato:
  -10,0.5 0.3 0.8 ...    (para k=10)
  -0                     (para salir)

─────────────────────────────────────────────────────────────────────────
SOLUCIÓN DE PROBLEMAS:
─────────────────────────────────────────────────────────────────────────

ERROR: "Command not found"
  → Asegúrate de tener permisos de ejecución:
    chmod +x *.sh

ERROR: "Compilation failed"
  → Verifica que tienes las dependencias instaladas:
    gcc, make, math library (-lm)

ERROR: "No data found"
  → Verifica que existen datasets en data/binary/vectors/
  → Ejecuta generate_vectors_dbs.sh si es necesario

ERROR: "Comparisons failed"
  → Asegúrate de tener Python 3 instalado
  → Verifica que existen resultados exactos en output/vectors/exact/

─────────────────────────────────────────────────────────────────────────

Para más información, consulta el README.md en el directorio del proyecto.

EOF
