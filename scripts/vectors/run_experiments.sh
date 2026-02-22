#!/bin/bash

###############################################################################
# Script para ejecutar pruebas completas de PBI y PBIFP
# 
# Este script:
# 1. Ejecuta queries con diferentes porcentajes para PBI y PBIFP
# 2. Compara los resultados con las respuestas exactas
# 3. Guarda los resultados en formato CSV para análisis posterior
# 4. Genera reportes resumidos
#
# Uso:
#   ./run_experiments.sh [options]
#
# Opciones:
#   -d DATASET     Dataset binario a usar (default: 10000v_128d.bin)
#   -k K_VALUE     Valor de K para K-NN (default: 10)
#   -q QUERIES     Archivo de queries (default: se genera automáticamente)
#   -n NUM_QUERIES Número de queries a generar (default: 100)
#   -p "PERCS"     Porcentajes a probar (default: "1 2 5 10 15 20 30 40 50")
#   -f "FICT"      Valores ficticios para PBIFP (default: "0 4 8 16 32")
#   -o OUTPUT_DIR  Directorio de salida (default: results/vectors)
#   -h             Mostrar ayuda
###############################################################################

set -e

# Colores para logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuración por defecto
DATASET="10000v_128d.bin"
K_VALUE=5
QUERY_FILE=""
NUM_QUERIES=100
N_PERMUTANTS=""  # Número de permutantes (default: igual a DIMENSIONS del dataset)
PERCENTAGES="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 20"
FICTICIOUS_VALUES="1 2 3 4 5"
OUTPUT_DIR=""
RUN_ALL_INSTANCES=true  # Si true, ejecuta las 5 instancias y promedia

# Función de ayuda
show_help() {
    cat << EOF
Uso: $0 [opciones]

Opciones:
  -d DATASET     Dataset binario a usar (default: 10000v_128d.bin)
  -k K_VALUE     Valor de K para K-NN (default: 5)
  -m N_PERM      Número de permutantes para el índice (default: dimensiones del dataset)
  -q QUERIES     Archivo de queries específico (default: procesa las 5 instancias)
  -n NUM_QUERIES Número de queries a generar (default: 100)
  -p "PERCS"     Porcentajes a probar (default: "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 20 25 30 35 40 45 50")
  -f "FICT"      Valores ficticios para PBIFP (default: "1 2 3 4 5 6 8")
  -o OUTPUT_DIR  Directorio de salida (default: results/vectors/TIMESTAMP)
  -s             Ejecutar solo UNA instancia (en lugar de las 5)
  -h             Mostrar esta ayuda

Ejemplos:
  # Ejecutar con valores por defecto (permutantes = dimensiones)
  $0

  # Dataset 256d pero solo 128 permutantes
  $0 -d 10000v_256d.bin -m 128

  # Ejecutar con dataset específico y configuración personalizada
  $0 -d 10000v_128d.bin -m 64 -k 5 -p "1 5 10 20"

EOF
}

# Procesar argumentos
while getopts "d:k:m:q:n:p:f:o:sh" opt; do
    case $opt in
        d) DATASET="$OPTARG" ;;
        k) K_VALUE="$OPTARG" ;;
        m) N_PERMUTANTS="$OPTARG" ;;
        q) QUERY_FILE="$OPTARG"; RUN_ALL_INSTANCES=false ;;
        n) NUM_QUERIES="$OPTARG" ;;
        p) PERCENTAGES="$OPTARG" ;;
        f) FICTICIOUS_VALUES="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        s) RUN_ALL_INSTANCES=false ;;
        h) show_help; exit 0 ;;
        *) show_help; exit 1 ;;
    esac
done

# Obtener rutas del proyecto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

# Extraer información del dataset PRIMERO (antes de crear directorios)
DATASET_NAME=$(basename "$DATASET" .bin)
DATASET_PATH="$PROJECT_ROOT/data/binary/vectors/$DATASET"

# Validar que exista el dataset
if [ ! -f "$DATASET_PATH" ]; then
    log_error "Dataset no encontrado: $DATASET_PATH"
    exit 1
fi

# Extraer dimensiones y número de vectores del nombre del dataset
# Ejemplo: 10000v_128d.bin -> N_VECTORS=10000, DIMENSIONS=128
N_VECTORS=$(echo "$DATASET_NAME" | grep -oP '^\d+(?=v)')
DIMENSIONS=$(echo "$DATASET_NAME" | grep -oP '\d+(?=d)')

