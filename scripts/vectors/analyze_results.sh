#!/bin/bash

###############################################################################
# Script para analizar resultados de experimentos
# 
# Genera gráficos y tablas comparativas de:
# - Precisión vs Porcentaje
# - Tiempo vs Porcentaje
# - Comparación entre métodos
###############################################################################

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# Rutas
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RESULTS_DIR="$PROJECT_ROOT/results/vectors"
GRAPHICS_DIR="$PROJECT_ROOT/graphics/vectors"

mkdir -p "$GRAPHICS_DIR"

###############################################################################
# Analizar comparaciones y generar tablas resumidas
###############################################################################
analyze_comparisons() {
    log_info "Analizando comparaciones..."
    
    for comparison_file in "$RESULTS_DIR/comparisons"/*.csv; do
        if [ ! -f "$comparison_file" ]; then continue; fi
        
        filename=$(basename "$comparison_file" .csv)
        log_info "Procesando: $filename"
        
        # Crear tabla resumida por método
        output_file="$GRAPHICS_DIR/${filename}_summary.txt"
        
        {
            echo "========================================"
            echo "RESUMEN: $filename"
            echo "========================================"
            echo ""
            
            # Agrupar por configuración y calcular promedios
            awk -F',' 'NR>1 {
                config=$1
                perc=$2
                prec=$3
                
                sum[config"_"perc] += prec
                count[config"_"perc]++
            }
            END {
                for (key in sum) {
                    split(key, parts, "_")
                    config = parts[1]
                    perc = parts[2]
                    avg = sum[key] / count[key]
                    printf "%s,%s,%.4f\n", config, perc, avg
                }
            }' "$comparison_file" | sort -t',' -k1,1 -k2,2n > "$output_file.tmp"
            
            # Formatear como tabla
            printf "%-50s | " "Configuración"
            awk -F',' '{print $2}' "$output_file.tmp" | sort -u | xargs printf "%8s "
            echo ""
            printf "%s\n" "$(printf '=%.0s' {1..150})"
            
            # Imprimir valores por configuración
            current_config=""
            while IFS=',' read -r config perc value; do
                if [ "$config" != "$current_config" ]; then
                    if [ -n "$current_config" ]; then
                        echo ""
                    fi
                    printf "%-50s | " "$config"
                    current_config="$config"
                fi
                printf "%8.4f " "$value"
            done < "$output_file.tmp"
            echo ""
            
            rm -f "$output_file.tmp"
        } | tee "$output_file"
        
        log_success "Resumen guardado en: $output_file"
    done
}

###############################################################################
# Generar archivos de datos para gnuplot
###############################################################################
generate_plot_data() {
    log_info "Generando datos para gráficos..."
    
    for comparison_file in "$RESULTS_DIR/comparisons"/*.csv; do
        if [ ! -f "$comparison_file" ]; then continue; fi
        
        filename=$(basename "$comparison_file" .csv)
        
        # Extraer datos por método para graficar
        awk -F',' 'NR>1 {
            # Extraer el método del nombre del índice
            match($1, /([0-9]+)m/, method)
            if (method[1] != "") {
                print $2, $3, method[1], $1
            }
        }' "$comparison_file" | sort -k3,3n -k1,1n > "$GRAPHICS_DIR/${filename}_plot.data"
        
        log_info "Datos de gráfico: $GRAPHICS_DIR/${filename}_plot.data"
    done
}

###############################################################################
# Generar script gnuplot
###############################################################################
generate_gnuplot_script() {
    log_info "Generando scripts de gnuplot..."
    
    for data_file in "$GRAPHICS_DIR"/*_plot.data; do
        if [ ! -f "$data_file" ]; then continue; fi
        
        base_name=$(basename "$data_file" _plot.data)
        gnuplot_script="$GRAPHICS_DIR/${base_name}.gnu"
        
        cat > "$gnuplot_script" << 'EOF'
set terminal pngcairo size 1200,800 enhanced font 'Verdana,10'
set output '${base_name}.png'

set title "${base_name} - Precision vs Percentage" font ",14"
set xlabel "Percentage"
set ylabel "Precision"

set grid
set key outside right top

set style data linespoints
set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 ps 1.5
set style line 2 lc rgb '#dd181f' lt 1 lw 2 pt 5 ps 1.5
set style line 3 lc rgb '#00a000' lt 1 lw 2 pt 9 ps 1.5

plot 'data_file' using 1:2 title 'Method 0' ls 1, \
     '' using 1:2 title 'Method 1' ls 2, \
     '' using 1:2 title 'Method 2' ls 3
EOF
        
        # Reemplazar variables
        sed -i "s|\${base_name}|$base_name|g" "$gnuplot_script"
        sed -i "s|data_file|$data_file|g" "$gnuplot_script"
        
        log_info "Script gnuplot creado: $gnuplot_script"
    done
}

###############################################################################
# Generar tabla comparativa entre PBI y PBIFP
###############################################################################
compare_pbi_pbifp() {
    log_info "Comparando PBI vs PBIFP..."
    
    output_file="$GRAPHICS_DIR/pbi_vs_pbifp_comparison.txt"
    
    {
        echo "========================================"
        echo "COMPARACIÓN PBI vs PBIFP"
        echo "========================================"
        echo ""
        
        # Buscar archivos de comparación
        pbi_file="$RESULTS_DIR/comparisons/pbi_comparison_k10.csv"
        pbifp_file="$RESULTS_DIR/comparisons/pbifp_comparison_k10.csv"
        
        if [ -f "$pbi_file" ] && [ -f "$pbifp_file" ]; then
            echo "Promedio de precisión por porcentaje:"
            echo ""
            printf "%-12s | %-12s | %-12s | %-12s\n" "Percentage" "PBI" "PBIFP (Best)" "Diferencia"
            echo "$(printf '=%.0s' {1..60})"
            
            # Calcular promedios por porcentaje
            join -t',' -1 2 -2 2 \
                <(awk -F',' 'NR>1 {sum[$2]+=$3; count[$2]++} END {for(p in sum) print p","sum[p]/count[p]}' "$pbi_file" | sort -t',' -k1,1n) \
                <(awk -F',' 'NR>1 {if($3>max[$2]) max[$2]=$3} END {for(p in max) print p","max[p]}' "$pbifp_file" | sort -t',' -k1,1n) |
                awk -F',' '{printf "%-12s | %-12.4f | %-12.4f | %+12.4f\n", $1, $2, $3, $3-$2}'
        else
            echo "Archivos de comparación no encontrados"
        fi
        
    } | tee "$output_file"
    
    log_success "Comparación guardada en: $output_file"
}

###############################################################################
# Buscar mejores configuraciones
###############################################################################
find_best_configs() {
    log_info "Buscando mejores configuraciones..."
    
    output_file="$GRAPHICS_DIR/best_configurations.txt"
    
    {
        echo "========================================"
        echo "MEJORES CONFIGURACIONES"
        echo "========================================"
        echo ""
        
        for comparison_file in "$RESULTS_DIR/comparisons"/*.csv; do
            if [ ! -f "$comparison_file" ]; then continue; fi
            
            filename=$(basename "$comparison_file" .csv)
            echo "--- $filename ---"
            
            # Top 5 configuraciones por precisión promedio
            awk -F',' 'NR>1 {
                sum[$1] += $3
                count[$1]++
            }
            END {
                for (config in sum) {
                    avg = sum[config] / count[config]
                    printf "%.6f %s\n", avg, config
                }
            }' "$comparison_file" | sort -rn | head -5 | 
                awk '{printf "  %2d. %s (Precisión: %.4f)\n", NR, $2, $1}'
            
            echo ""
        done
        
    } | tee "$output_file"
    
    log_success "Mejores configuraciones en: $output_file"
}

###############################################################################
# FUNCIÓN PRINCIPAL
###############################################################################
main() {
    log_info "========================================"
    log_info "ANÁLISIS DE RESULTADOS"
    log_info "========================================"
    
    if [ ! -d "$RESULTS_DIR/comparisons" ] || [ -z "$(ls -A "$RESULTS_DIR/comparisons" 2>/dev/null)" ]; then
        log_info "No se encontraron resultados para analizar"
        log_info "Ejecuta primero: ./run_all_experiments.sh"
        exit 0
    fi
    
    analyze_comparisons
    generate_plot_data
    generate_gnuplot_script
    compare_pbi_pbifp
    find_best_configs
    
    log_success "========================================"
    log_success "ANÁLISIS COMPLETADO"
    log_success "Ver resultados en: $GRAPHICS_DIR"
    log_success "========================================"
}

main "$@"
