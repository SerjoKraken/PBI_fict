#ifndef INDEX
#define INDEX

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>

#include "../../db/vectors/vectors.h"

#include "../index.h"

// Function to calculate similarity between two permutations
// int *a and int *b of size n
int spearmanRho(int *a, int *b, int n);

// Structure to store an object and his permutation
// It has the id of the object, the permutation of the object
// and the spearman rho value to the query
typedef struct Object {
  int id; // id of the object we use this to get the data from the db module
  // void *data; we don't store the data cause it's in the db module
  int *permutation;       // permutation of the object
  int spearmanRhoToQuery; // spearman rho value to the query
} Object;

// Structure to store the header of the Index
// It has the name of the database, the number of permutants
// and dimensions of the objects
typedef struct {
  char *dbname;
  int n;    // Number of permutants
  int size; // Number of objects
  int dim;  // dimensions
} fileHeader;

// Pemutant Based Index
// It has the number of permutants, the objects of the index,
// permutants of the index and the size of the index
typedef struct {
  int nPermutants; // number of permutants
  Object *objects; // objects of the index
  int *permutants; // permutants of the index
  int size;        // size of the index
} PBI;

extern PBI *pbi; // Store all the information of the index

int comparate(const void *a, const void *b);
void loadObjects(fileHeader *header, int nPermutans);
void calculatePermutation(int *permutation, int n);
void printPBI(Index S);

#endif
