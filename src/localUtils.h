#ifndef LOCALUTILS_H
#define LOCALUTILS_H


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

typedef unsigned char byte;
typedef int bool;

#define true 1
#define false 0

#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define DISTANCE(a, b) ((a)*(a) + (b)*(b))

// If the metric space is continous, use float, otherwise use int
#ifdef CONTINOUS
typedef float elementDistance;
#else 
typedef int elementDistance;
#endif

// number of distance calculated
static long long numDistances;

// number of deletions
static long long deletions;

// Candidate element
typedef struct {
  int id;
  elementDistance dist;
} NNelem;

// Candidate element list
typedef struct {
  int size;
  NNelem *elements;
  int k;
} NNCandidates;


// list of answers for range queries

typedef struct t_opair {
  int id;
  elementDistance d;
} opair;


typedef struct t_ret{
  uint chunk;
  opair *ret;
  uint iret;
} Tret;


// Creates a NNlist with size k;
NNCandidates createNNList(int k);

// adds an element to the list if it is closer
void addNNelem(NNCandidates *list, int id, elementDistance dist);

// tells if the distance is out the range of the candidates
void outNNElem(NNCandidates *list, elementDistance dist);
  
// prints the list
void showNNList(NNCandidates *list);

// gives the radius of the farthest element in NNCandidates, -1 if empty
void getRadiusNNList(NNCandidates *list);

// frees the list
void freeNNList(NNCandidates *list);


// Creates a list of answers for range queries
Tret createRet(uint chunk);

// inserts element element in ret if is at most radius from query o
void insertRet(Tret *ret, int elementId, int o, elementDistance radius);

// insert element in ret
void insertRet2(Tret *ret, int elementId);

#endif // !
