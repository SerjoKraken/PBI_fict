#!/bin/bash

###############################################################################
# Script de Ejemplo Rápido - Prueba Completa del Sistema
# 
# Este script ejecuta una prueba rápida con configuración mínima
# para verificar que todo funciona correctamente.
###############################################################################

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Ejemplo Rápido - Sistema de Pruebas PBI/PBIFP            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Obtener directorio del proyecto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${YELLOW}Paso 1: Verificando compilación...${NC}"
if ! make all-vectors > /dev/null 2>&1; then
    echo "Error: No se pudo compilar. Ejecute 'make all-vectors' manualmente."
    exit 1
fi
echo -e "${GREEN}✓ Compilación OK${NC}"
echo ""

echo -e "${YELLOW}Paso 2: Verificando datasets...${NC}"
if [ ! -f "data/binary/vectors/10000v_128d.bin" ]; then
    echo "Dataset no encontrado. Intentando generar..."
    if [ -x "scripts/vectors/generate_vectors_dbs.sh" ]; then
        ./scripts/vectors/generate_vectors_dbs.sh
    else
        echo "Error: No se puede generar dataset automáticamente."
        echo "Por favor, genere el dataset 10000v_128d.bin manualmente."
        exit 1
    fi
fi
echo -e "${GREEN}✓ Dataset disponible${NC}"
echo ""

echo -e "${YELLOW}Paso 3: Ejecutando experimento rápido...${NC}"
echo "  - Dataset: 10000v_128d.bin"
echo "  - K: 5"
echo "  - Queries: 100"
echo "  - Porcentajes: 1%, 5%, 10%"
echo "  - Ficticios PBIFP: 0, 4"
echo ""

./scripts/vectors/run_experiments.sh \
    -d 10000v_128d.bin \
    -k 5 \
    -n 100 \
    -p "1 5 10" \
    -f "2 4 6" \
    -o results/vectors/quick_example

EXAMPLE_DIR="results/vectors/quick_example"

echo ""
echo -e "${YELLOW}Paso 4: Generando gráficos...${NC}"
./scripts/vectors/generate_plots.sh "$EXAMPLE_DIR"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ¡Experimento Completado con Éxito!                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Resultados guardados en: $EXAMPLE_DIR"
echo ""
echo "Archivos generados:"
echo "  📊 CSV de PBI:         $EXAMPLE_DIR/comparisons/pbi_precision.csv"
echo "  📊 CSV de PBIFP:       $EXAMPLE_DIR/comparisons/pbifp_precision.csv"
echo "  📈 Gráfico PBI:        $EXAMPLE_DIR/plots/pbi_precision.png"
echo "  📈 Gráfico PBIFP:      $EXAMPLE_DIR/plots/pbifp_precision.png"
echo "  📈 Comparación:        $EXAMPLE_DIR/plots/pbi_vs_pbifp.png"
echo "  📄 Reporte:            $EXAMPLE_DIR/reports/summary_report.txt"
echo ""
echo "Para ver el reporte:"
echo "  cat $EXAMPLE_DIR/reports/summary_report.txt"
echo ""
echo "Para ver los gráficos (en Linux con entorno gráfico):"
echo "  xdg-open $EXAMPLE_DIR/plots/pbi_vs_pbifp.png"
echo ""
echo "Para ejecutar un experimento completo:"
echo "  ./scripts/vectors/run_experiments.sh -h"
echo ""
