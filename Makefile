CC = gcc

CFLAGS = -Wall -Wextra -g -lm
DB_VECTORS = src/db/vectors/vectors.c
DB_DOCUMENTS = src/db/documents/documents.c
INDEX = src/index/pbi/pbi.c src/build.c
QUERY = src/index/pbi/pbi.c src/query.c
DATA_STRUCTURES = src/include/priorityQueue.c
# INCLUDE = -I include/priorityQueue.c

index-vectors:
	$(CC) $(CFLAGS) $(DB_VECTORS) $(INDEX) $(DATA_STRUCTURES) -o build/vectors/index

query-vectors:
	$(CC) $(CFLAGS) $(DB_VECTORS) $(QUERY) $(DATA_STRUCTURES) -o build/vectors/query

index-strings:
	$(CC) $(CFLAGS) $(DB_DOCUMENTS) $(INDEX) $(DATA_STRUCTURES) -o build/index

query-strings:
	$(CC) $(CFLAGS) $(DB_DOCUMENTS) $(QUERY) $(DATA_STRUCTURES) -o build/query
