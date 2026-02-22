#!/bin/bash

###############################################################################
# Script para generar gráficos a partir de resultados de experimentos
# 
# Este script genera:
# 1. Gráfico de precisión vs porcentaje para PBI
# 2. Gráfico de precisión vs porcentaje para PBIFP (diferentes valores ficticios)
# 3. Gráfico comparativo PBI vs PBIFP (mejor configuración)
#
# Uso:
#   ./generate_plots.sh <RESULTS_DIR> [OUTPUT_DIR]
#
# Parámetros:
#   RESULTS_DIR  - Directorio con los resultados del experimento
#   OUTPUT_DIR   - Directorio de salida para gráficos (default: RESULTS_DIR/plots)
#
###############################################################################

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Validar argumentos
if [ "$#" -lt 1 ]; then
    echo "Uso: $0 <RESULTS_DIR> [OUTPUT_DIR]"
    echo ""
    echo "Ejemplo:"
    echo "  $0 results/vectors/experiment_20231121_143022"
    echo "  $0 results/vectors/experiment_20231121_143022 graphics/vectors/experiment1"
    exit 1
fi

RESULTS_DIR="$1"
OUTPUT_DIR="${2:-$RESULTS_DIR/plots}"
GRAPHICS_DIR="$OUTPUT_DIR/graficos"

# Validar que exista el directorio de resultados
if [ ! -d "$RESULTS_DIR" ]; then
    log_error "Directorio de resultados no encontrado: $RESULTS_DIR"
    exit 1
fi

# Crear directorios de salida
mkdir -p "$OUTPUT_DIR"
mkdir -p "$GRAPHICS_DIR"

log_info "==============================================="
log_info "GENERACIÓN DE GRÁFICOS"
log_info "==============================================="
log_info "Resultados desde: $RESULTS_DIR"
log_info "Gráficos hacia: $OUTPUT_DIR"
log_info "==============================================="

# Archivos de entrada - intentar primero los promedios, luego los simples
PBI_CSV="$RESULTS_DIR/comparisons/pbi_precision_avg.csv"
PBIFP_CSV="$RESULTS_DIR/comparisons/pbifp_precision_avg.csv"

# Si no existen los archivos con promedios, usar los simples
if [ ! -f "$PBI_CSV" ]; then
    PBI_CSV="$RESULTS_DIR/comparisons/pbi_precision.csv"
fi

if [ ! -f "$PBIFP_CSV" ]; then
    PBIFP_CSV="$RESULTS_DIR/comparisons/pbifp_precision.csv"
fi

# Validar que existan los archivos CSV
if [ ! -f "$PBI_CSV" ]; then
    log_error "Archivo PBI no encontrado: $PBI_CSV"
    log_error "Buscado: pbi_precision_avg.csv o pbi_precision.csv"
    exit 1
fi

if [ ! -f "$PBIFP_CSV" ]; then
    log_error "Archivo PBIFP no encontrado: $PBIFP_CSV"
    log_error "Buscado: pbifp_precision_avg.csv o pbifp_precision.csv"
    exit 1
fi

log_success "Usando: $(basename $PBI_CSV)"
log_success "Usando: $(basename $PBIFP_CSV)"

###############################################################################
# Extraer información del experimento (dimensiones y permutantes)
###############################################################################
DIMENSIONS=""
N_PERMUTANTS=""
N_VECTORS=""
DATASET_NAME=""

# Intentar extraer del summary.txt
if [ -f "$RESULTS_DIR/summary.txt" ]; then
    DIMENSIONS=$(grep "^Dimensiones:" "$RESULTS_DIR/summary.txt" | awk '{print $2}')
    N_PERMUTANTS=$(grep "^Permutantes:" "$RESULTS_DIR/summary.txt" | awk '{print $2}')
    N_VECTORS=$(grep "^Vectores:" "$RESULTS_DIR/summary.txt" | awk '{print $2}')
    DATASET_NAME=$(grep "^Dataset:" "$RESULTS_DIR/summary.txt" | awk '{print $2}')
fi

# Si no se encontró, intentar del nombre del directorio o archivos
if [ -z "$DIMENSIONS" ] || [ -z "$N_PERMUTANTS" ]; then
    # Buscar en archivos de índice
    IDX_FILE=$(find "$RESULTS_DIR" -name "*.idx" 2>/dev/null | head -1)
    if [ -n "$IDX_FILE" ]; then
        IDX_NAME=$(basename "$IDX_FILE" .idx)
        # Formato: 10000v_128d_256p_4f.idx o similar
        N_VECTORS=$(echo "$IDX_NAME" | grep -oP '^\d+(?=v)')
        DIMENSIONS=$(echo "$IDX_NAME" | grep -oP '\d+(?=d)')
        N_PERMUTANTS=$(echo "$IDX_NAME" | grep -oP '\d+(?=p)')
    fi
fi

# Si aún no tenemos N_VECTORS, intentar del nombre del dataset
if [ -z "$N_VECTORS" ] && [ -n "$DATASET_NAME" ]; then
    N_VECTORS=$(echo "$DATASET_NAME" | grep -oP '^\d+(?=v)')
fi

# Valores por defecto si no se encuentran
DIMENSIONS=${DIMENSIONS:-"?"}
N_PERMUTANTS=${N_PERMUTANTS:-"?"}
N_VECTORS=${N_VECTORS:-"?"}

log_info "Configuración detectada:"
log_info "  - Vectores: $N_VECTORS"
log_info "  - Dimensiones: $DIMENSIONS"
log_info "  - Permutantes: $N_PERMUTANTS"

###############################################################################
# Calcular rango dinámico del eje Y basado en datos mínimos
###############################################################################
log_info "Calculando rangos dinámicos para gráficos..."

