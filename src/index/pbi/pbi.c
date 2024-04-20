
#include "pbi.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "../../include/priorityQueue.h"

// q = [5, 1, 2, 0, 3, 4]

// u = [2, 5, 1, 0, 4, 3]

long long numDistances = 0;

PBI *pbi;

int *inversePermutation(int *permutation, int n) {
  int i;
  int *inverse = (int *)malloc(sizeof(int) * n);

  for (i = 0; i < n; i++) {
    inverse[permutation[i]] = i;
  }
  // 3 2 0 5 4 1
  return inverse;
}

int spearmanRho(int *u, int *q, int n) {
  int sum = 0;
  int i;

  int *inverse = inversePermutation(u, n);

  for (i = 0; i < n; i++) {
    // we calculate the difference of position between the two vectors
    sum += abs(i - inverse[q[i]]);
  }

  free(inverse);

  return sum;
}

void printPermutation(int *permutation, int n) {
  int i = 0;
  printf("[");
  for (i = 0; i < n; i++) {
    printf("%d,", permutation[i]);
  }
  printf("]\n");
}

Index build(char *dbname, int n, int *argc, char ***argv) {
  fileHeader *header = malloc(sizeof(fileHeader));
  // header->n = n;
  header->dbname = malloc(sizeof(char) * strlen(dbname));
  strcpy((header->dbname), dbname);

  header->n = openDB(dbname);
  header->dim = getDB()->coords;

  // printf("nnums %d\n", n);
  // printf("Finish openDB\n");
  if (n && (n < header->n)) {
    header->n = n;
  }

  pbi = malloc(sizeof(PBI));
  pbi->nPermutants = atoi((*argv)[4]);
  pbi->permutants = malloc(sizeof(int) * pbi->nPermutants);
  pbi->objects = malloc(sizeof(Object) * (header->n));
  // we have to consider the index 0 is
  // the query and 1 to size are the data
  pbi->size = header->n;

  srand(time(NULL));

  for (int i = 0; i < pbi->nPermutants; i++) {
    unsigned int permutant = rand() % header->n;
    pbi->permutants[i] = permutant;
  }

  for (int i = 0; i < header->n; i++) {
    pbi->objects[i].id = i;
    pbi->objects[i].permutation = malloc(sizeof(int) * pbi->nPermutants);
    for (int j = 0; j < pbi->nPermutants; j++) {
      pbi->objects[i].permutation[j] = pbi->permutants[j];
    }
  }

  loadObjects(header, pbi->nPermutants);

  return (Index)header;
}

