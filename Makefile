# =============================================================================
# Makefile for PBI/PBIFP Indexing System
# =============================================================================

# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -O3 -g -std=c11
LDFLAGS = -lm
SANITIZERS = -fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer

# Optional: Enable optimizations (uncomment for production builds)
# CFLAGS += -O3 -march=native -flto

# Optional: Enable sanitizers for debugging (uncomment when debugging)
# CFLAGS += $(SANITIZERS)

# Source files
SRC_DIR = src
DB_DIR = $(SRC_DIR)/db
INDEX_DIR = $(SRC_DIR)/index
INCLUDE_DIR = $(SRC_DIR)/include

# Database sources
DB_VECTORS = $(DB_DIR)/vectors/vectors.c
DB_DOCUMENTS = $(DB_DIR)/documents/documents.c
DB_STRINGS = $(DB_DIR)/strings/strings.c

# Core sources
BUILD_SRC = $(SRC_DIR)/build.c
QUERY_SRC = $(SRC_DIR)/query.c
BASICS_SRC = $(SRC_DIR)/basics.c

# Index sources
PBI_SRC = $(INDEX_DIR)/pbi/pbi.c
PBIFP_SRC = $(INDEX_DIR)/pbifp/pbifp.c

# Data structures
PRIORITY_QUEUE = $(INCLUDE_DIR)/priorityQueue.c

# Build directories
BUILD_DIR = build
BUILD_VECTORS = $(BUILD_DIR)/vectors
BUILD_STRINGS = $(BUILD_DIR)/strings
BUILD_DOCUMENTS = $(BUILD_DIR)/documents

# Target binaries
# Vectors
BUILD_PBI_VECTORS = $(BUILD_VECTORS)/build-pbi-vectors
QUERY_PBI_VECTORS = $(BUILD_VECTORS)/query-pbi-vectors
BUILD_PBIFP_VECTORS = $(BUILD_VECTORS)/build-pbifp-vectors
QUERY_PBIFP_VECTORS = $(BUILD_VECTORS)/query-pbifp-vectors

# Strings
BUILD_PBI_STRINGS = $(BUILD_STRINGS)/build-pbi-strings
QUERY_PBI_STRINGS = $(BUILD_STRINGS)/query-pbi-strings
BUILD_PBIFP_STRINGS = $(BUILD_STRINGS)/build-pbifp-strings
QUERY_PBIFP_STRINGS = $(BUILD_STRINGS)/query-pbifp-strings

# Documents
BUILD_PBI_DOCUMENTS = $(BUILD_DOCUMENTS)/build-pbi-documents
QUERY_PBI_DOCUMENTS = $(BUILD_DOCUMENTS)/query-pbi-documents
BUILD_PBIFP_DOCUMENTS = $(BUILD_DOCUMENTS)/build-pbifp-documents
QUERY_PBIFP_DOCUMENTS = $(BUILD_DOCUMENTS)/query-pbifp-documents

# =============================================================================
# Default target
# =============================================================================
.DEFAULT_GOAL := all

.PHONY: all all-vectors all-strings all-documents clean help dirs test

# =============================================================================
# Directory creation
# =============================================================================
dirs:
	@mkdir -p $(BUILD_VECTORS)
	@mkdir -p $(BUILD_STRINGS)
	@mkdir -p $(BUILD_DOCUMENTS)

# =============================================================================
# PBI Vectors
# =============================================================================
$(BUILD_PBI_VECTORS): $(DB_VECTORS) $(BUILD_SRC) $(PRIORITY_QUEUE) $(PBI_SRC) | dirs
	@echo "Compilando: build-pbi-vectors"
	@$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)
	@echo "✓ Compilado: $@"

$(QUERY_PBI_VECTORS): $(DB_VECTORS) $(QUERY_SRC) $(PRIORITY_QUEUE) $(PBI_SRC) | dirs
	@echo "Compilando: query-pbi-vectors"
	@$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)
	@echo "✓ Compilado: $@"

# =============================================================================
# PBIFP Vectors
# =============================================================================
$(BUILD_PBIFP_VECTORS): $(DB_VECTORS) $(BUILD_SRC) $(PRIORITY_QUEUE) $(PBIFP_SRC) | dirs
	@echo "Compilando: build-pbifp-vectors"
	@$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)
	@echo "✓ Compilado: $@"