# Encontrar el mínimo de recuperación en PBI y PBIFP
MIN_PBI=$(tail -n +2 "$PBI_CSV" | cut -d',' -f2 | sort -n | head -1)
MIN_PBIFP=$(tail -n +2 "$PBIFP_CSV" | cut -d',' -f3 | sort -n | head -1)

# Tomar el mínimo global
MIN_RECOVERY=$(echo -e "$MIN_PBI\n$MIN_PBIFP" | sort -n | head -1 | cut -d'.' -f1)

# Redondear hacia abajo a múltiplo de 10
MIN_RECOVERY=$((MIN_RECOVERY - MIN_RECOVERY % 10))

# Asegurar que no sea menor que 0
if [ $MIN_RECOVERY -lt 0 ]; then
    MIN_RECOVERY=0
fi

# El máximo será 100
MAX_RECOVERY=100

log_info "  - Rango eje Y: [$MIN_RECOVERY, $MAX_RECOVERY]"
log_info "  - Mínimo PBI: $MIN_PBI%"
log_info "  - Mínimo PBIFP: $MIN_PBIFP%"

###############################################################################
# Gráfico 1: PBI - Precisión vs Porcentaje
###############################################################################
log_info "Generando gráfico PBI..."

PBI_PLOT="$OUTPUT_DIR/pbi_precision.gnu"
PBI_DATA="$OUTPUT_DIR/pbi_precision.data"

# Convertir CSV a formato gnuplot
tail -n +2 "$PBI_CSV" | tr ',' ' ' > "$PBI_DATA"

cat > "$PBI_PLOT" << EOF
set terminal postscript eps enhanced color font "Helvetica,20"
set encoding utf8
set output 'graficos/pbi_precision_${DIMENSIONS}d_${N_PERMUTANTS}p.eps'

set title "PBI - ${N_VECTORS} objetos, ${DIMENSIONS}d, ${N_PERMUTANTS}p"
set xlabel "% Revisión Base de Datos"
set ylabel "% Recuperación"

set grid
set key right bottom

# Ajustar rangos dinámicamente - vista completa
set xrange [0:55]
set yrange [$MIN_RECOVERY:$MAX_RECOVERY]

# Incrementos de 10 en 10 en eje Y
set ytics 10

# Estilo de línea con marcador pequeño y línea más prominente
set style line 1 pt 7 ps 0.8 lw 2 lc rgb "#2E86AB"

plot 'pbi_precision.data' using 1:2 with linespoints ls 1 title "PBI"
EOF

(cd "$OUTPUT_DIR" && gnuplot "pbi_precision.gnu")

# Convertir EPS a PNG y PDF
if [ -f "$GRAPHICS_DIR/pbi_precision_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" ]; then
    convert -density 300 "$GRAPHICS_DIR/pbi_precision_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" "$GRAPHICS_DIR/pbi_precision_${DIMENSIONS}d_${N_PERMUTANTS}p.png" 2>/dev/null || true
    ps2pdf -dEPSCrop "$GRAPHICS_DIR/pbi_precision_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" "$GRAPHICS_DIR/pbi_precision_${DIMENSIONS}d_${N_PERMUTANTS}p.pdf" 2>/dev/null || true
    log_success "Gráfico PBI generado: $GRAPHICS_DIR/pbi_precision_${DIMENSIONS}d_${N_PERMUTANTS}p.eps"
else
    log_error "Error generando gráfico PBI (¿gnuplot instalado?)"
fi

###############################################################################
# Gráfico 2: PBIFP - Precisión vs Porcentaje (múltiples configuraciones + PBI)
###############################################################################
log_info "Generando gráfico PBIFP con valores PBI..."

PBIFP_PLOT="$OUTPUT_DIR/pbifp_precision.gnu"

# Obtener valores ficticios únicos
FICT_VALUES=$(tail -n +2 "$PBIFP_CSV" | cut -d',' -f2 | sort -u)

# Crear archivos de datos por cada valor ficticio
for fict in $FICT_VALUES; do
    PBIFP_DATA="$OUTPUT_DIR/pbifp_precision_${fict}f.data"
    tail -n +2 "$PBIFP_CSV" | awk -F',' -v f="$fict" '$2 == f {print $1, $3}' > "$PBIFP_DATA"
done

# Generar script gnuplot
cat > "$PBIFP_PLOT" << EOF
set terminal postscript eps enhanced color font "Helvetica,20"
set encoding utf8
set output 'graficos/pbifp_precision_${DIMENSIONS}d_${N_PERMUTANTS}p.eps'

set title "PBI vs PBIFP - ${DIMENSIONS}d con ${N_PERMUTANTS} permutantes"
set xlabel "% Revisión Base de Datos"
set ylabel "% Recuperación"

set grid
set key right bottom

# Ajustar rangos dinámicamente - vista completa
set xrange [0:55]
set yrange [$MIN_RECOVERY:$MAX_RECOVERY]

# Incrementos de 10 en 10 en eje Y
set ytics 10

# Definir estilos de línea - diferenciación por COLORES
# PBI: línea negra gruesa con círculos grandes
set style line 1 pt 7 ps 1.2 lw 3 lc rgb "#000000"

# PBIFP: diferentes colores vivos y marcadores distintos (todas líneas sólidas)
set style line 2 pt 4 ps 1.0 lw 2.5 lc rgb "#0066CC"    # Azul intenso
set style line 3 pt 5 ps 1.0 lw 2.5 lc rgb "#CC0066"    # Magenta/rosa intenso
set style line 4 pt 6 ps 1.0 lw 2.5 lc rgb "#FF6600"    # Naranja brillante
set style line 5 pt 8 ps 1.0 lw 2.5 lc rgb "#009933"    # Verde intenso
set style line 6 pt 9 ps 1.0 lw 2.5 lc rgb "#9933CC"    # Púrpura
set style line 7 pt 10 ps 1.0 lw 2.5 lc rgb "#CC6600"   # Marrón/naranja oscuro
set style line 8 pt 12 ps 1.0 lw 2.5 lc rgb "#00CCCC"   # Cyan brillante
set style line 9 pt 13 ps 1.0 lw 2.5 lc rgb "#CC0000"   # Rojo intenso

