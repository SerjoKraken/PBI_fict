#!/bin/bash

cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║                    ✨ SISTEMA DE EXPERIMENTOS PBI/PBIFP ✨               ║
║                                                                          ║
║                          TODO LISTO PARA USAR                            ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝

┌──────────────────────────────────────────────────────────────────────────┐
│  📋 COMANDOS PRINCIPALES                                                 │
└──────────────────────────────────────────────────────────────────────────┘

  1️⃣  Verificar entorno (recomendado antes de empezar)
      $ ./check_environment.sh

  2️⃣  Ejecutar TODOS los experimentos automáticamente ⭐
      $ ./run_all_experiments.sh
      
      ├─ Compila binarios
      ├─ Genera consultas si no existen
      ├─ Construye índices PBI (128, 256, 512 permutantes)
      ├─ Construye índices PBIFP (múltiples configuraciones)
      ├─ Ejecuta consultas con varios porcentajes
      ├─ Compara resultados
      └─ Genera reporte final

  3️⃣  Analizar resultados
      $ ./analyze_results.sh
      
      ├─ Genera tablas comparativas
      ├─ Identifica mejores configuraciones
      ├─ Compara PBI vs PBIFP
      └─ Prepara datos para gráficos

  4️⃣  Ver ayuda completa
      $ ./help.sh

  5️⃣  Limpiar archivos generados
      $ ./clean.sh

┌──────────────────────────────────────────────────────────────────────────┐
│  📊 RESULTADOS Y REPORTES                                                │
└──────────────────────────────────────────────────────────────────────────┘

  Después de ejecutar los experimentos, encontrarás:

  📁 results/vectors/
     ├─ comparisons/               # CSVs con métricas
     │  ├─ pbi_comparison_k10.csv
     │  └─ pbifp_comparison_k10.csv
     ├─ build_pbi.log             # Logs de construcción
     ├─ build_pbifp.log
     └─ experiment_report.txt     # Reporte final

  📁 graphics/vectors/
     ├─ best_configurations.txt   # Top 5 configuraciones
     ├─ pbi_vs_pbifp_comparison.txt
     └─ *_summary.txt             # Resúmenes por método

  📁 index/vectors/
     ├─ pbi/                      # Índices PBI
     └─ pbifp/                    # Índices PBIFP

  📁 output/vectors/
     ├─ pbi/                      # Resultados PBI
     └─ pbifp/                    # Resultados PBIFP

┌──────────────────────────────────────────────────────────────────────────┐
│  ⚙️  CONFIGURACIONES DISPONIBLES                                         │
└──────────────────────────────────────────────────────────────────────────┘

  PBI:
    • Permutantes: 128, 256, 512

  PBIFP:
    • Permutantes: 128, 256
    • Ficticios: 0, 4, 8, 12, 16, 20, 24, 28, 32
    • Métodos:
      - 0 = Por Distancia (distance-based)
      - 1 = Por Frecuencia (frequency-based) ⭐ Recomendado
      - 2 = Por Media (mean-based)

  Porcentajes de revisión: 1%, 2%, 5%, 10%, 15%, 20%, 30%, 40%, 50%
  Valores de K: 10, 20, 50

┌──────────────────────────────────────────────────────────────────────────┐
│  🎯 FLUJO DE TRABAJO TÍPICO                                              │
└──────────────────────────────────────────────────────────────────────────┘

  Experimento Completo (Automático):
  
    1. $ ./check_environment.sh        # Verificar que todo esté bien
    2. $ ./run_all_experiments.sh      # Ejecutar experimentos (puede tardar)
    3. $ ./analyze_results.sh          # Analizar resultados
    4. $ cat ../../graphics/vectors/best_configurations.txt
    5. $ cat ../../graphics/vectors/pbi_vs_pbifp_comparison.txt

  Experimento Personalizado (Manual):

    1. Edita run_all_experiments.sh (líneas 46-67)
       - Modifica DATASETS, PERMUTANTS, FICTICIOUS, etc.
    2. $ ./run_all_experiments.sh
    3. $ ./analyze_results.sh

  Limpiar y Reiniciar:

    $ ./clean.sh                       # Menú interactivo
    $ ./run_all_experiments.sh         # Ejecutar de nuevo

