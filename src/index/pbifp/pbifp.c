#include "pbifp.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "../../include/priorityQueue.h"

PBIFP * pbifp;


long long numDistances = 0;
float * distanceEvaluations = NULL;
float * distanceEvaluationsSorted = NULL;
float percentage;

// q = [5, 1, 2, 0, 3, 4]

// u = [2, 5, 1, 0, 4, 3]
int *inversePermutation(int *permutation, int n) {
  int i;
  int *inverse = malloc(sizeof(int) * n);

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
    sum += abs(i - inverse[q[i]]);
  }

  free(inverse);

  return sum;
}

int comparate(const void *a, const void *b) {
  int *_a, *_b;

  _a = (int *)a;
  _b = (int *)b;

  return (*_a - *_b);
}


float * generateByDistance(float *distances) {
  int i;
  int n = pbifp->nPermutants * pbifp->size;
  printf("n: %d\n", n);

  float *result = malloc(sizeof(float) * pbifp->nFicticious);
  // we look for the first non zero distance
  for (i = pbifp->nPermutants - 1; distanceEvaluationsSorted[i] == 0 && i < n; i++);
  printf("i: %d\n", i);

  // we calculate the pivot t
  // we let this with using just the last distance
  /*float t = (distances[n - 1] - distances[i])/((pbifp->nFicticious));*/
  float t = (distances[n - 1]) / (pbifp->nFicticious);

  for (int j  = 0; j < pbifp->nFicticious; j++) {
    result[j] = t / 2 + t * j;
  }
  return result;
}

float * generateByFrecuency(float *distances) {
  int i;
  int n = pbifp->nPermutants * pbifp->size;
  int nPer = pbifp->nPermutants;
  float *result = malloc(sizeof(float) * pbifp->nFicticious);

  // we look for the first non zero distance
  for (i = pbifp->nPermutants - 1; distanceEvaluationsSorted[i] == 0 && i < n; i++);
  int size = (n - i);

  int p = floor((double)size / pbifp->nFicticious);

  for (int j  = 0; j < pbifp->nFicticious; j++) {
    int index = p / 2 + p * j;
    result[j] = (distances[index + nPer] + distances[index + nPer + 1]) / 2;
  }
  return result;
}


Index build(char *dbname, int n, int *argc, char ***argv) {
  // ./index <data file> <index name> <n elements> <permutants> <ficticious>
  // program name, data file, index name (output), n elements, permutants
  //
  // argv[0] = ./index.out
  // argv[1] = <data file>
  // argv[2] = <index name>
  // argv[3] = <n elements>
  // argv[4] = <permutants>
  // argv[5] = <ficticious permutants>
  // argv[6] = <method>
  fileHeader *header = malloc(sizeof(fileHeader));

  header->dbname = malloc(sizeof(char) * strlen(dbname));

  strcpy(header->dbname, dbname);

  header->n = openDB(dbname);
  header->dim = getDB()->coords;

  if (n && (n < header->n)) {
    header->n = n;
  }

  pbifp = malloc(sizeof(PBIFP));
  pbifp->nPermutants = atoi((*argv)[4]);


  pbifp->nFicticious = atoi((*argv)[5]);

  pbifp->permutationSize = pbifp->nPermutants + pbifp->nFicticious;

  pbifp->permutants = malloc(sizeof(int) * (pbifp->nPermutants));
  pbifp->ficticiousDistances = malloc(sizeof(float) * pbifp->nFicticious);

  pbifp->objects = malloc(sizeof(Object) * (header->n));
  // we have to consider the index 0 is
  // the query and 1 to size are the data
  pbifp->size = header->n;

  distanceEvaluations = malloc(sizeof(float) * (pbifp->size * pbifp->nPermutants));
  distanceEvaluationsSorted = malloc(sizeof(float) * (pbifp->size * pbifp->nPermutants));

    // we have to check the arguments
  if (!atoi((*argv)[6]))
    pbifp->distanceGenerator = generateByDistance;
  else
    pbifp->distanceGenerator = generateByFrecuency;

  // We set the random seed
  srand(time(NULL));

  // We randomly generate the permutants
  // we have to avoid repetitions
  int p = 0, x = 0;
  while(p < pbifp->nPermutants) {
    int r = rand() % pbifp->size + 1;

    for (x = 0; x < p; x++){
      if (pbifp->permutants[x] == r) {
        break;
      }
    }

    if (x == p) {
      pbifp->permutants[p++] = r;
    }
  }

  // We sort the permutants
  qsort(pbifp->permutants, pbifp->nPermutants, sizeof(int), comparate);

  for (int i = 1; i <= header->n; i++) {
    pbifp->objects[i - 1].id = i;
    pbifp->objects[i - 1].permutation = malloc(sizeof(int) * pbifp->permutationSize);
    for (int j = 0; j < pbifp->permutationSize; j++) {
      pbifp->objects[i - 1].permutation[j] = j;
    }
  }

  loadObjects(header, pbifp->nPermutants);

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
  quicksort(distances, permutation, n - i);
}

