#pragma once

#include "pbi.h"
// #include "../localUtils.h"
#include "../db.h"
// #include "index.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


// q = [5, 1, 2, 0, 3, 4]

// u = [2, 5, 1, 0, 4, 3]

int* inversePermutation(int * permutation, int n){
  int i;
  int *inverse = malloc(sizeof(int) * n);

  for(i = 0; i < n; i++){
    inverse[permutation[i]] = i;
  }
  // 3 2 0 5 4 1
  return inverse;
}

int spearmanRho(int *u, int *q, int n){
  int sum = 0;
  int i, j;

  int* inverse = inversePermutation(u, n);

  for(i = 0; i < n; i++){
    // we calculate the difference of position between the two vectors
    sum += abs(i - inverse[q[i]]);
  }

  return sum;
}



void printPermutation(int *permutation, int n){
  int i = 0;
  printf("[");
  for(i = 0; i < n; i++){
    printf("%d,", permutation[i]);
  }
  printf("]\n");
}

Index build(char *dbname, int n, int *argc, char ***argv){
  fileHeader *header = malloc(sizeof(fileHeader));
  // header->n = n;
  header->dbname = malloc(sizeof(char) * strlen(dbname));
  strcpy((header->dbname), dbname);

  header->n = openDB("vectors.ascii"); 
  header->dim = getDB()->coords;

  // printf("nnums %d\n", n);
  // printf("Finish openDB\n");
  if (n && (n < header->n)) {
    header->n = n;
  }

  pbi = malloc(sizeof(PBI));
  pbi->nPermutants = 20; // TODO: 20 is a magic number
  pbi->permutans = malloc(sizeof(int) * 20);
  pbi->objects = malloc(sizeof(Object) * header->n);
  pbi->size = header->n;

  // printf("pbi->nPermutants %d\n", pbi->nPermutants);
  for (int i = 0; i < pbi->nPermutants; i++) {
    pbi->permutans[i] = i;
  }
  
  
  for (int i = 0; i < header->n; i++) {
    pbi->objects[i].id = i;
    pbi->objects[i].permutation = malloc(sizeof(int) * pbi->nPermutants);
    for (int j = 0; j < pbi->nPermutants; j++) {
      pbi->objects[i].permutation[j] = pbi->permutans[j];
    }
  }


  // printf("build index\n");
  loadObjects(header, pbi->nPermutants);

  // for (int i = 0; i < header->n; i++) {
  //   printf("Object %d ", i);
  //   printPermutation(pbi->objects[i].permutation, pbi->nPermutants);
  //   printf("\n");
  // }
  


  return (Index)header;

}

void insertSort(float *distances, int *permutants, int *permutation, int n){
  int i, j, p;
  float td;
  float tp;
  
  for (i = 0; i < n; i++) {
    p = i;
    for (j = i + 1; j < n; j++)
      if (distances[j] < distances[p])
        p = j;
    td = distances[p];
    distances[p] = distances[i];
    distances[i] = td;

    tp = permutation[p];
    permutation[p] = permutation[i];
    permutation[i] = tp;
  }
}

  

// We calculate the permutation sorting by the distances form every permutant
void quicksort(float *distances, int *permutants, int *permutation, int n){
  int i, j, p;
  float t;
  float tp;

  if (n < 2)
    return;
  p = distances[n / 2];
  for (i = 0, j = n - 1;; i++, j--) {
    while (distances[i] < p)
      i++;
    while (p < distances[j])
      j--;
    if (i >= j)
      break;
    t = distances[i];
    distances[i] = distances[j];
    distances[j] = t;

    tp = permutation[i];
    permutation[i] = permutation[j];
    permutation[j] = tp;
  }
  quicksort(distances, permutants, permutation, i);
  quicksort(distances + i, permutants + i, permutation, n - i);
}



void loadObjects(fileHeader *h, int nPer){
  int i, j, k;
  // TODO: 20 is a magic number
  // We use the first 20 elements as permutants


  // printf("db.nnums %d\n", db.nnums);
  // printf("db.coords %d\n", db.coords);
  // printf("db.n %d\n", h->n);
  
  float* distances = malloc(sizeof(double) * nPer);
  // printf("aux %d\n", aux);
  for (i = 0; i < pbi->size; i++) {
    pbi->objects[i].id = i;



    for(k = 0; k < nPer; k++){
      distances[k] = 0;
      // distances[j] += distance(pbi->permutans[k], j);
      // distances[k] = db.df(u, q, db.coords);
      distances[k] = distance(pbi->permutans[k], i);
      // printf("distances[%d] %f\n", k, distances[k]);
      // quicksort(double *distances, int *permutants, int *permutation, int n);
    }
    // quicksort(distances, pbi->permutans, pbi->objects[i].permutation, nPer);
    insertSort(distances, pbi->permutans, pbi->objects[i].permutation, nPer);

    // printf("[");
    // for (int j = 0; j < 20; j++) {
    // printf("%f,", distances[j]);
    // }
    // printf("]\n");
    // printPermutation(pbi->objects[i].permutation, 20);

    // TODO: We need to calculate the distances.
    // to calculate the order of the permutations
  }
}

