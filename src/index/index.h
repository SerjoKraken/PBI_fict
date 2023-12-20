#ifndef INDEX_H
#define INDEX_H

#include "../localUtils.h"


typedef void* Index;



// build index
Index build(char *dbname, int n, int *argc, char ***argv);

// initalize index
Index init(char *dbname, int *argc, char ***argv);

// frees the index and close database if closeDB
void freeIndex (Index index, bool closeDB);

// save index to file
void saveIndex(Index index, char *filename);

// load Index
Index loadIndex(char *filename); 

/*
 * range search for query obj with radius r in index S. 
 * it returns how many objects it found. it prints them if show
 * */
int rangeSearch(Index S, int obj, float r, bool show, float *object);

/*
 * kNN search for query obk in index S. It return the distance to the
* farthest object found
* */
float kNNSearch(Index S, int obj, int k, bool show, float *objetct);

/*
 * Insert an object obj in the index S.
 * This is used in the dynamic version
 * */

void insertObject(Index S, int obj);

/*
 * Delete an object obj from the index S. it prints in which
 * node was stored ovj if show
 * Used in the dynamic version
 * */
void deleteObject(Index S, int obj, bool show);


#endif // ndef INDEX_H