// distances is an array of distances
// permutants are the ids of the permutants in the pbi
// permutation is the permutation array of the object
// n is the size of the arrays
void insertSort(float *distances, int *permutation, int n) {
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
void quicksort(float *distances, int *permutation, int n) {
  int i, j;
  float p;
  float t;
  int tp;

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
  quicksort(distances, permutation, i);
  quicksort(distances + i, permutation, n - i);
}

void loadObjects(fileHeader *h, int nPer) {
  int i, k;

  float *distances = malloc(sizeof(double) * nPer);

  printf("pbi->size %d\n", pbi->size);

  for (i = 1; i <= pbi->size; i++) {
    pbi->objects[i - 1].id = i;
    //
    // printf("Object %d\n", i);
    // for (int j = 0; j < h->dim; j++) {
    //   printf("%f ", db.nums[i * h->dim + j]);
    // }
    // printf("\n");
    for (k = 0; k < nPer; k++) {
      distances[k] = distance(pbi->permutants[k], i);
      numDistances++;
    }
    // We should use quicksort instead of insertSort
    // insertSort(distances, pbi->permutans, pbi->objects[i].permutation, nPer);
    quicksort(distances, pbi->objects[i - 1].permutation, nPer);
  }
}

void printPBI() {
  printf("pbi->size %d\n", pbi->size);
  printf("pbi->nPermutants %d\n", pbi->nPermutants);
  printf("pbi->permutans\n");
  for (int i = 0; i < pbi->nPermutants; i++) {
    printf("%d ", pbi->permutants[i]);
  }

  printf("\n");
  for (int i = 0; i < pbi->size; i++) {
    printf("Object %d\n", pbi->objects[i].id);
    for (int j = 0; j < pbi->nPermutants; j++) {
      printf("%d ", pbi->objects[i].permutation[j]);
    }
    printf("\n");
  }
}

void swap(int *a, int *b) {
  int t = *a;
  *a = *b;
  *b = t;
}

void freeIndex(Index index, bool closeDB) {
  fileHeader *header = (fileHeader *)index;
  if (closeDB) {
    // closeDB();
  }
  free(pbi->permutants);
  for (int i = 0; i < header->n; i++) {
    free(pbi->objects[i].permutation);
  }
  free(pbi->objects);
  free(pbi);
  free(header->dbname);
  free(header);
}

Index init(char *dbname, int *argc, char ***argv) { return NULL; }

void saveIndex(Index index, char *filename) {
  int i, j;
  FILE *fp;
  fileHeader *header = (fileHeader *)index;

  if (!(fp = fopen(filename, "w"))) {
    printf("Error opening file %s\n", filename);
    exit(1);
  }

  header = (fileHeader *)index;
  // printf("%s\n", header->dbname);
  fwrite(header->dbname, strlen(header->dbname) + 1, 1, fp);

  // printf("header->n %d\n", header->n);
  fwrite(&header->n, sizeof(int), 1, fp);
  // printf("header->dim %d\n", header->dim);
  fwrite(&header->dim, sizeof(int), 1, fp);
  // printf("header->nPermutants %d\n", pbi->nPermutants);
  fwrite(&pbi->nPermutants, sizeof(int), 1, fp);

  for (i = 0; i < pbi->nPermutants; i++) {
    // printf("%d ", pbi->permutans[i]);
    fwrite(&pbi->permutants[i], sizeof(int), 1, fp);
  }
  // printf("\n");

  for (i = 0; i < header->n; i++) {
    fwrite(&pbi->objects[i].id, sizeof(int), 1, fp);
    for (j = 0; j < pbi->nPermutants; j++) {
      fwrite(&pbi->objects[i].permutation[j], sizeof(int), 1, fp);
      // printf("%d ", pbi->objects[i].permutation[j]);
    }
    // printf("\n");
  }

  fclose(fp);
}

Index loadIndex(char *filename) {
  char str[1024];
  char *ptr = str;
  int i, j;
  FILE *fp;
  fileHeader *header;
  pbi = malloc(sizeof(PBI));

  if ((fp = fopen(filename, "r")) == NULL) {
    fprintf(stderr, "Error opening file %s\n", filename);
    exit(-1);
  }

  header = malloc(sizeof(fileHeader));

  while ((*ptr++ = getc(fp)))
    ;
  header->dbname = malloc(ptr - str);

  strcpy(header->dbname, str);

  // we read the n elements
  fread(&header->n, sizeof(int), 1, fp);
  pbi->size = header->n;
  // read the dimension of the database
  fread(&header->dim, sizeof(int), 1, fp);

  // read the number of permutants
  fread(&pbi->nPermutants, sizeof(int), 1, fp);

  pbi->permutants = malloc(sizeof(int) * pbi->nPermutants);
  pbi->objects = malloc(sizeof(Object) * header->n);

  // read the list with permutants
  for (i = 0; i < pbi->nPermutants; i++) {
    fread(&pbi->permutants[i], sizeof(int), 1, fp);
  }

  // we read each object with id and permutation
  for (i = 0; i < header->n; i++) {
    // pbi->objects[i].id = i;
    fread(&(pbi->objects[i].id), sizeof(int), 1, fp);
    pbi->objects[i].permutation = malloc(sizeof(int) * pbi->nPermutants);
    // for (j = 0; j < pbi->nPermutants; j++) {
    fread(pbi->objects[i].permutation, sizeof(int), pbi->nPermutants, fp);
    // }
  }

  fclose(fp);
  openDB(header->dbname);

  return (Index)header;
}

int comparateInt(Item a, Item b) {
  int *_a, *_b;
  _a = (int *)a;
  _b = (int *)b;
  return (*_a - *_b);
}

int comparate(const void *a, const void *b) {
  int *_a, *_b;

  _a = (int *)a;
  _b = (int *)b;

  return (*_a - *_b);
}

int comparateFloat(const void *a, const void *b) {
  float *_a, *_b;
  _a = (float *)a;
  _b = (float *)b;
  return (*_a - *_b);
}

int compararateObjects(const void *a, const void *b) {
  Object *_a, *_b;

  _a = (Object *)a;
  _b = (Object *)b;

  return (_a->spearmanRhoToQuery - _b->spearmanRhoToQuery);
}

bool inPermutans(int value) {
  for (int i = 0; i < pbi->nPermutants; i++) {
    if (pbi->permutants[i] == value) {
      return true;
    }
  }
  return false;
}
// we sort the database by the spearman rho similarity
// n is the number of objects
//
// We just have to sort the pbi objects we don't have to change the ids of the
// objects in the index cause it should be inmutable in the database

void quicksort_db(int n) {
  int i, j, p;
  int temp;
  float t;
  Object t_object;

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

    if (inPermutans(pbi->objects[i].id) == true) {
      // swap the value id in the list of permutants
      for (int k = 0; k < pbi->nPermutants; k++) {
        if (pbi->permutants[k] == pbi->objects[i].id) {
          pbi->permutants[k] = pbi->objects[j].id;
        }
      }
    }

    if (inPermutans(pbi->objects[i].id) == true) {
      // swap the value id in the list of permutants
      for (int k = 0; k < pbi->nPermutants; k++) {
        if (pbi->permutants[k] == pbi->objects[j].id) {
          pbi->permutants[k] = pbi->objects[i].id;
        }
      }
    }

    temp = pbi->objects[i].id;
    pbi->objects[i].id = pbi->objects[j].id;
    pbi->objects[j].id = temp;

    t_object = pbi->objects[i];
    pbi->objects[i] = pbi->objects[j];
    pbi->objects[j] = t_object;

    // we have to sort the db by the spearman rho distance too

    // swap_db (int i, int j)
    for (int k = 0; k < db.coords; k++) {
      t = db.nums[pbi->objects[i].id * db.coords + k];
      db.nums[pbi->objects[i].id * db.coords + k] =
          db.nums[pbi->objects[j].id * db.coords + k];
      db.nums[pbi->objects[j].id * db.coords + k] = t;
    }
  }

  quicksort_db(i);
  quicksort_db(n - i);
}