void calculatePermutation(int *permutation, int nPer){
  int i, j, k;

  float* distances = malloc(sizeof(double) * nPer);


  for(k = 0; k < nPer; k++){
    distances[k] = 0;
    // distances[j] += distance(pbi->permutans[k], j);
    // distances[k] = db.df(u, q, db.coords);
    distances[k] = distance(pbi->permutans[k], i);
    // printf("distances[%d] %f\n", k, distances[k]);
    // quicksort(double *distances, int *permutants, int *permutation, int n);
  }
  // quicksort(distances, pbi->permutans, pbi->objects[i].permutation, nPer);
  insertSort(distances, pbi->permutans, pbi->objects[i].permutation, nPer);

}


void printPBI(){
  printf("pbi->nPermutants %d\n", pbi->nPermutants);
  printf("pbi->permutans\n");
  for(int i = 0; i < 20; i++){
    printf("%d ", pbi->permutans[i]);
  }

  printf("\n");

  for(int i = 0; i < 100; i++){
    printf("Object %d\n", i);
    for(int j = 0; j < 20; j++){
      printf("%d ", pbi->objects[i].permutation[j]);
    }
    printf("\n");
  }
}


void swap(int *a, int *b){
  int t = *a;
  *a = *b;
  *b = t;
}

void freeIndex(Index index, bool closeDB){
  fileHeader *header = (fileHeader*)index;
  free(header->dbname);
  free(header);
  if (closeDB) {
    // closeDB();
  }
  free(pbi->permutans);
  for (int i = 0; i < header->n; i++) {
    free(pbi->objects[i].permutation);
  }
  free(pbi->objects);
  free(pbi);
}

Index init(char *dbname, int *argc, char ***argv){
  return NULL;
}

void saveIndex(Index index, char *filename){
  int i, j;
  FILE *fp;
  fileHeader *header = (fileHeader*)index;

  if(!(fp = fopen(filename, "w"))){
    printf("Error opening file %s\n", filename);
    exit(1);
  } 

  header = (fileHeader*)index;
  // fwrite(header->dbname, strlen(header->dbname) + 1, 1, fp);

  printf("header->dim %d\n", header->dim);

  fwrite(&header->n, sizeof(int), 1, fp);
  fwrite(&header->dim, sizeof(int), 1, fp);
  fwrite(&pbi->nPermutants, sizeof(int), 1, fp);

  for(i = 0; i < pbi->nPermutants; i++){
    fwrite(&pbi->permutans[i], sizeof(int), 1, fp);
  }

  for(i = 0; i < header->n; i++){
    for(j = 0; j < pbi->nPermutants; j++){
      fwrite(&pbi->objects[i].permutation[j], sizeof(int), 1, fp);
    }
  }

  fclose(fp);
}

Index loadIndex(char *filename){
  char str[1024];
  char *ptr = str;
  int i, j;
  FILE *fp;
  fileHeader *header;
  pbi = malloc(sizeof(PBI));



  if((fp = fopen(filename, "r")) == NULL){
    fprintf(stderr, "Error opening file %s\n", filename);
    exit(-1);
  }

  header = malloc(sizeof(fileHeader));

  // while((*ptr++ = getc(fp)));
  header->dbname = malloc(strlen(filename) + 1);
  strcpy(header->dbname, filename);


  // fread(header->dbname, strlen(filename) + 1, 1, fp);

  // strcpy(header->dbname, str);
  fread(&header->n, sizeof(int), 1, fp);
  fread(&header->dim, sizeof(int), 1, fp);

  printf("header->n %d\n", header->n);
  printf("header->dim %d\n", header->dim);

  fread(&pbi->nPermutants, sizeof(int), 1, fp);

  printf("pbi->nPermutants %d\n", pbi->nPermutants);


  pbi->permutans = malloc(sizeof(int) * pbi->nPermutants);

  pbi->objects = malloc(sizeof(Object) * header->n);

  for(i = 0; i < pbi->nPermutants; i++){
    fread(&pbi->permutans[i], sizeof(int), 1, fp);
    printf("%d ", pbi->permutans[i]);
  }
  printf("\n");

  for(i = 0; i < header->n; i++){
    pbi->objects[i].id = i;
    pbi->objects[i].permutation = malloc(sizeof(int) * pbi->nPermutants);
    for(j = 0; j < pbi->nPermutants; j++){
      fread(&pbi->objects[i].permutation[j], sizeof(int), 1, fp);
    }
    // printPermutation(pbi->objects[i].permutation, pbi->nPermutants);
  }

  fclose(fp);
  openDB("vectors.ascii");

  return (Index)header;
}

int rangeSearch(Index S, int obj, elementDistance r, bool show, float *object){
  // we calculate the spearman rho distance between the query and the database
  // we sort the database by the spearman rho similarity
  // we return the elements with distance less than r
  printf("rangeSearch\n");
  return 0;
}


