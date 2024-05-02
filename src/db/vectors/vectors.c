#include "vectors.h"

#include <fcntl.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

DB db;
int func;

float distance(int u, int q) {
  return db.df((float *)db(u), (float *)db(q), db.coords);
}

float _distance(int u, float *q) { return db.df(db(u), q, db.coords); }

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
  return total;
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

void writeDB(char *name) {
  int file = open(name, O_TRUNC | O_WRONLY | O_CREAT, S_IREAD | S_IWRITE);

  write(file, &func, sizeof(int));
  write(file, &db.coords, sizeof(int));

  // fwrite(&db.coords, sizeof(int), 1, f);
  // fwrite(&func, sizeof(int), 1, f);

  for (int i = 1; i <= db.nnums; i++) {
    for (int j = 0; j < db.coords; j++) {
      write(file, db.nums + i * db.coords + j, sizeof(float));
    }
  }

  close(file);
}

void shuffle(const void *base, size_t nmemb, size_t size) {
  char *p = (char *)base;
  size_t i, n = nmemb * size;
  char *tmp = malloc(size);

  // We use the index 0 to store the query element in the DB
  // then we don't shuffle the index 0, it should be between 1 and n

  for (i = 0; i < nmemb; i++) {
    size_t j = rand() % nmemb;
    if (i == j)
      continue;
    memcpy(tmp, p + i * size, size);
    memcpy(p + i * size, p + j * size, size);
    memcpy(p + j * size, tmp, size);
  }
  free(tmp);
}

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
  // The index 0 is needed when we search for a
  // element who it's not in the DB
  // that's why we use a size of db.nnums + 1
  db.nums = malloc((db.nnums + 1) * sizeof(float) * db.coords);

  // fread(db.nums + db.coords + 1, db.nnums * sizeof(float) * db.coords,
  //       db.coords, f);
  fread(db.nums + db.coords, db.nnums * sizeof(float) * db.coords, db.coords,
        f);

  fclose(f);

  return db.nnums;
}

void closeDB(void) {
  free(db.nums);
  db.nums = NULL;
}

DB *getDB(void) { return &db; }

// This function parse the input
// and insert the object in the first
// position available in the DB 0
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

void printObj(int obj) {
  int i;
  float *p = db(obj);
  for (i = 0; i < db.coords - 1; i++)
    printf("%f ", p[i]);
  printf("%f\n", p[i]);
}