void loadObjects(fileHeader *h, int nPermutants) {
  int i, k;

  float *distances = malloc(sizeof(double) * (nPermutants + pbifp->nFicticious));

  for (i = 1; i <= pbifp->size; i++) {
    for (k = 0; k < nPermutants; k++) {
      distances[k] = distance(pbifp->permutants[k], i);
      // Save the distances evaluation for every permutants
      // until we have the generated distances
      distanceEvaluationsSorted[(i - 1) * nPermutants + k] =
      distanceEvaluations[(i - 1) * nPermutants + k] = distances[k];
      numDistances++;
    }
  }

  qsort(distanceEvaluationsSorted, nPermutants * pbifp->size, sizeof(float), comparate);


  // generate the ficticious distances
  pbifp->ficticiousDistances = pbifp->distanceGenerator(distanceEvaluationsSorted);


  for (i = 0; i < pbifp->size; i++) {
    // copy the permutant distance to the object i
    memcpy(distances, distanceEvaluations + i * nPermutants, nPermutants * sizeof(float));
    // copy the ficticious distance to the object i
    memcpy(distances + nPermutants, pbifp->ficticiousDistances, pbifp->nFicticious * sizeof(float));

    // sort the distances
    quicksort(distances, pbifp->objects[i].permutation, pbifp->permutationSize);
  }

  free(distances);
  free(distanceEvaluations);
  free(distanceEvaluationsSorted);
}

void printIndexHeader(Index S) {

  printf("dbname: %s\n", ((fileHeader *)S)->dbname);
  printf("size: %d\n", pbifp->size);
  printf("dim: %d\n", ((fileHeader *)S)->dim);
  printf("nPermutants: %d\n", pbifp->nPermutants);

  for (int i = 0; i < pbifp->nPermutants; i++) {
    (i < pbifp->nPermutants - 1) ? 
      printf("%d,", pbifp->permutants[i]) :
      printf("%d\n", pbifp->permutants[i]);
  }

  printf("nFicticious: %d\n", pbifp->nFicticious); 
  for (int i = 0; i < pbifp->nFicticious; i++) {
    (i < pbifp->nFicticious - 1) ? 
      printf("%f,", pbifp->ficticiousDistances[i]) :
      printf("%f\n", pbifp->ficticiousDistances[i]);
  }

}

void printIndex(Index S) {

  printIndexHeader(S);

  for (int i = 0; i < pbifp->size; i++) {
    printf("%d\n", pbifp->objects[i].id);
    for (int j = 0; j < pbifp->permutationSize; j++) {
      if (pbifp->objects[i].permutation[j] >= pbifp->nPermutants){
        printf("\033[1;32m");
      }
      else {
        printf("\033[0m");
      }
      (j < pbifp->permutationSize - 1) ? 
        printf("%d,", pbifp->objects[i].permutation[j]) :
        printf("%d\n", pbifp->objects[i].permutation[j]);
    }
  }
}

void freeIndex(Index index, bool closedb) {
  fileHeader *header = (fileHeader *)index;
  if (closedb) {
    closeDB();
  }
  free(pbifp->permutants);
  free(pbifp->ficticiousDistances);
  for (int i = 0; i < header->n; i++) {
    free(pbifp->objects[i].permutation);
  }
  free(pbifp->objects);
  free(pbifp);
  free(header->dbname);
  free(header);
}

Index init(char *dbname, int *argc, char ***argv) { return NULL; }

