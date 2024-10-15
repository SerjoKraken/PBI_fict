#ifndef BASICS_H
#define BASICS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <math.h>

typedef unsigned char byte;
typedef int bool;

#define true 1
#define false 0

#define ARRAY_SIZE(x) (sizeof(x) / sizeof(x[0]))

#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define DISTANCE(a, b) ((a) * (a) + (b) * (b))

// If the metric space is continous, use float, otherwise use int
#ifdef CONTINOUS
typedef float elementDistance;
#else
typedef int elementDistance;
#endif

// number of distance calculated
extern long long numDistances;

// number of deletions
extern long long deletions;

// Candidate element
typedef struct {
  int id;
  float dist;
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
  float dist;
} RElem;

typedef struct t_ret {
  int size;
  RElem *elements;
  float range;
} RCandidates;

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
RCandidates createRet(uint chunk);

// inserts element element in ret if is at most radius from query o
void insertRet(RCandidates *ret, int elementId, int o, elementDistance radius);

// insert element in ret
void insertRet2(RCandidates *ret, int elementId);

#endif // !
