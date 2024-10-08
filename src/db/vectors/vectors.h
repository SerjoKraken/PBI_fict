#ifndef DB_H
#define DB_H

#include <stdio.h>


/* Struct that defines the vectors DB 
 *  - nums: coords all together
 *  - nnums: number of vectors
 *  - coords: dimensions
 *  - df: distance function
 * */
typedef struct {
  float *nums; /* Coords all together */
  int nnums;  /* number of vectors (with space for one more at the beginning) */
  int coords; /* Dimensions */
  float (*df)(float *u, float *q, int); /* distance function */
} DB;

extern DB db;

/* Macros */

/* Get an element p from the DB */
#define db(p) (db.nums + db.coords * (int)p)

#define NewObj 0
#define NullObj (-1)

/* Open DB and read data */
int openDB(char *name);

/* Close DB*/
void closeDB(void);

float distance(int u, int q);
float _distance(int u, float *q);

/*
 * This function parse the input
 * and insert the object in the first
 * position avaliable in the DB,
 * in that position we store store the
 * query object
 * */
int parseObj(char *str);

/* Print DB*/
void printObj(int obj);


/* Get DB */
DB *getDB(void);

/* Shuffle the DB*/
void shuffle(const void *base, size_t nmemb, size_t size);


/*
 * Write DB
 * This is used for keep the order when we read
 * because we shuffle the DB when we read the data
 * and we want to keep this order when we compare
 * the recovery percentage against exact algorithms
 * */
void writeDB(char *name);

#endif
