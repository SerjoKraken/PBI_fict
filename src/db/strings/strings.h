#ifndef STRINGS_H
#define STRINGS_H

typedef struct {
  char *words;  /* Coords all together */
  char **ptrs;  /* Pointers to words */
  int nwords;  /* Number of words */

  int csize;

  int *c;

  int (*dist)(char*, char*);
} DB;


extern DB db;

/* Macros */

/* Get an element p from the DB */
#define db(p) (db.ptrs[(int)p])

#define NewObj 0
#define NullObj (-1)

/* Open DB and read data */
int openDB(char *name);

/* Close DB*/
void closeDB(void);

float distance(int u, int q);

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



#endif