$(QUERY_PBIFP_VECTORS): $(DB_VECTORS) $(QUERY_SRC) $(PRIORITY_QUEUE) $(PBIFP_SRC) | dirs
	@echo "Compilando: query-pbifp-vectors"
	@$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)
	@echo "✓ Compilado: $@"

# =============================================================================
# PBI Strings
# =============================================================================
$(BUILD_PBI_STRINGS): $(DB_STRINGS) $(BUILD_SRC) $(PRIORITY_QUEUE) $(PBI_SRC) | dirs
	@echo "Compilando: build-pbi-strings"
	@$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)
	@echo "✓ Compilado: $@"

$(QUERY_PBI_STRINGS): $(DB_STRINGS) $(QUERY_SRC) $(PRIORITY_QUEUE) $(PBI_SRC) | dirs
	@echo "Compilando: query-pbi-strings"
	@$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)
	@echo "✓ Compilado: $@"

# =============================================================================
# PBIFP Strings
# =============================================================================
$(BUILD_PBIFP_STRINGS): $(DB_STRINGS) $(BUILD_SRC) $(PRIORITY_QUEUE) $(PBIFP_SRC) | dirs
	@echo "Compilando: build-pbifp-strings"
	@$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)
	@echo "✓ Compilado: $@"

$(QUERY_PBIFP_STRINGS): $(DB_STRINGS) $(QUERY_SRC) $(PRIORITY_QUEUE) $(PBIFP_SRC) | dirs
	@echo "Compilando: query-pbifp-strings"
	@$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)
	@echo "✓ Compilado: $@"

# =============================================================================
# PBI Documents
# =============================================================================
$(BUILD_PBI_DOCUMENTS): $(DB_DOCUMENTS) $(BUILD_SRC) $(PRIORITY_QUEUE) $(PBI_SRC) | dirs
	@echo "Compilando: build-pbi-documents"
	@$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)
	@echo "✓ Compilado: $@"

$(QUERY_PBI_DOCUMENTS): $(DB_DOCUMENTS) $(QUERY_SRC) $(PRIORITY_QUEUE) $(PBI_SRC) | dirs
	@echo "Compilando: query-pbi-documents"
	@$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)
	@echo "✓ Compilado: $@"

# =============================================================================
# PBIFP Documents
# =============================================================================
$(BUILD_PBIFP_DOCUMENTS): $(DB_DOCUMENTS) $(BUILD_SRC) $(PRIORITY_QUEUE) $(PBIFP_SRC) | dirs
	@echo "Compilando: build-pbifp-documents"
	@$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)
	@echo "✓ Compilado: $@"

$(QUERY_PBIFP_DOCUMENTS): $(DB_DOCUMENTS) $(QUERY_SRC) $(PRIORITY_QUEUE) $(PBIFP_SRC) | dirs
	@echo "Compilando: query-pbifp-documents"
	@$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)
	@echo "✓ Compilado: $@"

# =============================================================================
# Aliases for convenience
# =============================================================================
build-pbi-vectors: $(BUILD_PBI_VECTORS)
query-pbi-vectors: $(QUERY_PBI_VECTORS)
build-pbifp-vectors: $(BUILD_PBIFP_VECTORS)
query-pbifp-vectors: $(QUERY_PBIFP_VECTORS)

build-pbi-strings: $(BUILD_PBI_STRINGS)
query-pbi-strings: $(QUERY_PBI_STRINGS)
build-pbifp-strings: $(BUILD_PBIFP_STRINGS)
query-pbifp-strings: $(QUERY_PBIFP_STRINGS)

build-pbi-documents: $(BUILD_PBI_DOCUMENTS)
query-pbi-documents: $(QUERY_PBI_DOCUMENTS)
build-pbifp-documents: $(BUILD_PBIFP_DOCUMENTS)
query-pbifp-documents: $(QUERY_PBIFP_DOCUMENTS)


# =============================================================================
# Grouped targets
# =============================================================================
all-vectors: $(BUILD_PBI_VECTORS) $(QUERY_PBI_VECTORS) \
             $(BUILD_PBIFP_VECTORS) $(QUERY_PBIFP_VECTORS)
	@echo "✓ Todos los binarios de vectores compilados"

