CC = gcc

CFLAGS = -Wall -Wextra -g -lm
SANITIZERS = -fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer
DB_VECTORS = src/db/vectors/vectors.c
DB_DOCUMENTS = src/db/documents/documents.c
DB_STRINGS = src/db/strings/strings.c
BUILD = src/build.c
QUERY = src/query.c
PBI = src/index/pbi/pbi.c
PBIFP = src/index/pbifp/pbifp.c
DATA_STRUCTURES = src/include/priorityQueue.c
# INCLUDE = -I include/priorityQueue.c

build-pbi-vectors:
	$(CC) $(CFLAGS) $(DB_VECTORS) $(BUILD) $(DATA_STRUCTURES) $(PBI) -o build/vectors/build-pbi-vectors

query-pbi-vectors:
	$(CC) $(CFLAGS) $(DB_VECTORS) $(QUERY) $(DATA_STRUCTURES) $(PBI) -o build/vectors/query-pbi-vectors


build-pbi-strings:
	$(CC) $(CFLAGS) $(DB_STRINGS) $(BUILD) $(DATA_STRUCTURES) $(PBI) -o build/strings/build-pbi-strings

query-pbi-strings:
	$(CC) $(CFLAGS) $(DB_STRINGS) $(QUERY) $(DATA_STRUCTURES) $(PBI) -o build/strings/query-pbi-strings


build-pbi-documents:
	$(CC) $(CFLAGS) $(DB_DOCUMENTS) $(BUILD) $(DATA_STRUCTURES) $(PBI) -o build/documents/build-pbi-documents

query-pbi-documents:
	$(CC) $(CFLAGS) $(DB_DOCUMENTS) $(QUERY) $(DATA_STRUCTURES) $(PBI) -o build/documents/query-pbi-documents


build-pbifp-vectors:
	$(CC) $(CFLAGS) $(DB_VECTORS) $(BUILD) $(DATA_STRUCTURES) $(PBIFP) -o build/vectors/build-pbifp-vectors

query-pbifp-vectors:
	$(CC) $(CFLAGS) $(DB_VECTORS) $(QUERY) $(DATA_STRUCTURES) $(PBIFP) -o build/vectors/query-pbifp-vectors


build-pbifp-strings:
	$(CC) $(CFLAGS) $(DB_STRINGS) $(BUILD) $(DATA_STRUCTURES) $(PBIFP) -o build/strings/build-pbifp-strings

query-pbifp-strings:
	$(CC) $(CFLAGS) $(DB_STRINGS) $(QUERY) $(DATA_STRUCTURES) $(PBIFP) -o build/strings/query-pbifp-strings


build-pbifp-documents:
	$(CC) $(CFLAGS) $(DB_STRINGS) $(BUILD) $(DATA_STRUCTURES) $(PBIFP) -o build/documents/build-pbifp-documents

query-pbifp-documents:
	$(CC) $(CFLAGS) $(DB_STRINGS) $(QUERY) $(DATA_STRUCTURES) $(PBIFP) -o build/documents/query-pbifp-documents


all-vectors: build-pbi-vectors query-pbi-vectors \
	build-pbifp-vectors query-pbifp-vectors

all-strings: build-pbi-strings query-pbi-strings \
	build-pbifp-strings query-pbifp-strings

all-documents: build-pbi-documents query-pbi-documents \
	build-pbifp-documents query-pbifp-documents

all: all-vectors all-strings all-documents

clean:
	rm build/vectors/*
	rm build/strings/*
	rm build/documents/*