┌──────────────────────────────────────────────────────────────────────────┐
│  📈 MEJORAS IMPLEMENTADAS                                                │
└──────────────────────────────────────────────────────────────────────────┘

  ✅ Sistema completamente automático
  ✅ Scripts modulares y reutilizables
  ✅ Verificación de entorno integrada
  ✅ Logs detallados y progreso visual
  ✅ Manejo robusto de errores
  ✅ Limpieza selectiva de archivos
  ✅ Documentación completa
  ✅ Análisis estadístico de resultados
  ✅ Comparaciones automáticas
  ✅ Identificación de mejores configuraciones

  Código fuente mejorado:
  ✅ generateByDistance() - Comentarios claros y validaciones
  ✅ generateByFrecuency() - Manejo de casos borde
  ✅ generateByMean() - Bug crítico corregido (faltaba min_dist)

┌──────────────────────────────────────────────────────────────────────────┐
│  🆘 SOLUCIÓN RÁPIDA DE PROBLEMAS                                         │
└──────────────────────────────────────────────────────────────────────────┘

  Error: "Permission denied"
    → chmod +x *.sh

  Error: "Command not found" (gcc, make, etc.)
    → sudo apt-get install build-essential python3

  Error: "Binary not found"
    → cd ../../ && make clean && make

  Error: "No data files"
    → Verifica: ls ../../data/binary/vectors/
    → Si no hay archivos, genera datos con los generadores

  ¿Necesitas más ayuda?
    → ./help.sh                        # Ayuda completa
    → cat README.md                    # Documentación detallada
    → cat SUMMARY.md                   # Resumen ejecutivo

┌──────────────────────────────────────────────────────────────────────────┐
│  📚 ARCHIVOS DE DOCUMENTACIÓN                                            │
└──────────────────────────────────────────────────────────────────────────┘

  README.md         - Documentación completa y detallada
  SUMMARY.md        - Resumen ejecutivo de mejoras
  help.sh           - Ayuda interactiva en terminal
  check_environment.sh - Diagnóstico del entorno

┌──────────────────────────────────────────────────────────────────────────┐
│  ✨ CARACTERÍSTICAS DESTACADAS                                           │
└──────────────────────────────────────────────────────────────────────────┘

  • Cero configuración manual - Todo automático
  • Reproducible - Misma config = Mismos resultados
  • Escalable - Fácil agregar datasets/configs
  • Profesional - Logs, reportes, métricas
  • Robusto - Validaciones y manejo de errores
  • Documentado - READMEs y ayuda integrada
  • Informativo - Progreso en tiempo real

┌──────────────────────────────────────────────────────────────────────────┐
│  🎓 EJEMPLO RÁPIDO                                                       │
└──────────────────────────────────────────────────────────────────────────┘

  # Experimento rápido de prueba (5-10 minutos)
  $ nano run_all_experiments.sh
  
  # Editar líneas:
  DATASETS=("10000v_128d.bin")
  PBIFP_PERMUTANTS=(128)
  PBIFP_FICTICIOUS=(0 8 16)
  PBIFP_METHODS=(1)
  PERCENTAGES=(0.05 0.10 0.20)
  
  $ ./run_all_experiments.sh
  $ ./analyze_results.sh
  $ cat ../../graphics/vectors/best_configurations.txt

╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║                    🚀 ¡TODO LISTO! COMIENZA AHORA:                      ║
║                                                                          ║
║                      ./check_environment.sh                              ║
║                      ./run_all_experiments.sh                            ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝

EOF