void saveIndex(Index index, char *filename) {
  int i, j;
  FILE *fp;
  fileHeader *header = (fileHeader *)index;

  if (!(fp = fopen(filename, "wb"))) {
    printf("Error opening file %s\n", filename);
    exit(1);
  }

  fwrite(header->dbname, strlen(header->dbname) + 1, 1, fp);
  fwrite(&header->n, sizeof(int), 1, fp);
  fwrite(&header->dim, sizeof(int), 1, fp);
  fwrite(&pbifp->nPermutants, sizeof(int), 1, fp);
  fwrite(&pbifp->nFicticious, sizeof(int), 1, fp);

  for (i = 0; i < pbifp->nPermutants; i++) {
    fwrite(&pbifp->permutants[i], sizeof(int), 1, fp);
  }

  for (i = 0; i < pbifp->nFicticious; i++) {
    fwrite(&pbifp->ficticiousDistances[i], sizeof(float), 1, fp);

  }

  for (i = 0; i < header->n; i++) {
    for (j = 0; j < pbifp->permutationSize; j++) {
      fwrite(&pbifp->objects[i].permutation[j], sizeof(int), 1, fp);
      
    }
  }

  // name of the DB file
  // number of DB elements
  // dimension
  // number of permutations
  // number of ficticious distances
  // permutants
  // ficticious distances
  //
  // for each object
    // permutations

  fclose(fp);
}



Index loadIndex(char *filename) {
  char str[1024];
  char *ptr = str;
  int i, j;
  FILE *fp;
  fileHeader *header;
  pbifp = malloc(sizeof(PBIFP));

  if ((fp = fopen(filename, "rb")) == NULL) {
    fprintf(stderr, "Error opening file %s\n", filename);
    exit(-1);
  }

  header = malloc(sizeof(fileHeader));

  // name of the DB file
  // number of DB elements
  // dimension
  // number of permutations
  // number of ficticious distances
  // permutants
  // ficticious distances
  //
  // for each object
    // permutations
 
  while ((*ptr++ = getc(fp)));
  header->dbname = malloc(ptr - str);
  strcpy(header->dbname, str);
  /*printf("%s\n", header->dbname);*/

  fread(&header->n, sizeof(int), 1, fp);
  pbifp->size = header->n;

  /*printf("%d\n", header->n);*/

  fread(&header->dim, sizeof(int), 1, fp);

  /*printf("%d\n", header->dim);*/

  fread(&pbifp->nPermutants, sizeof(int), 1, fp);
  pbifp->permutants = malloc(sizeof(int) * pbifp->nPermutants);

  /*printf("%d\n", pbifp->nPermutants);*/

  fread(&pbifp->nFicticious, sizeof(int), 1, fp);
  pbifp->ficticiousDistances = malloc(sizeof(float) * pbifp->nFicticious);

  /*printf("%d\n", pbifp->nFicticious);*/

  pbifp->permutationSize = pbifp->nPermutants + pbifp->nFicticious;

  for (i = 0; i < pbifp->nPermutants; i++) {
    fread(&(pbifp->permutants[i]), sizeof(int), 1, fp);

    /*printf("%d ", pbifp->permutants[i]);*/
  }


  for (i = 0 ; i < pbifp->nFicticious; i++) {
    fread(&(pbifp->ficticiousDistances[i]), sizeof(float), 1, fp);

    /*printf("%f ", pbifp->ficticiousDistances[i]);*/
  }



  pbifp->objects = malloc(sizeof(Object) * header->n);

  // we read each object with id and permutation
  for (i = 0; i < header->n; i++) {
    pbifp->objects[i].id = i + 1;
    pbifp->objects[i].permutation = malloc(sizeof(int) * pbifp->permutationSize);
    for (j = 0; j < pbifp->permutationSize; j++) {
      fread(&(pbifp->objects[i].permutation[j]), sizeof(int), 1, fp);
    }
  }

  fclose(fp);
  openDB(header->dbname);

  return (Index)header;
}



int comparateObjects(const void *a, const void *b) {
  Object *_a, *_b;

  _a = (Object *)a;
  _b = (Object *)b;

  return (_a->spearmanRhoToQuery - _b->spearmanRhoToQuery);
}

// we sort the database by the spearman rho similarity
// n is the number of objects
//
// We just have to sort the pbi objects we don't have to change the ids of the
// objects in the index cause it should be inmutable in the database