plot \\
EOF

# Agregar línea para cada valor ficticio con diferentes marcadores
idx=2
first=true

for fict in $FICT_VALUES; do
    if [ "$first" = true ]; then
        first=false
    else
        echo "    , \\" >> "$PBIFP_PLOT"
    fi
    echo -n "    'pbifp_precision_${fict}f.data' using 1:2 with linespoints ls $idx title 'PBIFP ${fict}f'" >> "$PBIFP_PLOT"
    idx=$((idx + 1))
done

# Agregar PBI al final para que se dibuje encima
echo ", \\" >> "$PBIFP_PLOT"
echo "    'pbi_precision.data' using 1:2 with linespoints ls 1 title \"PBI\"" >> "$PBIFP_PLOT"
echo "" >> "$PBIFP_PLOT"

(cd "$OUTPUT_DIR" && gnuplot "pbifp_precision.gnu") 2>/dev/null

# Convertir EPS a PNG y PDF
if [ -f "$GRAPHICS_DIR/pbifp_precision_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" ]; then
    convert -density 300 "$GRAPHICS_DIR/pbifp_precision_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" "$GRAPHICS_DIR/pbifp_precision_${DIMENSIONS}d_${N_PERMUTANTS}p.png" 2>/dev/null || true
    ps2pdf -dEPSCrop "$GRAPHICS_DIR/pbifp_precision_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" "$GRAPHICS_DIR/pbifp_precision_${DIMENSIONS}d_${N_PERMUTANTS}p.pdf" 2>/dev/null || true
    log_success "Gráfico PBIFP generado: $GRAPHICS_DIR/pbifp_precision_${DIMENSIONS}d_${N_PERMUTANTS}p.eps"
else
    log_error "Error generando gráfico PBIFP"
fi

###############################################################################
# Gráfico 2B: UNIFICADO - PBI + PBIFP en un solo gráfico
###############################################################################
log_info "Generando gráfico unificado PBI + PBIFP..."

UNIFIED_PLOT="$OUTPUT_DIR/unified_pbi_pbifp.gnu"

cat > "$UNIFIED_PLOT" << EOF
set terminal postscript eps enhanced color font "Helvetica,20"
set encoding utf8
set output 'graficos/unified_pbi_pbifp_${DIMENSIONS}d_${N_PERMUTANTS}p.eps'

set title "PBI vs PBIFP - ${N_VECTORS} objetos, ${DIMENSIONS}d, ${N_PERMUTANTS}p"
set xlabel "% Revisión Base de Datos"
set ylabel "% Recuperación"

set grid
set key right bottom

# Ajustar rangos dinámicamente - vista completa
set xrange [0:55]
set yrange [$MIN_RECOVERY:$MAX_RECOVERY]

# Incrementos de 10 en 10 en eje Y
set ytics 10

# Definir estilos de línea - IGUALES en todos los gráficos unificados
# PBI: línea negra gruesa con círculos grandes
set style line 1 pt 7 ps 1.2 lw 3 lc rgb "#000000"

# PBIFP: diferentes colores vivos y marcadores distintos (todas líneas sólidas)
set style line 2 pt 4 ps 1.0 lw 2.5 lc rgb "#0066CC"    # Azul intenso
set style line 3 pt 5 ps 1.0 lw 2.5 lc rgb "#CC0066"    # Magenta/rosa intenso
set style line 4 pt 6 ps 1.0 lw 2.5 lc rgb "#FF6600"    # Naranja brillante
set style line 5 pt 8 ps 1.0 lw 2.5 lc rgb "#009933"    # Verde intenso
set style line 6 pt 9 ps 1.0 lw 2.5 lc rgb "#9933CC"    # Púrpura
set style line 7 pt 10 ps 1.0 lw 2.5 lc rgb "#CC6600"   # Marrón/naranja oscuro
set style line 8 pt 12 ps 1.0 lw 2.5 lc rgb "#00CCCC"   # Cyan brillante
set style line 9 pt 13 ps 1.0 lw 2.5 lc rgb "#CC0000"   # Rojo intenso

plot \\
EOF

# Agregar líneas PBIFP primero
idx=2
first=true
for fict in $FICT_VALUES; do
    if [ "$first" = true ]; then
        first=false
    else
        echo "    , \\" >> "$UNIFIED_PLOT"
    fi
    echo -n "    'pbifp_precision_${fict}f.data' using 1:2 with linespoints ls $idx title 'PBIFP ${fict}f'" >> "$UNIFIED_PLOT"
    idx=$((idx + 1))
done

# Agregar PBI al final para que se dibuje encima
echo ", \\" >> "$UNIFIED_PLOT"
echo "    'pbi_precision.data' using 1:2 with linespoints ls 1 title \"PBI\"" >> "$UNIFIED_PLOT"
echo "" >> "$UNIFIED_PLOT"

(cd "$OUTPUT_DIR" && gnuplot "unified_pbi_pbifp.gnu") 2>/dev/null

# Convertir EPS a PNG y PDF
if [ -f "$GRAPHICS_DIR/unified_pbi_pbifp_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" ]; then
    convert -density 300 "$GRAPHICS_DIR/unified_pbi_pbifp_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" "$GRAPHICS_DIR/unified_pbi_pbifp_${DIMENSIONS}d_${N_PERMUTANTS}p.png" 2>/dev/null || true
    ps2pdf -dEPSCrop "$GRAPHICS_DIR/unified_pbi_pbifp_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" "$GRAPHICS_DIR/unified_pbi_pbifp_${DIMENSIONS}d_${N_PERMUTANTS}p.pdf" 2>/dev/null || true
    log_success "Gráfico unificado generado: $GRAPHICS_DIR/unified_pbi_pbifp_${DIMENSIONS}d_${N_PERMUTANTS}p.eps"