if [ -z "$N_VECTORS" ] || [ -z "$DIMENSIONS" ]; then
    log_error "No se pudo extraer información del dataset. Nombre esperado: NNNNv_DDDd.bin"
    exit 1
fi

# Si no se especificó número de permutantes, usar las dimensiones del dataset
if [ -z "$N_PERMUTANTS" ]; then
    N_PERMUTANTS="$DIMENSIONS"
    log_info "Número de permutantes no especificado, usando dimensiones del dataset: $N_PERMUTANTS"
fi

# Configurar directorios (AHORA que ya tenemos dimensiones y permutantes)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
if [ -z "$OUTPUT_DIR" ]; then
    OUTPUT_DIR="$PROJECT_ROOT/results/vectors/experiment_${DIMENSIONS}d_${N_PERMUTANTS}p_${TIMESTAMP}"
fi

mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/queries"
mkdir -p "$OUTPUT_DIR/exact"
mkdir -p "$OUTPUT_DIR/pbi"
mkdir -p "$OUTPUT_DIR/pbifp"
mkdir -p "$OUTPUT_DIR/comparisons"
mkdir -p "$OUTPUT_DIR/reports"

# Archivos de log
MAIN_LOG="$OUTPUT_DIR/experiment.log"
SUMMARY_LOG="$OUTPUT_DIR/summary.txt"

log_info "==============================================="
log_info "EXPERIMENTO: $DATASET_NAME (K=$K_VALUE)"
log_info "==============================================="
log_info "Dataset: $DATASET_PATH"
log_info "Vectores: $N_VECTORS"
log_info "Dimensiones del dataset: $DIMENSIONS"
log_info "Permutantes a usar: $N_PERMUTANTS"
log_info "Queries: $NUM_QUERIES"
log_info "Porcentajes: $PERCENTAGES"
log_info "Valores ficticios PBIFP: $FICTICIOUS_VALUES"
log_info "Directorio de salida: $OUTPUT_DIR"
log_info "==============================================="

# Guardar configuración del experimento
{
    echo "CONFIGURACIÓN DEL EXPERIMENTO"
    echo "=============================="
    echo "Fecha: $(date)"
    echo "Dataset: $DATASET_NAME"
    echo "Vectores: $N_VECTORS"
    echo "Dimensiones: $DIMENSIONS"
    echo "Permutantes: $N_PERMUTANTS"
    echo "K: $K_VALUE"
    echo "Archivo de queries: $QUERY_FILE"
    echo "Número de queries: $NUM_QUERIES"
    echo "Resultados AESA: $EXACT_OUTPUT"
    echo "Porcentajes: $PERCENTAGES"
    echo "Valores ficticios: $FICTICIOUS_VALUES"
    echo ""
} > "$SUMMARY_LOG"

###############################################################################
# PASO 1: Determinar archivos de queries a procesar
###############################################################################
log_info "PASO 1: Determinando archivos de queries..."

declare -a QUERY_FILES
declare -a QUERY_NUMBERS

