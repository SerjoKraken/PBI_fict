CC = gcc

CFLAGS = -Wall -Wextra -g -lm

INDEX = db.c index/pbi.c main.c
QUERY = db.c index/pbi.c query.c

build:
	gcc $(CFLAGS) $(INDEX) -o index.out

query:
	gcc $(CFLAGS) $(QUERY) -o query.out
