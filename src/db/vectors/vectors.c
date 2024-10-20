#include "vectors.h"

#include <fcntl.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>

DB db;
int func;

float distance(int u, int q) {
  return db.df((float *)db(u), (float *)db(q), db.coords);
}


float distanceL1(float *u, float *q, int k) {
  int i;
  float total = 0;
  for (i = 0; i < k; i++) {
    total += fabs(u[i] - q[i]);
  }
  return total;
}

float distanceL2(float *u, float *q, int k) {
  int i;
  float total = 0;
  for (i = 0; i < k; i++) {
    total += (u[i] - q[i]) * (u[i] - q[i]);
  }
  return sqrt(total);
}

float distanceInf(float *u, float *q, int k) {
  int i;
  float max = 0;
  for (i = 0; i < k; i++) {
    if (fabs(u[i] - q[i]) > max) {
      max = fabs(u[i] - q[i]);
    }
  }
  return max;
}


// Open and load the DB
int openDB(char *name) {
  FILE *f = fopen(name, "rb");
  struct stat sdata;

  stat(name, &sdata);
  fread(&func, sizeof(int), 1, f);

  if (func == 1) {
    db.df = distanceL1;
  } else if (func == 2) {
    db.df = distanceL2;
  } else if (func == 3) {
    db.df = distanceInf;
  }


  fread(&db.coords, sizeof(int), 1, f);
  db.nnums = (sdata.st_size - 2 * sizeof(int)) / sizeof(float) / db.coords;

  db.nums = malloc((db.nnums + 1) * sizeof(float) * db.coords);

  fread(db.nums + db.coords, db.nnums * sizeof(float) * db.coords, 1, f);

  fclose(f);

  return db.nnums;
}

void closeDB(void) {
  free(db.nums);
  db.nums = NULL;
}

DB *getDB(void) { 
  return &db; 
}

// Parse the query string and return the index in the DB
int parseObj(char *str) {
  float *d = db(NewObj);
  int i, step;

  for (i = 0; i < db.coords - 1; i++) {
    sscanf(str, "%f,%n", d + i, &step);
    str += step;
  }
  sscanf(str, "%f", d + i);

  return NewObj;
}


// Show the object
void printObj(int obj) {
  int i;
  float *p = db(obj);
  for (i = 0; i < db.coords - 1; i++)
    printf("%f,", p[i]);
  printf("%f\n", p[i]);
}