int comparate(const void *a, const void *b){
  int *_a, *_b;

  _a = (int*)a;
  _b = (int*)b;

  return (*_a - *_b);
}

float comparateFloat(const void *a, const void *b){
  float *_a, *_b;
  _a = (float*)a;
  _b = (float*)b;
  return (*_a - *_b);
}


// we sort the database by the spearman rho similarity
// n is the number of objects
void quicksort_db(int n){
  int i, j, p;
  int t;
  Object *t_object;

  if (n < 2)
    return;

  p = pbi->objects[n / 2].spearmanRhoToQuery;

  for (i = 0, j = n - 1;; i++, j--) {
    while (pbi->objects[i].spearmanRhoToQuery < p)
      i++;
    while (p < pbi->objects[j].spearmanRhoToQuery)
      j--;
    if (i >= j)
      break;

    t = pbi->objects[i].spearmanRhoToQuery;
    pbi->objects[i].spearmanRhoToQuery = pbi->objects[j].spearmanRhoToQuery;
    pbi->objects[j].spearmanRhoToQuery = t;

    t_object = &pbi->objects[i];
    pbi->objects[i] = pbi->objects[j];
    pbi->objects[j] = *t_object;

    // we have to sort the db by the spearman rho distance too

    for (int k = 0; k < getDB()->coords; k++) {
      // t = db(pbi->objects[i].id)[k];
      // db(pbi->objects[i].id)[k] = db(pbi->objects[j].id)[k];
      // db(pbi->objects[j].id)[k] = t;


      t = getDB()->nums[pbi->objects[i].id * getDB()->coords + k];
      getDB()->nums[pbi->objects[i].id * getDB()->coords + k] = getDB()->nums[pbi->objects[j].id * getDB()->coords + k];
      getDB()->nums[pbi->objects[j].id * getDB()->coords + k] = t;

      for (int l = 0; l < getDB()->coords; l++) {

      }
    }

  }

  quicksort_db(i);
  quicksort_db(n - i);


}

void quicksort_db_float(float *distances, int *ids, int n){
  int i, j, p;

  float t;
  int t_id;

  if (n < 2)
    return;
  p = distances[n / 2];
  for (i = 0, j = n - 1;; i++, j--) {
    while (distances[i] < p)
      i++;
    while (p < distances[j])
      j--;
    if (i >= j)
      break;

    t = distances[i];
    distances[i] = distances[j];
    distances[j] = t;

    t_id = ids[i];
    ids[i] = ids[j];
    ids[j] = t_id;
    // we have to sort the db by the spearman rho distance too

  }
  quicksort_db_float(distances, ids, i);
  quicksort_db_float(distances + i, ids + i, n - i);

}

float kNNSearch(Index S, int obj, int k, bool show, float *object){

  fileHeader *header = (fileHeader*)S;

  
  // We calculate the spearman rho distance between the query and the database
  int *queryPermutation = malloc(sizeof(int) * pbi->nPermutants);
  float *distances = malloc(sizeof(float) * pbi->nPermutants);


  for (int i = 0; i < pbi->nPermutants; i++) {
    queryPermutation[i] = i;
  }

  for (int i = 0; i < pbi->nPermutants; i++) {
    distances[i] = _distance(pbi->permutans[i], object);
  }

  insertSort(distances, pbi->permutans, queryPermutation, pbi->nPermutants);


  for (int i = 0; i < header->n; i++) {
    pbi->objects[i].spearmanRhoToQuery = spearmanRho(pbi->objects[i].permutation, 
                                                    queryPermutation, 
                                                    pbi->nPermutants);
  }

  quicksort_db(header->n);


  // we print the k first elements of the database with the less distance
  // assuming they are actually the k nearest neighbors
  float db_percent = 0.1;

  float dist;


  // we look in the 2% of the database and we add the k nearest objects into the NNCandidates
  

  int n = header->n * db_percent;
  
  
  NNCandidates nn;
  nn.elements = malloc(sizeof(NNelem) * n);

  nn.k = k;
  nn.size = 0;

  int i = 0;
  int j = 0;
  int *ids = malloc(sizeof(int) * n);
  float *distances_db = malloc(sizeof(float) * n);


  for (i = 0; i < n; i++) {
    ids[i] = pbi->objects[i].id;
    distances_db[i] = _distance(ids[i], object);
  }

  // we sort the ids by the distance

  quicksort_db_float(distances_db, ids, n);


  for(i = 0; i < n; i++){
    nn.elements[i].id = ids[i];
    nn.elements[i].dist = distances_db[i];
    nn.size++;
  }


  // print the NNCandidates

  for (int i = 0; i < nn.size; i++) {
    printf("NNCandidates[%d] = %d, %f\n", i, nn.elements[i].id, nn.elements[i].dist);
  }


  // we return the distance of the farthest element to simplify the latest element

  return nn.elements[nn.size - 1].dist;
  // return 0;
}




// Methods to insert and delete objects
// It is for the dynamic versions
void insertObject(Index S, int obj){

}

void deleteObject(Index S, int obj, bool show){

}
