
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
  int *inverse = malloc(sizeof(int) * n);

  for (i = 0; i < n; i++) {
    inverse[permutation[i] - 1] = i;
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
    sum += abs(i - inverse[q[i] - 1]);
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

  shuffle(db.nums + db.coords, db.nnums, sizeof(float) * db.coords);
  writeDB(dbname);
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

  // srand(time(NULL));
  //
  // for (int i = 0; i < pbi->nPermutants; i++) {
  //   unsigned int permutant = rand() % header->n;
  //   pbi->permutants[i] = permutant;
  // }

  // We have a shuffled DB then we could use first nPermutants objects
  // of the DB

  for (int i = 1; i <= pbi->nPermutants; i++) {
    pbi->permutants[i - 1] = i;
  }

  for (int i = 1; i <= header->n; i++) {
    pbi->objects[i - 1].id = i;
    pbi->objects[i - 1].permutation = malloc(sizeof(int) * pbi->nPermutants);
    for (int j = 0; j < pbi->nPermutants; j++) {
      pbi->objects[i - 1].permutation[j] = pbi->permutants[j];
    }
  }

  loadObjects(header, pbi->nPermutants);

  return (Index)header;
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


  for (i = 1; i <= pbi->size; i++) {
    // pbi->objects[i - 1].id = i;
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
    quicksort(distances, pbi->objects[i - 1].permutation, nPer);
  }

}