void quicksort_db(int n) {
  int i, j, p;
  float t;
  Object t_object;

  if (n < 2)
    return;

  p = pbifp->objects[n / 2].spearmanRhoToQuery;

  for (i = 0, j = n - 1;; i++, j--) {
    while (pbifp->objects[i].spearmanRhoToQuery < p)
      i++;
    while (p < pbifp->objects[j].spearmanRhoToQuery)
      j--;
    if (i >= j)
      break;

    t_object = pbifp->objects[i];
    pbifp->objects[i] = pbifp->objects[j];
    pbifp->objects[j] = t_object;

  }

  quicksort_db(i);
  quicksort_db(n - i);
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

int comparateNNElems2(const void* a, const void* b) {
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

float kNNSearch(Index S, int obj, int k, bool show) {
  fileHeader *header = (fileHeader *)S;

  // We calculate the spearman rho distance between the query and the database
  int *queryPermutation = malloc(sizeof(int) * pbifp->permutationSize);
  float *distances = malloc(sizeof(float) * pbifp->permutationSize);

  // if the permutants are the first elements in the db
  // we could optimize this
  for (int i = 0; i < pbifp->permutationSize; i++) {
    queryPermutation[i] = i;
    if (i < pbifp->nPermutants) {
      distances[i] = distance(pbifp->permutants[i], NewObj);
      numDistances++;
    }
  }

  memcpy(distances + pbifp->nPermutants, pbifp->ficticiousDistances, sizeof(float) * pbifp->nFicticious);

  quicksort(distances, queryPermutation, pbifp->permutationSize);

  for (int i = 0; i < header->n; i++) {
    pbifp->objects[i].spearmanRhoToQuery = spearmanRho(
      pbifp->objects[i].permutation, queryPermutation, pbifp->permutationSize);
  }

  qsort(pbifp->objects, pbifp->size, sizeof(Object), comparateObjects);


  // we look in the 2% 3% 5% 7% 10% of the database and we add the k nearest objects
  // into the NNCandidates

  int n = pbifp->size * percentage;

  // Creation of the priorityQueue
  PQ *pq = createPQ(k, comparateNNElems, sizeof(NNelem));

  NNCandidates nn;
  nn.elements = malloc(sizeof(NNelem) * k);
  nn.k = k;
  nn.size = 0;

  for (int i = 0; i < n; i++) {
    NNelem *elem = malloc(sizeof(NNelem));
    elem->id = pbifp->objects[i].id;
    elem->dist = distance(pbifp->objects[i].id, NewObj);
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

  for (int i = 0; !isEmptyPQ(pq) && i < k; i++) {
    NNelem element = *(NNelem *)extractMaxPQ(pq);
    nn.elements[i] = element;
    nn.size++;
    /*fprintf(stdout, "distance = %f\n", element.dist);*/
  }
  qsort(nn.elements, nn.size, sizeof(NNelem), comparateNNElems2);

  for (int i = 0; i < nn.size; i++) {
    if(show)
      printObj(nn.elements[i].id);
  }

  // the first element in the NNCandidates has the farthest distance
  float r = nn.elements[nn.size - 1].dist;

  free(queryPermutation);
  free(distances);
  free(nn.elements);
  destroyPQ(pq);

  return r;
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
  int *queryPermutation = malloc(sizeof(int) * pbifp->permutationSize);
  float *distances = malloc(sizeof(float) * pbifp->permutationSize);

  for (int i = 0; i < pbifp->permutationSize; i++) {
    queryPermutation[i] = i;
    if (i < pbifp->nPermutants) {
      distances[i] = distance(pbifp->permutants[queryPermutation[i]], NewObj);
      numDistances++;
    }
  }

  memcpy(distances + pbifp->nPermutants, pbifp->ficticiousDistances, sizeof(float) * pbifp->nFicticious);

  quicksort(distances, queryPermutation, pbifp->permutationSize);

  for (int i = 0; i < header->n; i++) {
    pbifp->objects[i].spearmanRhoToQuery = spearmanRho(
      pbifp->objects[i].permutation, queryPermutation, pbifp->permutationSize);
  }

  qsort(pbifp->objects, header->n, sizeof(Object), comparateObjects);

  // We look in a percentage of the database
  // It should be an argument in this function
  int n = header->n * percentage;

  unsigned count = 0;

  for (int i = 0; i < pbifp->size && i < n; i++) {
    float distance_to_query = distance(pbifp->objects[i].id, NewObj);
    numDistances++;
    if (distance_to_query <= r) {
      count++;
      if(show)
        printObj(pbifp->objects[i].id);

    }
  }
  free(queryPermutation);
  free(distances);
  return count;
}

// void insertObject(Index S, int obj) {}

// void deleteObject(Index S, int obj, bool show) {}