else
    log_error "Error generando gráfico unificado"
fi

###############################################################################
# Gráfico 2A: Unified ZOOM 0-10% (región crítica)
###############################################################################
log_info "Generando gráfico unificado PBI + PBIFP con zoom 0-10%..."

UNIFIED_ZOOM_PLOT="$OUTPUT_DIR/unified_zoom_0_10.gnu"

cat > "$UNIFIED_ZOOM_PLOT" << EOF
set terminal postscript eps enhanced color font "Helvetica,20"
set encoding utf8
set output 'graficos/unified_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.eps'

set title "PBI vs PBIFP - Zoom 0-10% ($N_VECTORS objetos, ${DIMENSIONS}d, ${N_PERMUTANTS}p)"
set xlabel "% Revisión Base de Datos"
set ylabel "% Recuperación"

set grid
set key right bottom

# Zoom en región 0-10%
set xrange [0:12]
set yrange [$MIN_RECOVERY:$MAX_RECOVERY]

# Incrementos de 10 en 10 en eje Y
set ytics 10

# Definir estilos de línea - IGUALES al gráfico unified sin zoom
# PBI: línea negra gruesa con círculos grandes
set style line 1 pt 7 ps 1.2 lw 3 lc rgb "#000000"

# PBIFP: diferentes colores vivos y marcadores distintos (todas líneas sólidas)
set style line 2 pt 4 ps 1.0 lw 2.5 lc rgb "#0066CC"    # Azul intenso
set style line 3 pt 5 ps 1.0 lw 2.5 lc rgb "#CC0066"    # Magenta/rosa intenso
set style line 4 pt 6 ps 1.0 lw 2.5 lc rgb "#FF6600"    # Naranja brillante
set style line 5 pt 8 ps 1.0 lw 2.5 lc rgb "#009933"    # Verde intenso
set style line 6 pt 9 ps 1.0 lw 2.5 lc rgb "#9933CC"    # Púrpura
set style line 7 pt 10 ps 1.0 lw 2.5 lc rgb "#CC6600"   # Marrón/naranja oscuro
set style line 8 pt 12 ps 1.0 lw 2.5 lc rgb "#00CCCC"   # Cyan brillante
set style line 9 pt 13 ps 1.0 lw 2.5 lc rgb "#CC0000"   # Rojo intenso

plot \\
EOF

# Agregar líneas para cada valor ficticio primero - usar FICT_VALUES
fict_index=2
first=true
for fict in $FICT_VALUES; do
    if [ "$first" = true ]; then
        first=false
    else
        echo "     , \\" >> "$UNIFIED_ZOOM_PLOT"
    fi
    echo -n "     'pbifp_precision_${fict}f.data' using 1:2 with linespoints ls $fict_index title \"PBIFP ${fict}f\"" >> "$UNIFIED_ZOOM_PLOT"
    fict_index=$((fict_index + 1))
done

# Agregar PBI al final para que se dibuje encima
echo ", \\" >> "$UNIFIED_ZOOM_PLOT"
echo "     'pbi_precision.data' using 1:2 with linespoints ls 1 title \"PBI\"" >> "$UNIFIED_ZOOM_PLOT"
echo "" >> "$UNIFIED_ZOOM_PLOT"

(cd "$OUTPUT_DIR" && gnuplot "unified_zoom_0_10.gnu") 2>/dev/null

# Convertir EPS a PNG y PDF
if [ -f "$GRAPHICS_DIR/unified_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" ]; then
    convert -density 300 "$GRAPHICS_DIR/unified_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" "$GRAPHICS_DIR/unified_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.png" 2>/dev/null || true
    ps2pdf -dEPSCrop "$GRAPHICS_DIR/unified_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" "$GRAPHICS_DIR/unified_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.pdf" 2>/dev/null || true
    log_success "Gráfico unificado zoom 0-10% generado: $GRAPHICS_DIR/unified_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.eps"
else
    log_error "Error generando gráfico unificado zoom"
fi

###############################################################################
# Gráfico 3A: PBI Zoom 0-10% (región crítica)
###############################################################################
log_info "Generando gráfico PBI con zoom 0-10%..."

PBI_ZOOM_PLOT="$OUTPUT_DIR/pbi_zoom_0_10.gnu"

cat > "$PBI_ZOOM_PLOT" << EOF
set terminal postscript eps enhanced color font "Helvetica,20"
set encoding utf8
set output 'graficos/pbi_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.eps'

set title "PBI - Zoom 0-10% (${N_VECTORS} objetos, ${DIMENSIONS}d, ${N_PERMUTANTS}p)"
set xlabel "% Revisión Base de Datos"
set ylabel "% Recuperación"

set grid
set key right bottom

# Zoom a la región 0-10%
set xrange [0:12]
set yrange [$MIN_RECOVERY:$MAX_RECOVERY]

# Incrementos de 5 en el eje Y para más detalle
set ytics 5

# Estilo con marcador pequeño
set style line 1 pt 7 ps 0.8 lw 2 lc rgb "#2E86AB"

plot 'pbi_precision.data' using 1:2 with linespoints ls 1 title "PBI"
EOF

(cd "$OUTPUT_DIR" && gnuplot "pbi_zoom_0_10.gnu") 2>/dev/null

# Convertir EPS a PNG y PDF
if [ -f "$GRAPHICS_DIR/pbi_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" ]; then
    convert -density 300 "$GRAPHICS_DIR/pbi_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" "$GRAPHICS_DIR/pbi_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.png" 2>/dev/null || true
    ps2pdf -dEPSCrop "$GRAPHICS_DIR/pbi_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" "$GRAPHICS_DIR/pbi_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.pdf" 2>/dev/null || true
    log_success "Gráfico PBI zoom 0-10% generado: $GRAPHICS_DIR/pbi_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.eps"