if [ "$RUN_ALL_INSTANCES" = true ] && [ -z "$QUERY_FILE" ]; then
    # Buscar las 5 instancias de queries
    log_info "Buscando las 5 instancias de queries para ${DIMENSIONS}d..."
    
    for i in 1 2 3 4 5; do
        QFILE="$PROJECT_ROOT/queries/vectors/nn/100q_${DIMENSIONS}d_${i}"
        if [ -f "$QFILE" ]; then
            QUERY_FILES+=("$QFILE")
            QUERY_NUMBERS+=("$i")
            log_success "  Encontrado: 100q_${DIMENSIONS}d_${i}"
        else
            log_warn "  No encontrado: 100q_${DIMENSIONS}d_${i}"
        fi
    done
    
    if [ ${#QUERY_FILES[@]} -eq 0 ]; then
        log_error "No se encontraron archivos de queries para ${DIMENSIONS}d"
        exit 1
    fi
    
    log_info "Total de instancias encontradas: ${#QUERY_FILES[@]}"
    
elif [ -n "$QUERY_FILE" ]; then
    # Usar archivo específico
    if [ ! -f "$QUERY_FILE" ]; then
        log_error "Archivo de queries no encontrado: $QUERY_FILE"
        exit 1
    fi
    QUERY_FILES=("$QUERY_FILE")
    QUERY_BASENAME=$(basename "$QUERY_FILE")
    QUERY_NUM=$(echo "$QUERY_BASENAME" | grep -oP '\d+$')
    QUERY_NUMBERS=("${QUERY_NUM:-1}")
    log_info "Usando archivo específico: $QUERY_FILE"
    
else
    # Buscar el primer archivo disponible
    QUERY_PATTERN="$PROJECT_ROOT/queries/vectors/nn/*q_${DIMENSIONS}d_*"
    QFILE=$(ls $QUERY_PATTERN 2>/dev/null | head -1)
    
    if [ -z "$QFILE" ]; then
        log_error "No se encontraron queries para ${DIMENSIONS} dimensiones"
        exit 1
    fi
    
    QUERY_FILES=("$QFILE")
    QUERY_BASENAME=$(basename "$QFILE")
    QUERY_NUM=$(echo "$QUERY_BASENAME" | grep -oP '\d+$')
    QUERY_NUMBERS=("${QUERY_NUM:-1}")
    log_info "Usando primera instancia encontrada: $QFILE"
fi

###############################################################################
# PASO 2: Verificar índices base (PBI y PBIFP)
###############################################################################
log_info "PASO 2: Verificando índices base..."

if [ ! -x "build/vectors/query-pbi-vectors" ]; then
    log_error "Ejecutable query-pbi-vectors no encontrado. Compilar primero."
    exit 1
fi

# Construir UN SOLO índice PBI con el número de permutantes especificado
PBI_INDEX="$PROJECT_ROOT/index/vectors/pbi/${DATASET_NAME}_${N_PERMUTANTS}p.idx"

if [ ! -f "$PBI_INDEX" ]; then
    log_info "Construyendo índice PBI con $N_PERMUTANTS permutantes..."
    mkdir -p "$(dirname "$PBI_INDEX")"
    
    if [ ! -x "build/vectors/build-pbi-vectors" ]; then
        log_error "Ejecutable build-pbi-vectors no encontrado"
        exit 1
    fi
    
    build/vectors/build-pbi-vectors "$DATASET_PATH" "$PBI_INDEX" "$N_VECTORS" "$N_PERMUTANTS" >> "$MAIN_LOG" 2>&1
    log_success "Índice PBI creado con $N_PERMUTANTS permutantes"
else
    log_success "Índice PBI ya existe"
fi

# Construir índices PBIFP (uno por cada valor ficticio)
declare -A PBIFP_INDICES

for fict in $FICTICIOUS_VALUES; do
    PBIFP_INDEX="$PROJECT_ROOT/index/vectors/pbifp/${DATASET_NAME}_${N_PERMUTANTS}p_${fict}f.idx"
    
    if [ ! -f "$PBIFP_INDEX" ]; then
        log_info "Construyendo índice PBIFP con $N_PERMUTANTS permutantes + $fict ficticios..."
        mkdir -p "$(dirname "$PBIFP_INDEX")"
        build/vectors/build-pbifp-vectors "$DATASET_PATH" "$PBIFP_INDEX" "$N_VECTORS" "$N_PERMUTANTS" "$fict" 0 >> "$MAIN_LOG" 2>&1
        log_success "  Índice PBIFP creado: $fict ficticios"
    fi
    
    PBIFP_INDICES[$fict]="$PBIFP_INDEX"
done

log_success "Todos los índices verificados/creados"

###############################################################################
# PASO 3: Procesar cada instancia de queries
###############################################################################
log_info "PASO 3: Procesando ${#QUERY_FILES[@]} instancia(s) de queries..."

# Arrays para acumular resultados de todas las instancias
declare -A PBI_PRECISIONS_SUM
declare -A PBIFP_PRECISIONS_SUM
declare -A RESULT_COUNTS

# Inicializar contadores
for perc in $PERCENTAGES; do
    PBI_PRECISIONS_SUM[$perc]=0
    RESULT_COUNTS[$perc]=0
    for fict in $FICTICIOUS_VALUES; do
        PBIFP_PRECISIONS_SUM["${perc}_${fict}"]=0
    done
done

# Procesar cada instancia
for idx in "${!QUERY_FILES[@]}"; do
    QUERY_FILE="${QUERY_FILES[$idx]}"
    QUERY_NUM="${QUERY_NUMBERS[$idx]}"
    
    log_info ""
    log_info "=========================================="
    log_info "PROCESANDO INSTANCIA ${QUERY_NUM} ($(($idx + 1))/${#QUERY_FILES[@]})"
    log_info "=========================================="
    log_info "Queries: $(basename $QUERY_FILE)"
    
    # Buscar resultado AESA correspondiente
    EXACT_OUTPUT="$PROJECT_ROOT/output/vectors/aesa/${DIMENSIONS}d/${DIMENSIONS}d_${QUERY_NUM}"
    
    if [ ! -f "$EXACT_OUTPUT" ]; then
        log_error "Resultados AESA no encontrados: $EXACT_OUTPUT"
        log_error "Saltando instancia $QUERY_NUM"
        continue
    fi
    
    log_success "AESA: ${DIMENSIONS}d_${QUERY_NUM}"
    
    # Crear subdirectorio para esta instancia
    mkdir -p "$OUTPUT_DIR/instance_${QUERY_NUM}/pbi"
    mkdir -p "$OUTPUT_DIR/instance_${QUERY_NUM}/pbifp"
    
    # Ejecutar queries PBI
    log_info "Ejecutando queries PBI..."
    declare -A PBI_RESULTS_INST
    
    for perc in $PERCENTAGES; do
        perc_decimal=$(echo "scale=2; $perc / 100" | bc)
        
        PBI_OUTPUT="$OUTPUT_DIR/instance_${QUERY_NUM}/pbi/pbi_${perc}p.txt"
        build/vectors/query-pbi-vectors "$PBI_INDEX" "$perc_decimal" < "$QUERY_FILE" > "$PBI_OUTPUT" 2>> "$MAIN_LOG"
        
        PBI_RESULTS_INST[$perc]="$PBI_OUTPUT"
    done
    
    # Ejecutar queries PBIFP
    log_info "Ejecutando queries PBIFP..."
    declare -A PBIFP_RESULTS_INST
    
    for perc in $PERCENTAGES; do
        perc_decimal=$(echo "scale=2; $perc / 100" | bc)
        
        for fict in $FICTICIOUS_VALUES; do
            PBIFP_INDEX="${PBIFP_INDICES[$fict]}"
            PBIFP_OUTPUT="$OUTPUT_DIR/instance_${QUERY_NUM}/pbifp/pbifp_${perc}p_${fict}f.txt"
            build/vectors/query-pbifp-vectors "$PBIFP_INDEX" "$perc_decimal" < "$QUERY_FILE" > "$PBIFP_OUTPUT" 2>> "$MAIN_LOG"
            
            PBIFP_RESULTS_INST["${perc}_${fict}"]="$PBIFP_OUTPUT"
        done
    done
    
    # Comparar resultados de esta instancia
    log_info "Comparando resultados de instancia $QUERY_NUM..."
    
    for perc in $PERCENTAGES; do
        result_file="${PBI_RESULTS_INST[$perc]}"
        
        if [ -f "$result_file" ]; then
            precision=$(python src/compare_knn_results.py "$EXACT_OUTPUT" "$result_file" "$K_VALUE")
            PBI_PRECISIONS_SUM[$perc]=$(echo "${PBI_PRECISIONS_SUM[$perc]} + $precision" | bc)
            RESULT_COUNTS[$perc]=$((${RESULT_COUNTS[$perc]} + 1))
            log_info "  PBI ${perc}%: ${precision}%"
        fi
    done
    
    for perc in $PERCENTAGES; do
        for fict in $FICTICIOUS_VALUES; do
            result_file="${PBIFP_RESULTS_INST[${perc}_${fict}]}"
            
            if [ -f "$result_file" ]; then
                precision=$(python src/compare_knn_results.py "$EXACT_OUTPUT" "$result_file" "$K_VALUE")
                PBIFP_PRECISIONS_SUM["${perc}_${fict}"]=$(echo "${PBIFP_PRECISIONS_SUM[${perc}_${fict}]} + $precision" | bc)
            fi
        done
    done
    
    log_success "Instancia $QUERY_NUM completada"
done

###############################################################################
# PASO 4: Calcular promedios de todas las instancias
###############################################################################
log_info ""
log_info "=========================================="
log_info "PASO 4: Calculando promedios de ${#QUERY_FILES[@]} instancias..."
log_info "=========================================="

# Archivo CSV para PBI con promedios
PBI_CSV="$OUTPUT_DIR/comparisons/pbi_precision_avg.csv"
echo "Percentage,Precision_Avg" > "$PBI_CSV"

log_info "Promedios PBI:"
for perc in $PERCENTAGES; do
    count=${RESULT_COUNTS[$perc]}
    if [ "$count" -gt 0 ]; then
        avg=$(echo "scale=2; ${PBI_PRECISIONS_SUM[$perc]} / $count" | bc)
        echo "$perc,$avg" >> "$PBI_CSV"
        log_info "  PBI ${perc}%: ${avg}% (promedio de $count instancias)"
    fi
done

log_success "Promedios PBI guardados en: $PBI_CSV"

# Archivo CSV para PBIFP con promedios
PBIFP_CSV="$OUTPUT_DIR/comparisons/pbifp_precision_avg.csv"
echo "Percentage,Ficticious,Precision_Avg" > "$PBIFP_CSV"

log_info "Promedios PBIFP:"
for perc in $PERCENTAGES; do
    for fict in $FICTICIOUS_VALUES; do
        count=${RESULT_COUNTS[$perc]}
        if [ "$count" -gt 0 ]; then
            avg=$(echo "scale=2; ${PBIFP_PRECISIONS_SUM[${perc}_${fict}]} / $count" | bc)
            echo "$perc,$fict,$avg" >> "$PBIFP_CSV"
            log_info "  PBIFP ${perc}% ${fict}f: ${avg}%"
        fi
    done
done

log_success "Promedios PBIFP guardados en: $PBIFP_CSV"

###############################################################################
# PASO 5: Generar reporte resumido
###############################################################################
log_info "PASO 5: Generando reporte resumido..."

REPORT_FILE="$OUTPUT_DIR/reports/summary_report.txt"

{
    echo "==============================================="
    echo "REPORTE DE EXPERIMENTO"
    echo "==============================================="
    echo "Fecha: $(date)"
    echo "Dataset: $DATASET_NAME ($N_VECTORS vectores, $DIMENSIONS dimensiones)"
    echo "K: $K_VALUE"
    echo "Instancias procesadas: ${#QUERY_FILES[@]}"
    echo "Referencia: AESA (resultados exactos)"
    echo ""
    echo "-----------------------------------------------"
    echo "RESULTADOS PBI vs AESA (PROMEDIOS)"
    echo "-----------------------------------------------"
    echo "Percentage | Precision Avg"
    echo "-----------|---------------"
    
    while IFS=, read -r perc prec; do
        if [ "$perc" != "Percentage" ]; then
            printf "%10s | %13s%%\n" "$perc%" "$prec"
        fi
    done < "$PBI_CSV"
    
    echo ""
    echo "-----------------------------------------------"
    echo "RESULTADOS PBIFP vs AESA - MEJORES CONFIGS (PROMEDIOS)"
    echo "-----------------------------------------------"
    echo "Percentage | Ficticious | Precision Avg"
    echo "-----------|------------|---------------"
    
    # Encontrar mejor configuración para cada porcentaje
    for perc in $PERCENTAGES; do
        best_prec=0
        best_fict=0
        
        while IFS=, read -r p f prec; do
            if [ "$p" = "$perc" ]; then
                if (( $(echo "$prec > $best_prec" | bc -l) )); then
                    best_prec="$prec"
                    best_fict="$f"
                fi
            fi
        done < <(tail -n +2 "$PBIFP_CSV")
        
        if [ "$best_prec" != "0" ]; then
            printf "%10s | %10s | %13s%%\n" "$perc%" "$best_fict" "$best_prec"
        fi
    done
    
    echo ""
    echo "==============================================="
    echo "ARCHIVOS GENERADOS"
    echo "==============================================="
    echo "Instancias procesadas:"
    for qf in "${QUERY_FILES[@]}"; do
        echo "  - $(basename $qf)"
    done
    echo ""
    echo "Comparaciones PBI (promedios): $PBI_CSV"
    echo "Comparaciones PBIFP (promedios): $PBIFP_CSV"
    echo "Directorio de salida: $OUTPUT_DIR"
    echo ""
    
} > "$REPORT_FILE"

cat "$REPORT_FILE"
log_success "Reporte guardado en: $REPORT_FILE"

# Guardar también en el summary.txt
cat "$REPORT_FILE" >> "$SUMMARY_LOG"

###############################################################################
# FINALIZACIÓN
###############################################################################
log_info "==============================================="
log_success "EXPERIMENTO COMPLETADO"
log_info "==============================================="
log_info ""
log_info "Los resultados están disponibles en:"
log_info "  - Directorio principal: $OUTPUT_DIR"
log_info "  - CSV PBI: $PBI_CSV"
log_info "  - CSV PBIFP: $PBIFP_CSV"
log_info "  - Reporte: $REPORT_FILE"
log_info ""
log_info "Para generar gráficos, ejecuta:"
log_info "  ./scripts/vectors/generate_plots.sh $OUTPUT_DIR"
log_info ""