void printPBI(Index S) {
  printf("%s\n", ((fileHeader *)S)->dbname);
  printf("%d\n", pbi->size);
  printf("%d\n", ((fileHeader *)S)->dim);
  printf("%d\n", pbi->nPermutants);
  for (int i = 0; i < pbi->nPermutants; i++) {
    (i < pbi->nPermutants - 1) ? 
      printf("%d,", pbi->permutants[i]) :
      printf("%d\n", pbi->permutants[i]);
  }
  for (int i = 0; i < pbi->size; i++) {
    printf("%d\n", pbi->objects[i].id);
    for (int j = 0; j < pbi->nPermutants; j++) {
      (j < pbi->nPermutants - 1) ? 
        printf("%d,", pbi->objects[i].permutation[j]) :
        printf("%d\n", pbi->objects[i].permutation[j]);
    }
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

  // printf("%s\n", header->dbname);
  fwrite(header->dbname, strlen(header->dbname) + 1, 1, fp);

  // printf("header->n %d\n", header->n);
  fwrite(&header->n, sizeof(int), 1, fp);

  // printf("header->dim %d\n", header->dim);
  fwrite(&header->dim, sizeof(int), 1, fp);

  // printf("header->nPermutants %d\n", pbi->nPermutants);
  fwrite(&pbi->nPermutants, sizeof(int), 1, fp);

  for (i = 0; i < pbi->nPermutants; i++) {
    // printf("%d ", pbi->permutants[i]);
    fwrite(&pbi->permutants[i], sizeof(int), 1, fp);
  }

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

  while ((*ptr++ = getc(fp)));

  header->dbname = malloc(ptr - str);

  strcpy(header->dbname, str);

  fread(&header->n, sizeof(int), 1, fp);
  pbi->size = header->n;


  fread(&header->dim, sizeof(int), 1, fp);

  fread(&pbi->nPermutants, sizeof(int), 1, fp);

  pbi->permutants = malloc(sizeof(int) * pbi->nPermutants);
  pbi->objects = malloc(sizeof(Object) * header->n);

  for (i = 0; i < pbi->nPermutants; i++) {
    fread(&pbi->permutants[i], sizeof(int), 1, fp);
  }

  // we read each object with id and permutation
  for (i = 0; i < header->n; i++) {
    fread(&(pbi->objects[i].id), sizeof(int), 1, fp);
    pbi->objects[i].permutation = malloc(sizeof(int) * pbi->nPermutants);
    fread(pbi->objects[i].permutation, sizeof(int), pbi->nPermutants, fp);
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

void quicksort_pbi(Object *objects, int size) {
  Object p;
  int i, j;
  if (size < 2)
    return;

  p = objects[size / 2];

  for (i = 0, j = size - 1;; i++, j--) {
    while (objects[i].spearmanRhoToQuery < p.spearmanRhoToQuery)
      i++;
    while (p.spearmanRhoToQuery < objects[j].spearmanRhoToQuery)
      j--;
    if (i >= 1)
      break;
    p = objects[i];
    objects[i] = objects[j];
    objects[j] = p;
  }

  quicksort_pbi(objects, i);
  quicksort_pbi(objects + i, size - i);
}

float kNNSearch(Index S, int obj, int k, bool show) {

  fileHeader *header = (fileHeader *)S;
  float percentages[] = {0.02, 0.03, 0.05, 0.07, 0.1};

  // We calculate the spearman rho distance between the query and the database
  int *queryPermutation = malloc(sizeof(int) * pbi->nPermutants);
  float *distances = malloc(sizeof(float) * pbi->nPermutants);

  // if the permutants are the first elements in the db
  // we could optimize this
  for (int i = 0; i < pbi->nPermutants; i++) {
    queryPermutation[i] = pbi->permutants[i];
    distances[i] = distance(pbi->permutants[i], NewObj);
    numDistances++;
  }

  quicksort(distances, queryPermutation, pbi->nPermutants);

  for (int i = 0; i < header->n; i++) {
    pbi->objects[i].spearmanRhoToQuery = spearmanRho(
        pbi->objects[i].permutation, queryPermutation, pbi->nPermutants);
  }

  qsort(pbi->objects, pbi->size, sizeof(Object), compararateObjects);
  /*quicksort_pbi(pbi->objects, pbi->size);*/

  float db_percent = 0.1;

  // we look in the 2% 3% 5% 7% of the database and we add the k nearest objects
  // into the NNCandidates
  //

  int n = pbi->size * db_percent;

  // Creation of the priorityQueue
  PQ *pq = createPQ(k, comparateNNElems, sizeof(NNelem));

  NNCandidates nn;
  nn.elements = malloc(sizeof(NNelem) * k);
  nn.k = k;
  nn.size = 0;

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

  for (int i = k - 1; !isEmptyPQ(pq) && i >= 0; i--) {
    NNelem element = *(NNelem *)extractMaxPQ(pq);
    nn.elements[i] = element;
    nn.size++;
    if(show)
      printObj(element.id);
    /*fprintf(stdout, "distance = %f\n", element.dist);*/
  }

  destroyPQ(pq);
  free(queryPermutation);
  free(distances);

  return nn.elements[nn.k - 1].dist;
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

// we calculate the spearman rho distance between the query and the database
// we sort the database by the spearman rho similarity
// we show the elements with distance less than r
// Finally returns the number of candidates in the range r
//
int rangeSearch(Index S, int obj, float r, bool show) {
  fileHeader *header = (fileHeader *)S;
  int *queryPermutation = malloc(sizeof(int) * pbi->nPermutants);
  float *distances = malloc(sizeof(float) * pbi->nPermutants);

  for (int i = 0; i < pbi->nPermutants; i++) {
    queryPermutation[i] = pbi->permutants[i];
    distances[i] = distance(pbi->permutants[i], NewObj);
    numDistances++;
  }
  quicksort(distances, queryPermutation, pbi->nPermutants);

  for (int i = 0; i < header->n; i++) {
    pbi->objects[i].spearmanRhoToQuery = spearmanRho(
        pbi->objects[i].permutation, queryPermutation, pbi->nPermutants);
  }

  qsort(pbi->objects, header->n, sizeof(Object), compararateObjects);

  // We look in a percentage of the database
  // It should be an argument in this function
  float db_percent = 0.1;
  int n = header->n * db_percent;
  unsigned count = 0;

  for (int i = 0; i < pbi->size && i < n; i++) {
    float distance_to_query = distance(pbi->objects[i].id, NewObj);
    numDistances++;
    if (distance_to_query <= r) {
      count++;
      if(show)
        printObj(pbi->objects[i].id);
      
    }
  }
  free(queryPermutation);
  free(distances);
  return count;
}

// Methods to insert and delete objects
// It is for the dynamic versions
// void insertObject(Index S, int obj) {}

// void deleteObject(Index S, int obj, bool show) {}