void quicksort_db_float(float *distances, int *ids, int n) {

  int i, j;

  float p;
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

int comparateNNElems(Item a, Item b) {
  NNelem *_a, *_b;
  _a = (NNelem *)a;
  _b = (NNelem *)b;
  if (_a->dist < _b->dist)
    return -1;
  else if (_a->dist > _b->dist)
    return 1;
  else
    return 0;
}

void printPQ(PQ *pq) {
  for (int i = 1; i <= pq->heapSize; i++) {
    // printf("%d %p\n", *(int *)pq->heap[i], pq->heap[i]);
    printf("%d %f %p %p\n", ((NNelem *)pq->heap[i])->id,
           ((NNelem *)pq->heap[i])->dist, pq->heap + i, pq->heap[i]);
  }
  printf("\n-------------------------\n");
}

// we should recieve the percentage of the database we want to look for
float kNNSearch(Index S, int obj, int k, bool show) {

  fileHeader *header = (fileHeader *)S;

  float percentages = {0.02, 0.03, 0.05, 0.07, 0.1};

  // We calculate the spearman rho distance between the query and the database
  int *queryPermutation = (int *)malloc(sizeof(int) * pbi->nPermutants);
  float *distances = (float *)malloc(sizeof(float) * pbi->nPermutants);

  for (int i = 0; i < pbi->nPermutants; i++) {
    queryPermutation[i] = pbi->permutants[i];
  }

  for (int i = 0; i < pbi->nPermutants; i++) {
    distances[i] = distance(pbi->permutants[i], NewObj);
    numDistances++;
  }

  // we should use quicksort instead of insertSort
  // insertSort(distances, pbi->permutans, queryPermutation, pbi->nPermutants);
  quicksort(distances, queryPermutation, pbi->nPermutants);
  printf("pemutation sorted\n");

  for (int i = 0; i < header->n; i++) {
    pbi->objects[i].spearmanRhoToQuery = spearmanRho(
        pbi->objects[i].permutation, queryPermutation, pbi->nPermutants);
  }

  // for (int i = 0; i < header->n; i++) {
  //   printf(
  //       "pbi->objects[%d].id = %d, pbi->objects[%d].spearmanRhoToQuery =
  //       %d\n", i, pbi->objects[i].id, i, pbi->objects[i].spearmanRhoToQuery);
  // }

  qsort(pbi->objects, header->n, sizeof(Object), compararateObjects);
  printf("Quicksort\n");

  // we print the k first elements of the database with the less distance
  // assuming they are actually the k nearest neighbors
  float db_percent = 0.1;

  // we look in the 2% 3% 5% 7% of the database and we add the k nearest objects
  // into the NNCandidates
  //

  // --------------------------------------------------------
  //
  // We have to change the way we obtain the k nearest neighbors
  // It's necessary to use a priority queue
  //
  // --------------------------------------------------------

  int n = header->n * db_percent;

  // printf("NNelem size = %lu\n", sizeof(NNelem));
  PQ *pq = createPQ(k, comparateNNElems, sizeof(NNelem));
  // printf("pq->sizeItem= %d\n", pq->sizeItem);
  //
  printf("PQ Created\n");

  // printf("n %d\n", n);

  NNCandidates nn;
  nn.elements = malloc(sizeof(NNelem) * n);

  nn.k = k;
  nn.size = 0;

  // printf("sizeof(void **) = %lu\n", sizeof(void **));
  // printf("sizeof(void *) = %lu\n", sizeof(void *));
  // printf("sizeof(NNelem) = %lu\n", sizeof(NNelem));
  // printf("sizeof(NNelem *) = %lu\n", sizeof(NNelem *));
  // printf("sizeof(int) = %lu\n", sizeof(int));
  // printf("sizeof(int *) = %lu\n", sizeof(int *));

  for (int i = 0; i < n; i++) {
    NNelem *elem = malloc(sizeof(NNelem));
    elem->id = pbi->objects[i].id;
    elem->dist = distance(pbi->objects[i].id, NewObj);
    numDistances++;
    // printf("elem->id = %d, elem->dist = %f\n", elem->id, elem->dist);
    if (pq->heapSize == k) {
      if (comparateNNElems(elem, peekPQ(pq)) < 0) {
        extractMaxPQ(pq);
        insertPQ(pq, elem);
      }
    } else {
      insertPQ(pq, elem);
    }
  }

  for (int i = 0; i < pbi->size; i++) {
    printf(
        "pbi->objects[%d].id = %d, pbi->objects[%d].spearmanRhoToQuery = %d\n",
        i, pbi->objects[i].id, i, pbi->objects[i].spearmanRhoToQuery);
  }

  for (int i = 0; !isEmptyPQ(pq) && i < n; i++) {
    NNelem element = *(NNelem *)extractMaxPQ(pq);
    printf("NNCandidates[%d] = %d, %f\n", i, element.id, element.dist);
    nn.elements[i] = element;
  }

  printf("extraction finished\n");

  destroyPQ(pq);

  return nn.elements[nn.size - 1].dist;
}

int comparateRElem(Item a, Item b) {
  RElem *_a, *_b;
  _a = (RElem *)a;
  _b = (RElem *)b;
  if (_a->dist < _b->dist)
    return -1;
  else if (_a->dist > _b->dist)
    return 1;
  else
    return 0;
}

int rangeSearch(Index S, int obj, float r, bool show) {
  // we calculate the spearman rho distance between the query and the database
  // we sort the database by the spearman rho similarity
  // we return the elements with distance less than r

  fileHeader *header = (fileHeader *)S;

  // We calculate the spearman rho distance between the query and the database
  int *queryPermutation = malloc(sizeof(int) * pbi->nPermutants);
  float *distances = malloc(sizeof(float) * pbi->nPermutants);

  for (int i = 0; i < pbi->nPermutants; i++) {
    queryPermutation[i] = pbi->permutants[i];
  }

  for (int i = 0; i < pbi->nPermutants; i++) {
    distances[i] = distance(pbi->permutants[i], NewObj);
    numDistances++;
    // distances[i] = _distance(pbi->permutans[i], object);
  }

  // insertSort(distances, pbi->permutans, queryPermutation, pbi->nPermutants);
  quicksort(distances, queryPermutation, pbi->nPermutants);

  for (int i = 0; i < header->n; i++) {
    pbi->objects[i].spearmanRhoToQuery = spearmanRho(
        pbi->objects[i].permutation, queryPermutation, pbi->nPermutants);
  }

  qsort(pbi->objects, header->n, sizeof(Object), compararateObjects);

  // We look in a percentage of the database
  float db_percent = 0.1;

  int n = header->n * db_percent;

  RCandidates rc;
  rc.elements = malloc(sizeof(RElem) * n);

  rc.size = 0;
  rc.range = r;

  // int *ids = malloc(sizeof(int) * n);
  // float *distances_db = malloc(sizeof(float) * n);
  //
  // for (i = 0; i < n; i++) {
  //   ids[i] = pbi->objects[i].id;
  //   distances_db[i] = distance(ids[i], NewObj);
  //   numDistances++;
  // }
  //
  // for (i = 0; i < n; i++) {
  //   printf("ids[%d] = %d, distances_db[%d] = %f\n", i, ids[i], i,
  //          distances_db[i]);
  // }

  // we sort the ids by the distance
  // Here we should do another strategy

  // quicksort_db_float(distances_db, ids, n);

  // for(i = 0; i < n; i++){
  //   printf("ids[%d] = %d, distances_db[%d] = %f\n", i, ids[i], i,
  //   distances_db[i]);
  // }

  for (int i = 0; i < pbi->size; i++) {
    printf(
        "pbi->objects[%d].id = %d, pbi->objects[%d].spearmanRhoToQuery = %d\n",
        i, pbi->objects[i].id, i, pbi->objects[i].spearmanRhoToQuery);
  }

  for (int i = 0; i < pbi->size && i < n; i++) {
    float distance_to_query = distance(pbi->objects[i].id, NewObj);
    numDistances++;
    if (distance_to_query <= r) {
      rc.elements[rc.size].id = pbi->objects[i].id;
      rc.elements[rc.size].dist = distance_to_query;
      rc.size++;
    }
  }

  printf("rc.size %d\n", rc.size);

  for (int i = 0; i < rc.size; i++) {
    printf("RCandidates[%d] = %d, %f\n", i, rc.elements[i].id,
           rc.elements[i].dist);
  }

  // free(ids);
  // free(distances_db);

  return rc.size;
}

// Methods to insert and delete objects
// It is for the dynamic versions
// void insertObject(Index S, int obj) {}

// void deleteObject(Index S, int obj, bool show) {}
