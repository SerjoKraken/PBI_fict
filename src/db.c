#ifndef DB_C
#define DB_C


#include "db.h"
#include "localUtils.h"

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include <string.h>
#include <sys/stat.h>



float distance(int u, int q){
  return db.df(db(u), db(q), db.coords);
}

float distanceL1(float *u, float *q, int k){
  int i;
  float total = 0;
  for(i = 0; i < k; i++){
    total += fabs(u[i] - q[i]);
  }
  return total;
}



float distanceL2(float *u, float *q, int k){
  int i;
  float total = 0;
  for(i = 0; i < k; i++){
    total += (u[i] - q[i]) * (u[i] - q[i]);
  }
  return total;
}

float distanceInf(float *u, float *q, int k){
  int i;
  float max = 0;
  for(i = 0; i < k; i++){
    if (fabs(u[i] - q[i]) > max){
      max = fabs(u[i] - q[i]);
    }
  }
  return max;
}


int openDB(char *name){
  FILE *f = fopen(name, "rb");
  int func;
  struct stat sdata;

  printf("before read header\n");
  stat(name, &sdata);
  fread(&func, sizeof(int), 1, f);

  printf("after read header\n");
  /*
   * func 1 --> distance L1*/
  if (func == 1) {
    db.df = distanceL1;
  }else if (func == 2){
    printf("Distance L2\n");
    db.df = distanceL2;
  }else if (func == 3){
    printf("Infinity Distance\n");
    db.df = distanceInf;
  }

  fread(&db.coords, sizeof(int), 1, f);
  db.nnums = (sdata.st_size - 2 * sizeof(int))/sizeof(float)/db.coords;
  db.nums = malloc( (db.nnums+1) * sizeof(float) * db.coords);

  printf("nnums %d\n", db.nnums);
  printf("coords %d\n", db.coords);


  fread(db.nums, db.nnums * sizeof(float) * db.coords, db.coords, f);
  
  fclose(f);

  for(int i = 0; i < db.nnums; i++){
    for(int j = 0; j < db.coords; j++){
      printf("%lf ", *(db(i)+j));
    }
    printf("\n");
  }

  printf("db.nnums %d\n", db.nnums);

  return db.nnums;
  
}

void closeDB(void){
  free(db.nums);
  db.nums = NULL;
}

int parseObj(char *str){
  int i;
  return 0;
}
void printObj(int obj){

}

#endif
