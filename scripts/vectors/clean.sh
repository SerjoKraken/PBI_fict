#!/bin/bash

###############################################################################
# Script para limpiar archivos generados por experimentos
# Útil para empezar de cero o liberar espacio en disco
###############################################################################

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Rutas
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

###############################################################################
# Mostrar menú de opciones
###############################################################################
show_menu() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║           LIMPIEZA DE ARCHIVOS DE EXPERIMENTOS                ║
╚════════════════════════════════════════════════════════════════╝

Selecciona qué deseas limpiar:

  1) Índices PBI
  2) Índices PBIFP  
  3) Todos los índices (PBI + PBIFP)
  4) Resultados de consultas
  5) Comparaciones y reportes
  6) Gráficos
  7) Logs
  8) TODO (excepto datos originales y consultas)
  9) Mostrar uso de disco
  0) Salir

EOF
}

###############################################################################
# Funciones de limpieza
###############################################################################

clean_pbi_indexes() {
    log_info "Limpiando índices PBI..."
    if [ -d "$PROJECT_ROOT/index/vectors/pbi" ]; then
        count=$(find "$PROJECT_ROOT/index/vectors/pbi" -type f | wc -l)
        rm -rf "$PROJECT_ROOT/index/vectors/pbi"/*
        log_info "Eliminados $count índices PBI"
    else
        log_info "No hay índices PBI para limpiar"
    fi
}

clean_pbifp_indexes() {
    log_info "Limpiando índices PBIFP..."
    if [ -d "$PROJECT_ROOT/index/vectors/pbifp" ]; then
        count=$(find "$PROJECT_ROOT/index/vectors/pbifp" -type f | wc -l)
        rm -rf "$PROJECT_ROOT/index/vectors/pbifp"/*
        log_info "Eliminados $count índices PBIFP"
    else
        log_info "No hay índices PBIFP para limpiar"
    fi
}

clean_query_results() {
    log_info "Limpiando resultados de consultas..."
    if [ -d "$PROJECT_ROOT/output/vectors" ]; then
        size=$(du -sh "$PROJECT_ROOT/output/vectors" 2>/dev/null | cut -f1)
        rm -rf "$PROJECT_ROOT/output/vectors/pbi"/*
        rm -rf "$PROJECT_ROOT/output/vectors/pbifp"/*
        log_info "Liberados ~$size de resultados de consultas"
    else
        log_info "No hay resultados de consultas para limpiar"
    fi
}

clean_comparisons() {
    log_info "Limpiando comparaciones y reportes..."
    if [ -d "$PROJECT_ROOT/results/vectors" ]; then
        rm -rf "$PROJECT_ROOT/results/vectors/comparisons"/*
        rm -f "$PROJECT_ROOT/results/vectors/experiment_report.txt"
        log_info "Comparaciones y reportes eliminados"
    else
        log_info "No hay comparaciones para limpiar"
    fi
}

clean_graphics() {
    log_info "Limpiando gráficos..."
    if [ -d "$PROJECT_ROOT/graphics/vectors" ]; then
        count=$(find "$PROJECT_ROOT/graphics/vectors" -type f | wc -l)
        rm -rf "$PROJECT_ROOT/graphics/vectors"/*
        log_info "Eliminados $count archivos de gráficos"
    else
        log_info "No hay gráficos para limpiar"
    fi
}

clean_logs() {
    log_info "Limpiando logs..."
    if [ -d "$PROJECT_ROOT/results/vectors" ]; then
        rm -f "$PROJECT_ROOT/results/vectors"/*.log
        log_info "Logs eliminados"
    else
        log_info "No hay logs para limpiar"
    fi
}

clean_all() {
    log_warning "¡ADVERTENCIA! Esto eliminará TODOS los archivos generados"
    read -p "¿Estás seguro? (escribe 'SI' para confirmar): " confirm
    
    if [ "$confirm" = "SI" ]; then
        clean_pbi_indexes
        clean_pbifp_indexes
        clean_query_results
        clean_comparisons
        clean_graphics
        clean_logs
        log_info "✓ Limpieza completa finalizada"
    else
        log_info "Operación cancelada"
    fi
}

show_disk_usage() {
    log_info "Uso de disco por directorio:"
    echo ""
    
    echo "ÍNDICES:"
    if [ -d "$PROJECT_ROOT/index/vectors/pbi" ]; then
        printf "  PBI:    "
        du -sh "$PROJECT_ROOT/index/vectors/pbi" 2>/dev/null | cut -f1
        printf "          (%d archivos)\n" $(find "$PROJECT_ROOT/index/vectors/pbi" -type f 2>/dev/null | wc -l)
    fi
    if [ -d "$PROJECT_ROOT/index/vectors/pbifp" ]; then
        printf "  PBIFP:  "
        du -sh "$PROJECT_ROOT/index/vectors/pbifp" 2>/dev/null | cut -f1
        printf "          (%d archivos)\n" $(find "$PROJECT_ROOT/index/vectors/pbifp" -type f 2>/dev/null | wc -l)
    fi
    
    echo ""
    echo "RESULTADOS:"
    if [ -d "$PROJECT_ROOT/output/vectors" ]; then
        printf "  Output: "
        du -sh "$PROJECT_ROOT/output/vectors" 2>/dev/null | cut -f1
        printf "          (%d archivos)\n" $(find "$PROJECT_ROOT/output/vectors" -type f 2>/dev/null | wc -l)
    fi
    
    echo ""
    echo "ANÁLISIS:"
    if [ -d "$PROJECT_ROOT/results/vectors" ]; then
        printf "  Results: "
        du -sh "$PROJECT_ROOT/results/vectors" 2>/dev/null | cut -f1
    fi
    if [ -d "$PROJECT_ROOT/graphics/vectors" ]; then
        printf "  Graphics: "
        du -sh "$PROJECT_ROOT/graphics/vectors" 2>/dev/null | cut -f1
    fi
    
    echo ""
    echo "TOTAL USADO:"
    total=0
    for dir in index/vectors output/vectors results/vectors graphics/vectors; do
        if [ -d "$PROJECT_ROOT/$dir" ]; then
            size=$(du -sb "$PROJECT_ROOT/$dir" 2>/dev/null | cut -f1)
            total=$((total + size))
        fi
    done
    numfmt --to=iec-i --suffix=B $total
    
    echo ""
}

###############################################################################
# FUNCIÓN PRINCIPAL
###############################################################################
main() {
    while true; do
        clear
        show_menu
        read -p "Opción: " option
        
        case $option in
            1) clean_pbi_indexes ;;
            2) clean_pbifp_indexes ;;
            3) 
                clean_pbi_indexes
                clean_pbifp_indexes
                ;;
            4) clean_query_results ;;
            5) clean_comparisons ;;
            6) clean_graphics ;;
            7) clean_logs ;;
            8) clean_all ;;
            9) show_disk_usage ;;
            0) 
                log_info "Saliendo..."
                exit 0
                ;;
            *)
                log_error "Opción inválida"
                ;;
        esac
        
        echo ""
        read -p "Presiona Enter para continuar..."
    done
}

main "$@"
