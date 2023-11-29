#include "pbi.h"
#include "../localUtils.h"
#include "../db.h"
#include "index.h"
#include <stdio.h>
#include <string.h>

int aux = 0;

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
  header->n = n;
  header->dbname = malloc(sizeof(char) * strlen(dbname));
  strcpy((header->dbname), dbname);

  header->n = openDB("vectors.ascii"); 

  printf("nnums %d\n", n);
  printf("Finish openDB\n");
  if (n && (n < header->n)) {
    header->n = n;
  }

  pbi = malloc(sizeof(PBI));
  pbi->nPermutants = 20; // TODO: 20 is a magic number
  pbi->permutans = malloc(sizeof(int) * 20);
  pbi->objects = malloc(sizeof(Object) * header->n);

  printf("pbi->nPermutants %d\n", pbi->nPermutants);
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

  aux = header->n;

  printf("build index\n");
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

void mergeSort(float *distances, int *permutants, int *permutation, int n){
  int i, j, k;
  int m = n / 2;
  float *tmp = malloc(sizeof(float) * n);
  int *tmp2 = malloc(sizeof(int) * n);
  if (n < 2)
    return;
  mergeSort(distances, permutants, permutation, m);
  mergeSort(distances + m, permutants + m, permutation + m, n - m);
  for (i = 0; i < m; i++)
    tmp[i] = distances[i];
  for (i = m, j = n - 1; i < n; i++, j--)
    tmp[i] = distances[j];
  for (i = 0; i < m; i++)
    tmp2[i] = permutation[i];
  for (i = m, j = n - 1; i < n; i++, j--)
    tmp2[i] = permutation[j];
  i = 0;
  j = n - 1;
  for (k = 0; k < n; k++)
    if (tmp[i] < tmp[j]) {
      distances[k] = tmp[i];
      permutation[k] = tmp2[i++];
    } else {
      distances[k] = tmp[j];
      permutation[k] = tmp2[j--];
    }
  free(tmp);
  free(tmp2);
}
  

// We calculate the permutation sorting by the distances form every permutant
void quicksort(float *distances, int *permutants, int *permutation, int n){
  printf("We are in quicksort\n");
  int i, j, p, t;
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

    t = permutation[i];
    permutation[i] = permutation[j];
    permutation[j] = t;
  }
  quicksort(distances, permutants, permutation, i);
  quicksort(distances + i, permutants + i, permutation, n - i);
}


void loadObjects(fileHeader *h, int nPer){
  int i, j, k;
  float* distances = malloc(sizeof(double) * nPer);
  // TODO: 20 is a magic number
  // We use the first 20 elements as permutants


  printf("db.nnums %d\n", db.nnums);
  printf("db.coords %d\n", db.coords);
  printf("db.n %d\n", h->n);
  
  printf("aux %d\n", aux);
  for (i = 0; i < aux; i++) {
    pbi->objects[i].id = i;

    for(k = 0; k < nPer; k++){
      distances[k] = 0;
      // distances[j] += distance(pbi->permutans[k], j);
      // distances[k] = db.df(u, q, db.coords);
      distances[k] = distance(pbi->permutans[k], i);
      printf("distances[%d] %f\n", k, distances[k]);
      // quicksort(double *distances, int *permutants, int *permutation, int n);
    }
    insertSort(distances, pbi->permutans, pbi->objects[i].permutation, 20);

    printf("[");
    for (int j = 0; j < 20; j++) {
      printf("%f,", distances[j]);
    }
    printf("]\n");
    printPermutation(pbi->objects[i].permutation, 20);

    // TODO: We need to calculate the distances.
    // to calculate the order of the permutations
  }
}

void printPBI(){
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

