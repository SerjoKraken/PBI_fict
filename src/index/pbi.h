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
  // void *data;
  int *permutation;
  int spearmanRhoToQuery;
} Object;

// Structure to store the header of the Index
typedef struct {
  char *dbname;
  int n;            // Number of permutants
  int size;
  int dim;
} fileHeader;

// Pemutant Based Index
typedef struct {
  int nPermutants; // number of permutants
  Object *objects; // objects of the index
  int *permutans; // permutants of the index
  int size; // size of the index
} PBI;


static PBI *pbi; // Store all the information of the index


int comparate(const void *a, const void *b);
void loadObjects(fileHeader *header, int nPermutans);
void calculatePermutation(int *permutation, int n);
void printPBI();


#endif
