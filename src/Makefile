CC = gcc

CFLAGS = -Wall -Wextra -g -lm
DB_VECTORS = db/vectors/vectors.c
DB_DOCUMENTS = db/documents/documents.c
INDEX = index/pbi/pbi.c build.c
QUERY = index/pbi/pbi.c query.c
DATA_STRUCTURES = include/priorityQueue.c
# INCLUDE = -I include/priorityQueue.c

build-vectors:
	$(CC) $(CFLAGS) $(DB_VECTORS) $(INDEX) $(DATA_STRUCTURES) -o index.out

build-documents:
	$(CC) $(CFLAGS) $(DB_DOCUMENTS) $(INDEX) $(DATA_STRUCTURES) -o index.out

query-vectors:
	$(CC) $(CFLAGS) $(DB_VECTORS) $(QUERY) $(DATA_STRUCTURES) -o query.out

query-documents:
	$(CC) $(CFLAGS) $(DB_DOCUMENTS) $(QUERY) $(DATA_STRUCTURES) -o query.out