all-strings: $(BUILD_PBI_STRINGS) $(QUERY_PBI_STRINGS) \
             $(BUILD_PBIFP_STRINGS) $(QUERY_PBIFP_STRINGS)
	@echo "✓ Todos los binarios de strings compilados"

all-documents: $(BUILD_PBI_DOCUMENTS) $(QUERY_PBI_DOCUMENTS) \
               $(BUILD_PBIFP_DOCUMENTS) $(QUERY_PBIFP_DOCUMENTS)
	@echo "✓ Todos los binarios de documents compilados"

all: all-vectors all-strings all-documents
	@echo ""
	@echo "╔════════════════════════════════════════════════════════╗"
	@echo "║     ✓ Compilación completada exitosamente            ║"
	@echo "╚════════════════════════════════════════════════════════╝"

# =============================================================================
# Cleaning
# =============================================================================
clean:
	@echo "Limpiando archivos binarios..."
	@rm -f $(BUILD_VECTORS)/*
	@rm -f $(BUILD_STRINGS)/*
	@rm -f $(BUILD_DOCUMENTS)/*
	@echo "✓ Limpieza completada"

# Clean all build artifacts and generated files
distclean: clean
	@echo "Limpieza profunda..."
	@rm -rf $(BUILD_DIR)
	@rm -rf index/vectors/* index/strings/* index/documents/* 2>/dev/null || true
	@rm -rf output/vectors/* output/strings/* output/documents/* 2>/dev/null || true
	@echo "✓ Limpieza profunda completada"

# =============================================================================
# Rebuild everything
# =============================================================================
rebuild: clean all

# =============================================================================
# Help
# =============================================================================
help:
	@echo "╔════════════════════════════════════════════════════════╗"
	@echo "║        Makefile - Sistema PBI/PBIFP                   ║"
	@echo "╚════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "Objetivos principales:"
	@echo "  make                    Compilar todo"
	@echo "  make all                Compilar todo"
	@echo "  make all-vectors        Compilar solo vectores"
	@echo "  make all-strings        Compilar solo strings"
	@echo "  make all-documents      Compilar solo documents"
	@echo ""
	@echo "Binarios individuales - Vectores:"
	@echo "  make build-pbi-vectors"
	@echo "  make query-pbi-vectors"
	@echo "  make build-pbifp-vectors"
	@echo "  make query-pbifp-vectors"
	@echo ""
	@echo "Binarios individuales - Strings:"
	@echo "  make build-pbi-strings"
	@echo "  make query-pbi-strings"
	@echo "  make build-pbifp-strings"
	@echo "  make query-pbifp-strings"
	@echo ""
	@echo "Binarios individuales - Documents:"
	@echo "  make build-pbi-documents"
	@echo "  make query-pbi-documents"
	@echo "  make build-pbifp-documents"
	@echo "  make query-pbifp-documents"
	@echo ""
	@echo "Limpieza:"
	@echo "  make clean              Eliminar binarios"
	@echo "  make distclean          Limpieza profunda"
	@echo "  make rebuild            Limpiar y recompilar"
	@echo ""
	@echo "Utilidades:"
	@echo "  make help               Mostrar esta ayuda"
	@echo "  make test               Ejecutar tests básicos"
	@echo ""
	@echo "Variables de compilación:"
	@echo "  CC = $(CC)"
	@echo "  CFLAGS = $(CFLAGS)"
	@echo "  LDFLAGS = $(LDFLAGS)"
	@echo ""

# =============================================================================
# Basic tests
# =============================================================================
test: all
	@echo "Ejecutando tests básicos..."
	@echo "Verificando que los binarios existen y son ejecutables..."
	@test -x $(BUILD_PBI_VECTORS) && echo "  ✓ build-pbi-vectors" || echo "  ✗ build-pbi-vectors"
	@test -x $(QUERY_PBI_VECTORS) && echo "  ✓ query-pbi-vectors" || echo "  ✗ query-pbi-vectors"
	@test -x $(BUILD_PBIFP_VECTORS) && echo "  ✓ build-pbifp-vectors" || echo "  ✗ build-pbifp-vectors"
	@test -x $(QUERY_PBIFP_VECTORS) && echo "  ✓ query-pbifp-vectors" || echo "  ✗ query-pbifp-vectors"
	@echo "✓ Tests básicos completados"
