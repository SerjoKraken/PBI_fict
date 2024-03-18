CC = gcc

CFLAGS = -Wall -Wextra -g -lm

INDEX = db.c index/pbi.c main.c
QUERY = db.c index/pbi.c query.c
DATA_STRUCTURES = include/priorityQueue.c
# INCLUDE = -I include/priorityQueue.c

build:
	gcc $(CFLAGS) $(INDEX) $(DATA_STRUCTURES) -o index.out

query:
	gcc $(CFLAGS) $(QUERY) $(DATA_STRUCTURES) -o query.out