else
    log_error "Error generando gráfico PBI zoom"
fi

###############################################################################
# Preparar datos: Encontrar mejor configuración PBIFP para cada porcentaje
###############################################################################
log_info "Preparando datos de mejor configuración PBIFP..."

PBIFP_BEST_DATA="$OUTPUT_DIR/pbifp_best.data"

# Encontrar la mejor configuración de PBIFP para cada porcentaje
> "$PBIFP_BEST_DATA"

PERCENTAGES=$(tail -n +2 "$PBI_CSV" | cut -d',' -f1 | sort -u)

for perc in $PERCENTAGES; do
    best_prec=0
    best_line=""
    
    while IFS=, read -r p f prec; do
        if [ "$p" = "$perc" ]; then
            if (( $(echo "$prec > $best_prec" | bc -l) )); then
                best_prec="$prec"
                best_line="$p $prec"
            fi
        fi
    done < <(tail -n +2 "$PBIFP_CSV")
    
    if [ -n "$best_line" ]; then
        echo "$best_line" >> "$PBIFP_BEST_DATA"
    fi
done

log_success "Datos preparados"

###############################################################################
# Gráfico 3B: Mejora de PBIFP sobre PBI - TODAS las configuraciones (HONESTO)
###############################################################################
log_info "Generando gráfico de mejora PBIFP sobre PBI (todas las configuraciones)..."

IMPROVEMENT_ALL_PLOT="$OUTPUT_DIR/pbifp_improvement_all.gnu"
IMPROVEMENT_ALL_DATA="$OUTPUT_DIR/pbifp_improvement_all.data"

# Calcular la mejora para TODAS las configuraciones
> "$IMPROVEMENT_ALL_DATA"

tail -n +2 "$PBIFP_CSV" | while IFS=, read -r perc fict prec_pbifp; do
    # Buscar la precisión PBI correspondiente
    prec_pbi=$(grep "^$perc," "$PBI_CSV" | cut -d',' -f2)
    
    if [ -n "$prec_pbi" ]; then
        # Calcular mejora (puede ser positiva, negativa o cero)
        improvement=$(awk -v a="$prec_pbifp" -v b="$prec_pbi" 'BEGIN{ printf "%.2f", (a - b)}')
        echo "$perc $fict $improvement" >> "$IMPROVEMENT_ALL_DATA"
    fi
done

# Obtener lista única de valores ficticios
FICT_VALUES=$(tail -n +2 "$PBIFP_CSV" | cut -d',' -f2 | sort -u)
FICT_COUNT=$(echo "$FICT_VALUES" | wc -l)

# Crear archivos de datos separados por configuración
for fict in $FICT_VALUES; do
    awk -v f="$fict" '$2 == f {print $1, $3}' "$IMPROVEMENT_ALL_DATA" > "$OUTPUT_DIR/improvement_${fict}f.data"
done

# Calcular límite superior del eje Y para el gráfico de mejoras (máx 3%)
MAX_IMP=$(awk 'BEGIN{max=-1e9} {if($3+0>max) max=$3} END{ if(max==-1e9) print 0; else print max}' "$IMPROVEMENT_ALL_DATA" 2>/dev/null || echo 0)
# Añadir margen de 0.5 puntos porcentuales, pero no superar 3.0; mínimo útil 1.0 para visibilidad
Y_MAX=$(awk -v m="$MAX_IMP" 'BEGIN{cap=3.0; m+=0.5; if(m>cap) m=cap; if(m<1.0) m=1.0; printf "%.2f", m}')

# Generar script gnuplot
cat > "$IMPROVEMENT_ALL_PLOT" << GNUPLOT_EOF
set terminal postscript eps enhanced color font "Helvetica,20"
set encoding utf8
set output 'graficos/pbifp_improvement_all_${DIMENSIONS}d_${N_PERMUTANTS}p.eps'

set title "Mejora PBIFP sobre PBI - Todas ($N_VECTORS objetos, ${DIMENSIONS}d, ${N_PERMUTANTS}p)"
set xlabel "% Revisión Base de Datos"
set ylabel "Mejora en % Recuperación"

set grid
set key right top

set xrange [0:55]
set yrange [-2:${Y_MAX}]

set ytics 1

# Línea de referencia en y=0 (sin mejora)
set arrow from 0,0 to 55,0 nohead lc rgb "black" lw 2 dt 2

# Definir estilos con marcadores pequeños
set style line 1 pt 7 ps 0.7 lc rgb "#2E86AB" lw 2
set style line 2 pt 4 ps 0.7 lc rgb "#A23B72" lw 2
set style line 3 pt 8 ps 0.7 lc rgb "#F18F01" lw 2
set style line 4 pt 6 ps 0.7 lc rgb "#C73E1D" lw 2
set style line 5 pt 12 ps 0.7 lc rgb "#6A994E" lw 2
set style line 6 pt 10 ps 0.7 lc rgb "#BC4B51" lw 2
set style line 7 pt 14 ps 0.7 lc rgb "#8B5A3C" lw 2
GNUPLOT_EOF

# Iniciar el plot statement
echo "" >> "$IMPROVEMENT_ALL_PLOT"
echo "plot \\" >> "$IMPROVEMENT_ALL_PLOT"

# Agregar líneas de plot para cada configuración
i=1
first=true
for fict in $FICT_VALUES; do
    if [ "$first" = true ]; then
        first=false
        echo -n "    'improvement_${fict}f.data' using 1:2 with linespoints ls $i title '$fict ficticios'" >> "$IMPROVEMENT_ALL_PLOT"
    else
        echo " , \\" >> "$IMPROVEMENT_ALL_PLOT"
        echo -n "    'improvement_${fict}f.data' using 1:2 with linespoints ls $i title '$fict ficticios'" >> "$IMPROVEMENT_ALL_PLOT"
    fi
    i=$((i+1))
done

