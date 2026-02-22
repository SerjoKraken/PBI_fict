#!/bin/bash
###############################################################################
# Quick test script to verify the automation works
# Tests with minimal configuration for faster execution
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# Get project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$PROJECT_ROOT"

log_info "========================================"
log_info "QUICK TEST - Automation Pipeline"
log_info "========================================"

# Test 1: Compilation
log_info "Test 1: Checking compilation..."
if make all-vectors > /dev/null 2>&1; then
    log_success "Compilation works"
else
    log_error "Compilation failed"
    exit 1
fi

# Test 2: Query generator
log_info "Test 2: Testing query generator..."
if [ -x "data/generator/vectors/genqueries" ]; then
    if data/generator/vectors/genqueries data/binary/vectors/10000v_128d.bin 0 2 10 0.0 > /tmp/test_queries.txt 2>/dev/null; then
        log_success "Query generator works ($(wc -l < /tmp/test_queries.txt) lines generated)"
        rm /tmp/test_queries.txt
    else
        log_error "Query generator failed"
        exit 1
    fi
else
    log_error "Query generator not found or not executable"
    exit 1
fi

# Test 3: Check datasets exist
log_info "Test 3: Checking datasets..."
dataset_count=$(ls -1 data/binary/vectors/*.bin 2>/dev/null | wc -l)
if [ $dataset_count -gt 0 ]; then
    log_success "Found $dataset_count dataset(s)"
else
    log_error "No datasets found"
    exit 1
fi

# Test 4: Build binaries exist
log_info "Test 4: Checking build binaries..."
if [ -x "build/vectors/build-pbi-vectors" ] && [ -x "build/vectors/build-pbifp-vectors" ]; then
    log_success "Build binaries exist"
else
    log_error "Build binaries not found"
    exit 1
fi

# Test 5: Query binaries exist
log_info "Test 5: Checking query binaries..."
if [ -x "build/vectors/query-pbi-vectors" ] && [ -x "build/vectors/query-pbifp-vectors" ]; then
    log_success "Query binaries exist"
else
    log_error "Query binaries not found"
    exit 1
fi

log_info "========================================"
log_success "ALL TESTS PASSED"
log_info "========================================"
log_info ""
log_info "You can now run the full automation:"
log_info "  ./scripts/vectors/run_all_experiments.sh"
log_info ""
log_info "Or for a quick test with minimal config:"
log_info "  Edit run_all_experiments.sh and reduce:"
log_info "    - DATASETS to just one file"
log_info "    - PERCENTAGES to (0.01 0.10)"
log_info "    - PBIFP_FICTICIOUS to (0 4)"
