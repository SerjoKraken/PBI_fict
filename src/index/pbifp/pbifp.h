#ifndef INDEX
#define INDEX

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>

#include "../../db/vectors/vectors.h"

#include "../index.h"

// Structure to store an object, his permutation and the spearman rho value

typedef struct {
  int id; // id of the object we use this to get the data from the db module
  // void *data; we don't store the data cause it's in the db module
  int *permutation;       // permutation of the object it has size = nPermutants
  int spearmanRhoToQuery; // spearman rho value to the query
} Object;

// Structure to store the header of the Index
typedef struct {
  char *dbname;
  int n;    // Number of permutants
  int size; // Number of objects
  int dim;  // dimensions
} fileHeader;

// Pemutant Based Index
typedef struct {
  int nPermutants; // number of permutants
  int nFicticious;
  Object *objects; // objects of the index
  int *permutants; // permutants of the index
  int size;        // size of the index
} PBIFP;

extern PBIFP *pbifp; // Store all the information of the index

int comparate(const void *a, const void *b);
void loadObjects(fileHeader *header, int nPermutans);
void calculatePermutation(int *permutation, int n);
void printPBI();

// Function to calculate similarity between two permutations
// int *a and int *b of size n
int spearmanRho(int *a, int *b, int n);

#endif