echo "" >> "$IMPROVEMENT_ALL_PLOT"

(cd "$OUTPUT_DIR" && {
    if ! gnuplot "pbifp_improvement_all.gnu" 2>&1; then
        log_error "Error ejecutando gnuplot para gráfico de todas las mejoras"
        cat "pbifp_improvement_all.gnu"
    fi
})

# Convertir EPS a PNG y PDF
if [ -f "$GRAPHICS_DIR/pbifp_improvement_all_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" ]; then
    convert -density 300 "$GRAPHICS_DIR/pbifp_improvement_all_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" "$GRAPHICS_DIR/pbifp_improvement_all_${DIMENSIONS}d_${N_PERMUTANTS}p.png" 2>/dev/null || true
    ps2pdf -dEPSCrop "$GRAPHICS_DIR/pbifp_improvement_all_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" "$GRAPHICS_DIR/pbifp_improvement_all_${DIMENSIONS}d_${N_PERMUTANTS}p.pdf" 2>/dev/null || true
    log_success "Gráfico de todas las mejoras generado: $GRAPHICS_DIR/pbifp_improvement_all_${DIMENSIONS}d_${N_PERMUTANTS}p.eps"
    
    # Análisis de resultados honestos
    log_info ""
    log_info "Análisis de Mejoras (todas las configuraciones):"
    
    positivas=$(awk '$3 > 0.5 {count++} END {print count+0}' "$IMPROVEMENT_ALL_DATA")
    neutrales=$(awk '$3 >= -0.5 && $3 <= 0.5 {count++} END {print count+0}' "$IMPROVEMENT_ALL_DATA")
    negativas=$(awk '$3 < -0.5 {count++} END {print count+0}' "$IMPROVEMENT_ALL_DATA")
    
    log_info "  ✅ Mejoras significativas (>0.5%): $positivas configuraciones"
    log_info "  ⚠️  Sin cambio significativo (±0.5%): $neutrales configuraciones"
    log_info "  ❌ Empeoramientos (< -0.5%): $negativas configuraciones"
    
    mejor=$(sort -k3 -rn "$IMPROVEMENT_ALL_DATA" | head -1)
    log_info ""
    log_info "  🏆 Mejor mejora: $mejor"
    
    if [ "$negativas" -gt 0 ]; then
        peor=$(sort -k3 -n "$IMPROVEMENT_ALL_DATA" | head -1)
        log_warn "  ⚠️  Peor resultado: $peor"
    fi
else
    log_error "Error generando gráfico de todas las mejoras"
fi

###############################################################################
# Gráfico 3C: Mejora de PBIFP sobre PBI - MEJOR configuración por porcentaje
###############################################################################
log_info "Generando gráfico de MEJOR mejora PBIFP sobre PBI..."

IMPROVEMENT_BEST_PLOT="$OUTPUT_DIR/pbifp_improvement_best.gnu"
IMPROVEMENT_BEST_DATA="$OUTPUT_DIR/pbifp_improvement_best.data"

# Calcular la mejora solo para la mejor configuración
> "$IMPROVEMENT_BEST_DATA"

while IFS=' ' read -r perc pbi_prec; do
    # Buscar mejor PBIFP para este porcentaje
    pbifp_prec=$(awk -v p="$perc" '$1 == p {print $2}' "$PBIFP_BEST_DATA")
    
    if [ -n "$pbifp_prec" ]; then
        # Calcular mejora en puntos porcentuales
        improvement=$(echo "scale=2; $pbifp_prec - $pbi_prec" | bc)
        
        # Determinar qué ficticios dieron esta mejor configuración
        best_fict=$(tail -n +2 "$PBIFP_CSV" | awk -F',' -v p="$perc" -v pr="$pbifp_prec" \
            '$1 == p && $3 == pr {print $2; exit}')
        
        echo "$perc $improvement $best_fict" >> "$IMPROVEMENT_BEST_DATA"
    fi
done < "$PBI_DATA"

cat > "$IMPROVEMENT_BEST_PLOT" << GNUPLOT_EOF
set terminal postscript eps enhanced color font "Helvetica,20"
set encoding utf8
set output 'graficos/pbifp_improvement_best_${DIMENSIONS}d_${N_PERMUTANTS}p.eps'

set title "Mejora PBIFP sobre PBI - Mejor ($N_VECTORS objetos, ${DIMENSIONS}d, ${N_PERMUTANTS}p)"
set xlabel "% Revisión Base de Datos"
set ylabel "Mejora en % Recuperación"

set grid
set key right top

set xrange [0:55]
set yrange [-1:8]

set ytics 1

# Línea de referencia en y=0
set arrow from 0,0 to 55,0 nohead lc rgb "black" lw 2 dt 2

# Estilos: verde para mejoras, rojo para empeoramientos - marcadores pequeños
set style line 1 pt 7 ps 0.9 lc rgb "#6A994E" lw 2.5
set style line 2 pt 7 ps 0.9 lc rgb "#C73E1D" lw 2.5

plot 'pbifp_improvement_best.data' using 1:(\$2>0?\$2:1/0):3 \
        with labels offset 0,0.8 font ",9" notitle, \
     'pbifp_improvement_best.data' using 1:(\$2>0?\$2:1/0) \
        with linespoints ls 1 title "Mejora positiva", \
     'pbifp_improvement_best.data' using 1:(\$2<=0?\$2:1/0) \
        with linespoints ls 2 title "Sin mejora/Empeora"
GNUPLOT_EOF

(cd "$OUTPUT_DIR" && {
    if ! gnuplot "pbifp_improvement_best.gnu" 2>&1; then
        log_error "Error ejecutando gnuplot para gráfico de mejor mejora"
        cat "pbifp_improvement_best.gnu"
    fi
})

