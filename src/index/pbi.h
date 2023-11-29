#ifndef PBI_H
#define PBI_H

#include "../localUtils.h"
#include "index.h"
#include "../db.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/stat.h>
#include <sys/types.h>

// Function to calculate similarity between two permutations
// int *a and int *b of size n
int spearmanRho(int *a, int *b, int n);


// Structure to store an object and his permutation
typedef struct {
  int id;
  void *data;
  int *permutation;
} Object;

// Structure to store the header of the Index
typedef struct {
  char *dbname;
  int n;            // Number of permutants
  int dim;
} fileHeader;

// Pemutant Based Index
typedef struct {
  int nPermutants; // number of permutants
  Object *objects;
  int *permutans;
} PBI;


static PBI *pbi; // Store all the DB objects


int comparate(const void *a, const void *b);
void loadObjects(fileHeader *header, int nPermutans);
void calculatePermutation(double *distances, int *permutans, int *permutation, int n);
void printPBI();


#endif
