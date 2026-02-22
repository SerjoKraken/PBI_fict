#!/bin/bash

###############################################################################
# Script para verificar que el entorno está correctamente configurado
###############################################################################

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Contadores
PASS=0
FAIL=0
WARN=0

check_pass() {
    echo -e "  ${GREEN}✓${NC} $1"
    ((PASS++))
}

check_fail() {
    echo -e "  ${RED}✗${NC} $1"
    ((FAIL++))
}

check_warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
    ((WARN++))
}

# Rutas
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      VERIFICACIÓN DEL ENTORNO DE EXPERIMENTOS                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

###############################################################################
# 1. Verificar herramientas del sistema
###############################################################################
echo -e "${BLUE}[1] Herramientas del Sistema${NC}"

if command -v gcc &> /dev/null; then
    version=$(gcc --version | head -1)
    check_pass "gcc encontrado: $version"
else
    check_fail "gcc NO encontrado (requerido para compilar)"
fi

if command -v make &> /dev/null; then
    version=$(make --version | head -1)
    check_pass "make encontrado: $version"
else
    check_fail "make NO encontrado (requerido para compilar)"
fi

if command -v python3 &> /dev/null; then
    version=$(python3 --version)
    check_pass "python3 encontrado: $version"
else
    check_fail "python3 NO encontrado (requerido para comparaciones)"
fi

if command -v bc &> /dev/null; then
    check_pass "bc encontrado (para cálculos)"
else
    check_warn "bc NO encontrado (usado en algunos scripts)"
fi

if command -v gnuplot &> /dev/null; then
    version=$(gnuplot --version | head -1)
    check_pass "gnuplot encontrado: $version"
else
    check_warn "gnuplot NO encontrado (opcional, para gráficos)"
fi

echo ""

###############################################################################
# 2. Verificar estructura de directorios
###############################################################################
echo -e "${BLUE}[2] Estructura de Directorios${NC}"

required_dirs=(
    "data/binary/vectors"
    "build/vectors"
    "src"
    "scripts/vectors"
)

for dir in "${required_dirs[@]}"; do
    if [ -d "$PROJECT_ROOT/$dir" ]; then
        check_pass "Directorio '$dir' existe"
    else
        check_fail "Directorio '$dir' NO existe"
    fi
done

# Directorios que se crearán automáticamente
optional_dirs=(
    "index/vectors/pbi"
    "index/vectors/pbifp"
    "output/vectors"
    "results/vectors"
    "graphics/vectors"
    "queries/vectors"
)

for dir in "${optional_dirs[@]}"; do
    if [ -d "$PROJECT_ROOT/$dir" ]; then
        check_pass "Directorio '$dir' existe"
    else
        check_warn "Directorio '$dir' se creará automáticamente"
    fi
done

echo ""

###############################################################################
# 3. Verificar archivos de datos
###############################################################################
echo -e "${BLUE}[3] Archivos de Datos${NC}"

data_count=$(find "$PROJECT_ROOT/data/binary/vectors" -name "*.bin" 2>/dev/null | wc -l)
if [ $data_count -gt 0 ]; then
    check_pass "Encontrados $data_count archivos .bin de datos"
    # Listar algunos
    find "$PROJECT_ROOT/data/binary/vectors" -name "*.bin" -exec basename {} \; | head -3 | while read file; do
        size=$(ls -lh "$PROJECT_ROOT/data/binary/vectors/$file" 2>/dev/null | awk '{print $5}')
        echo "    - $file ($size)"
    done
    if [ $data_count -gt 3 ]; then
        echo "    - ... y $((data_count - 3)) más"
    fi
else
    check_fail "NO se encontraron archivos de datos .bin"
    echo "    → Ejecuta: cd data/generator/vectors && ./generate_vectors_dbs.sh"
fi

echo ""

###############################################################################
# 4. Verificar archivos de consultas
###############################################################################
echo -e "${BLUE}[4] Archivos de Consultas${NC}"

if [ -d "$PROJECT_ROOT/queries/vectors/nn" ]; then
    query_count=$(find "$PROJECT_ROOT/queries/vectors/nn" -type f 2>/dev/null | wc -l)
    if [ $query_count -gt 0 ]; then
        check_pass "Encontrados $query_count archivos de consultas"
    else
        check_warn "No hay archivos de consultas (se generarán automáticamente)"
    fi
else
    check_warn "Directorio de consultas no existe (se creará automáticamente)"
fi

echo ""

###############################################################################
# 5. Verificar binarios compilados
###############################################################################
echo -e "${BLUE}[5] Binarios Compilados${NC}"

