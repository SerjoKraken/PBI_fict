#ifndef DB_H
#define DB_H


typedef struct {
  float *nums;
  int nnums;
  int coords;
  float (*df) (float *u, float *q, int); /* distance function */
}DB;

static DB db;

#define db(p) (db.nums + db.coords * (int)p)

int openDB(char *name);
void closeDB(void);

float distance(int u, int q);
int parseObj(char *str);
void printObj(int obj);

#endif
