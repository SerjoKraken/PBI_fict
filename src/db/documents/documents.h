#ifndef DB_H
#define DB_H

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>
#include <math.h>
#include <stdio.h>


typedef struct t_vocab{
  uint id; // the id of the term
  double w; // the weight of the term
} Vocab;

typedef struct {
  char *dirname;
  char **dnames; // documents names
  uint n; // number of documents
  float (*dist)(char *, char *);
} DB;


extern DB db;

#define db(p) (db.dnames[(uint)p])

double tfdf(char *fname1, char *fname2);
float distance(uint u, uint q);

int openDB(char* name);

void closeDB();

void printObj(int ojb);


int parseObj(char *s);




#endif // !DEBUG