# Convertir EPS a PNG y PDF
if [ -f "$GRAPHICS_DIR/pbifp_improvement_best_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" ]; then
    convert -density 300 "$GRAPHICS_DIR/pbifp_improvement_best_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" "$GRAPHICS_DIR/pbifp_improvement_best_${DIMENSIONS}d_${N_PERMUTANTS}p.png" 2>/dev/null || true
    ps2pdf -dEPSCrop "$GRAPHICS_DIR/pbifp_improvement_best_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" "$GRAPHICS_DIR/pbifp_improvement_best_${DIMENSIONS}d_${N_PERMUTANTS}p.pdf" 2>/dev/null || true
    log_success "Gráfico de mejor mejora generado: $GRAPHICS_DIR/pbifp_improvement_best_${DIMENSIONS}d_${N_PERMUTANTS}p.eps"
else
    log_error "Error generando gráfico de mejor mejora"
fi

###############################################################################
# Gráfico 3D: Comparación directa PBI vs PBIFP (opcional)
###############################################################################
log_info "Generando gráfico comparativo PBI vs PBIFP..."

COMPARISON_PLOT="$OUTPUT_DIR/pbi_vs_pbifp.gnu"

cat > "$COMPARISON_PLOT" << EOF
set terminal postscript eps enhanced color font "Helvetica,20"
set encoding utf8
set output 'graficos/pbi_vs_pbifp_${DIMENSIONS}d_${N_PERMUTANTS}p.eps'

set title "PBI vs PBIFP (Mejor) - ${N_VECTORS} objetos, ${DIMENSIONS}d, ${N_PERMUTANTS}p"
set xlabel "% Revisión Base de Datos"
set ylabel "% Recuperación"

set grid
set key right bottom

# Ajustar rangos - vista completa
set xrange [0:55]
set yrange [$MIN_RECOVERY:$MAX_RECOVERY]

# Incrementos de 10 en 10 en eje Y
set ytics 10

# Estilos de línea con marcadores pequeños
set style line 1 pt 7 ps 0.8 lw 2.5 lc rgb "#2E86AB"
set style line 2 pt 4 ps 0.8 lw 2.5 lc rgb "#A23B72"

plot 'pbi_precision.data' using 1:2 with linespoints ls 1 title "PBI", \\
     'pbifp_best.data' using 1:2 with linespoints ls 2 title "PBIFP (mejor)"
EOF

(cd "$OUTPUT_DIR" && gnuplot "pbi_vs_pbifp.gnu") 2>/dev/null

# Convertir EPS a PNG y PDF
if [ -f "$GRAPHICS_DIR/pbi_vs_pbifp_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" ]; then
    convert -density 300 "$GRAPHICS_DIR/pbi_vs_pbifp_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" "$GRAPHICS_DIR/pbi_vs_pbifp_${DIMENSIONS}d_${N_PERMUTANTS}p.png" 2>/dev/null || true
    ps2pdf -dEPSCrop "$GRAPHICS_DIR/pbi_vs_pbifp_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" "$GRAPHICS_DIR/pbi_vs_pbifp_${DIMENSIONS}d_${N_PERMUTANTS}p.pdf" 2>/dev/null || true
    log_success "Gráfico comparativo generado: $GRAPHICS_DIR/pbi_vs_pbifp_${DIMENSIONS}d_${N_PERMUTANTS}p.eps"
else
    log_error "Error generando gráfico comparativo"
fi

###############################################################################
# Gráfico 4: PBIFP Zoom 0-10% (región crítica)
###############################################################################
log_info "Generando gráfico PBIFP con zoom 0-10%..."

ZOOM_PLOT="$OUTPUT_DIR/pbifp_zoom_0_10.gnu"

cat > "$ZOOM_PLOT" << EOF
set terminal postscript eps enhanced color font "Helvetica,20"
set encoding utf8
set output 'graficos/pbifp_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.eps'

set title "PBIFP - Zoom 0-10% (${N_VECTORS} objetos, ${DIMENSIONS}d, ${N_PERMUTANTS}p)"
set xlabel "% Revisión Base de Datos"
set ylabel "% Recuperación"

set grid
set key right bottom

# Zoom a la región 0-10%
set xrange [0:12]
set yrange [$MIN_RECOVERY:$MAX_RECOVERY]

# Incrementos de 5 en el eje Y para más detalle
set ytics 5

# Definir estilos con marcadores pequeños
set style line 1 pt 7 ps 0.8 lw 2 lc rgb "#2E86AB"
set style line 2 pt 4 ps 0.8 lw 2 lc rgb "#A23B72"
set style line 3 pt 8 ps 0.8 lw 2 lc rgb "#F18F01"
set style line 4 pt 6 ps 0.8 lw 2 lc rgb "#C73E1D"
set style line 5 pt 12 ps 0.8 lw 2 lc rgb "#6A994E"

plot \\
EOF

# Agregar línea para cada valor ficticio
first=true
idx=1

for fict in $FICT_VALUES; do
    if [ "$first" = true ]; then
        first=false
    else
        echo "    , \\" >> "$ZOOM_PLOT"
    fi
    
    echo -n "    'pbifp_precision_${fict}f.data' using 1:2 with linespoints ls $idx title '$fict ficticios'" >> "$ZOOM_PLOT"
    
    idx=$((idx + 1))
done

echo "" >> "$ZOOM_PLOT"

(cd "$OUTPUT_DIR" && gnuplot "pbifp_zoom_0_10.gnu") 2>/dev/null

# Convertir EPS a PNG y PDF
if [ -f "$GRAPHICS_DIR/pbifp_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" ]; then
    convert -density 300 "$GRAPHICS_DIR/pbifp_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" "$GRAPHICS_DIR/pbifp_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.png" 2>/dev/null || true
    ps2pdf -dEPSCrop "$GRAPHICS_DIR/pbifp_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.eps" "$GRAPHICS_DIR/pbifp_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.pdf" 2>/dev/null || true
    log_success "Gráfico PBIFP zoom 0-10% generado: $GRAPHICS_DIR/pbifp_zoom_0_10_${DIMENSIONS}d_${N_PERMUTANTS}p.eps"