required_binaries=(
    "build/vectors/build-pbi-vectors"
    "build/vectors/build-pbifp-vectors"
    "build/vectors/query-pbi-vectors"
    "build/vectors/query-pbifp-vectors"
)

for binary in "${required_binaries[@]}"; do
    if [ -f "$PROJECT_ROOT/$binary" ] && [ -x "$PROJECT_ROOT/$binary" ]; then
        check_pass "$(basename $binary) está compilado y es ejecutable"
    else
        check_fail "$(basename $binary) NO encontrado o no es ejecutable"
        echo "    → Ejecuta: make clean && make"
    fi
done

echo ""

###############################################################################
# 6. Verificar archivos fuente
###############################################################################
echo -e "${BLUE}[6] Archivos Fuente${NC}"

key_sources=(
    "src/build.c"
    "src/query.c"
    "src/index/pbifp/pbifp.c"
    "src/index/pbi/pbi.c"
    "src/compare_knn_results.py"
)

for source in "${key_sources[@]}"; do
    if [ -f "$PROJECT_ROOT/$source" ]; then
        check_pass "$(basename $source)"
    else
        check_fail "$(basename $source) NO encontrado"
    fi
done

echo ""

###############################################################################
# 7. Verificar scripts
###############################################################################
echo -e "${BLUE}[7] Scripts de Experimentos${NC}"

scripts=(
    "scripts/vectors/run_all_experiments.sh"
    "scripts/vectors/analyze_results.sh"
    "scripts/vectors/build_pbi.sh"
    "scripts/vectors/build_pbifp.sh"
    "scripts/vectors/query_pbi.sh"
    "scripts/vectors/query_pbifp.sh"
    "scripts/vectors/clean.sh"
    "scripts/vectors/help.sh"
)

for script in "${scripts[@]}"; do
    if [ -f "$PROJECT_ROOT/$script" ]; then
        if [ -x "$PROJECT_ROOT/$script" ]; then
            check_pass "$(basename $script) (ejecutable)"
        else
            check_warn "$(basename $script) (NO ejecutable)"
            echo "    → Ejecuta: chmod +x $PROJECT_ROOT/$script"
        fi
    else
        check_fail "$(basename $script) NO encontrado"
    fi
done

echo ""

###############################################################################
# 8. Verificar Makefile
###############################################################################
echo -e "${BLUE}[8] Sistema de Compilación${NC}"

if [ -f "$PROJECT_ROOT/Makefile" ]; then
    check_pass "Makefile encontrado"
    
    # Verificar algunos targets importantes
    if grep -q "build-pbi-vectors" "$PROJECT_ROOT/Makefile"; then
        check_pass "Target 'build-pbi-vectors' definido"
    else
        check_warn "Target 'build-pbi-vectors' no encontrado"
    fi
    
    if grep -q "build-pbifp-vectors" "$PROJECT_ROOT/Makefile"; then
        check_pass "Target 'build-pbifp-vectors' definido"
    else
        check_warn "Target 'build-pbifp-vectors' no encontrado"
    fi
else
    check_fail "Makefile NO encontrado"
fi

echo ""

###############################################################################
# Resumen final
###############################################################################
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                          RESUMEN                               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

total=$((PASS + FAIL + WARN))
echo -e "  ${GREEN}✓ Pasadas:${NC}    $PASS / $total"
echo -e "  ${RED}✗ Fallidas:${NC}   $FAIL / $total"
echo -e "  ${YELLOW}⚠ Advertencias:${NC} $WARN / $total"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✓ Sistema listo para ejecutar experimentos                   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Siguiente paso:"
    echo "  ./run_all_experiments.sh"
    echo ""
    echo "O para ayuda:"
    echo "  ./help.sh"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ✗ Hay problemas que deben resolverse                         ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Acciones recomendadas:"
    
    if ! command -v gcc &> /dev/null || ! command -v make &> /dev/null; then
        echo "  1. Instalar herramientas de compilación:"
        echo "     sudo apt-get install build-essential"
    fi
    
    if ! command -v python3 &> /dev/null; then
        echo "  2. Instalar Python 3:"
        echo "     sudo apt-get install python3"
    fi
    
    binary_missing=false
    for binary in "${required_binaries[@]}"; do
        if [ ! -f "$PROJECT_ROOT/$binary" ]; then
            binary_missing=true
            break
        fi
    done
    
    if $binary_missing; then
        echo "  3. Compilar el proyecto:"
        echo "     cd $PROJECT_ROOT"
        echo "     make clean && make"
    fi
    
    if [ $data_count -eq 0 ]; then
        echo "  4. Generar datos de prueba:"
        echo "     cd data/generator/vectors"
        echo "     ./generate_vectors_dbs.sh"
    fi
    
    exit 1
fi