else
    log_error "Error generando gráfico zoom"
fi

###############################################################################
# Gráfico 5: Tabla comparativa en formato texto
###############################################################################
log_info "Generando tabla comparativa..."

TABLE_FILE="$OUTPUT_DIR/comparison_table.txt"

{
    echo "==============================================="
    echo "TABLA COMPARATIVA PBI vs PBIFP"
    echo "==============================================="
    echo ""
    printf "%-12s | %-12s | %-12s | %-12s\n" "Percentage" "PBI" "PBIFP (Best)" "Diferencia"
    echo "-------------|--------------|--------------|-------------"
    
    while IFS=' ' read -r perc pbi_prec; do
        # Buscar mejor PBIFP para este porcentaje
        pbifp_prec=$(awk -v p="$perc" '$1 == p {print $2}' "$PBIFP_BEST_DATA")
        
        if [ -n "$pbifp_prec" ]; then
            # Asegurar formato correcto con punto decimal
            pbi_prec=$(echo "$pbi_prec" | tr ',' '.')
            pbifp_prec=$(echo "$pbifp_prec" | tr ',' '.')
            diff=$(echo "scale=2; $pbifp_prec - $pbi_prec" | bc | tr ',' '.')
            
            printf "%-12s | %-11s%% | %-11s%% | %+s%%\n" "$perc%" "$pbi_prec" "$pbifp_prec" "$diff"
        fi
    done < "$PBI_DATA"
    
    echo ""
    echo "==============================================="
    
} > "$TABLE_FILE"

cat "$TABLE_FILE"
log_success "Tabla guardada en: $TABLE_FILE"

###############################################################################
# Generar reporte de gráficos
###############################################################################
GRAPHICS_REPORT="$OUTPUT_DIR/graphics_report.txt"

{
    echo "==============================================="
    echo "REPORTE DE GRÁFICOS GENERADOS"
    echo "==============================================="
    echo "Fecha: $(date)"
    echo ""
    echo "Configuración:"
    echo "  - Dimensiones: $DIMENSIONS"
    echo "  - Permutantes: $N_PERMUTANTS"
    echo "  - Rango eje Y: [$MIN_RECOVERY%, $MAX_RECOVERY%]"
    echo ""
    echo "Gráficos generados:"
    echo "  1. PBI Precisión (0-55%): pbi_precision.eps/.png/.pdf"
    echo "  2. PBIFP Precisión (0-55%): pbifp_precision.eps/.png/.pdf"
    echo "  3. UNIFICADO PBI+PBIFP (0-55%): unified_pbi_pbifp.eps/.png/.pdf"
    echo "  4. PBI Zoom (0-10%): pbi_zoom_0_10.eps/.png/.pdf"
    echo "  5. PBIFP Zoom (0-10%): pbifp_zoom_0_10.eps/.png/.pdf"
    echo "  6. Mejora PBIFP todas (0-55%): pbifp_improvement_all.eps/.png/.pdf"
    echo "  7. Mejora PBIFP mejor (0-55%): pbifp_improvement_best.eps/.png/.pdf"
    echo "  8. Comparación directa (0-55%): pbi_vs_pbifp.eps/.png/.pdf"
    echo ""
    echo "Archivos de datos:"
    echo "  - pbi_precision.data"
    echo "  - pbifp_precision_*.data"
    echo "  - pbifp_best.data"
    echo "  - pbifp_improvement_all.data (todas las configuraciones)"
    echo "  - pbifp_improvement_best.data (mejor por porcentaje)"
    echo ""
    echo "Scripts gnuplot:"
    echo "  - pbi_precision.gnu"
    echo "  - pbifp_precision.gnu"
    echo "  - unified_pbi_pbifp.gnu"
    echo "  - pbi_zoom_0_20.gnu"
    echo "  - pbifp_zoom_0_20.gnu"
    echo "  - pbifp_improvement_all.gnu"
    echo "  - pbifp_improvement_best.gnu"
    echo "  - pbi_vs_pbifp.gnu"
    echo ""
    echo "Tabla comparativa:"
    echo "  - comparison_table.txt"
    echo ""
    echo "==============================================="
    echo "GRÁFICOS RECOMENDADOS PARA PRESENTACIÓN:"
    echo "==============================================="
    echo "  ✓ unified_pbi_pbifp.png       - NUEVO: PBI + PBIFP en un solo gráfico (0-55%)"
    echo "  ✓ pbi_zoom_0_10.png           - PBI detallado (0-10%)"
    echo "  ✓ pbifp_zoom_0_10.png         - PBIFP detallado (0-10%)"
    echo "  ✓ pbifp_improvement_all.png   - HONESTO: Muestra todas las configuraciones"
    echo "  ✓ pbifp_improvement_best.png  - OPTIMISTA: Solo mejor por porcentaje"
    echo ""
} > "$GRAPHICS_REPORT"

log_info "==============================================="
log_success "GENERACIÓN DE GRÁFICOS COMPLETADA"
log_info "==============================================="
log_info ""
log_info "Los gráficos están disponibles en: $GRAPHICS_DIR"
log_info ""
log_info "Configuración: ${DIMENSIONS}d con ${N_PERMUTANTS} permutantes"
log_info "Rango dinámico: [$MIN_RECOVERY%, $MAX_RECOVERY%]"
log_info ""
log_info "Gráficos principales:"
log_info "  1. Completos (0-55%): PBI, PBIFP, unificado, mejoras"
log_info "  2. Zoom (0-10%): PBI zoom, PBIFP zoom"
log_info "  3. Análisis: Mejora TODAS configuraciones, Mejora MEJOR"
log_info ""
log_info "Para ver los gráficos PNG:"
log_info "  xdg-open $GRAPHICS_DIR/*.png"
log_info ""
