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

// u = [2, 5, 1, 0, 4, 3]

// q = [5, 1, 2, 0, 3, 4]
int *inversePermutation(int *permutation, int n) {
  int i;
  int *inverse = malloc(sizeof(int) * n);

  for (i = 0; i < n; i++) {
    inverse[permutation[i]] = i;
  }
  // u_inv = [3, 2, 0, 5, 4, 1]
  return inverse;
}

int spearmanRho(int *u, int *q, int n) {
  int sum = 0;
  int i;

  int *inverse = inversePermutation(u, n);

  for (i = 0; i < n; i++) {
    int d = i - inverse[q[i]];
    sum += d * d;
  }

  free(inverse);
  return sum;
}

int comparate(const void *a, const void *b) {
  int *_a = (int *)a;
  int *_b = (int *)b;

  return (*_a - *_b);
}

int comparateFloat(const void *a, const void * b) {
  float *_a = (float *)a;
  float *_b = (float *)b;

  if (*_a < *_b)
    return -1;
  else if (*_a > *_b)
    return 1;

  return 0;
}

float * generateByDistance(float *distances) {
  int i;
  int n = pbifp->nPermutants * pbifp->size;
  float *result = malloc(sizeof(float) * pbifp->nFicticious);

  // Buscar el primer elemento no-cero
  for (i = 0; i < n && distanceEvaluationsSorted[i] == 0; i++);

  // Calcular el paso: 1% de margen en cada extremo
  int validRange = n - i;
  int step = validRange / 100;
  if (step < 1) step = 1;

  // Tomar min y max con margen del 1%
  float min_dist = distances[i + step];
  float max_dist = distances[n - 1 - step];

  // Distribuir uniformemente los pivotes ficticios en el rango
  float t = (max_dist - min_dist) / pbifp->nFicticious;

  for (int j = 0; j < pbifp->nFicticious; j++) {
    // Centrar cada pivote en su segmento (t/2) + desplazamiento (t*j) + offset (min_dist)
    result[j] = min_dist + t / 2 + t * j;
  }

  return result;
}

float * generateByFrecuency(float *distances) {
  int i;
  int n = pbifp->nPermutants * pbifp->size;
  float *result = malloc(sizeof(float) * pbifp->nFicticious);

  // Buscar el primer elemento no-cero
  for (i = 0; i < n && distanceEvaluationsSorted[i] == 0; i++);

  int size = n - i;
  
  // Dividir el rango en segmentos iguales según la cantidad de pivotes ficticios
  int p = floor((float)size / pbifp->nFicticious);
  if (p < 1) p = 1;

  for (int j = 0; j < pbifp->nFicticious; j++) {
    // Tomar el centro de cada segmento, sumando i para offset inicial
    int index = i + p / 2 + p * j;
    
    // Verificar que no nos salgamos del rango válido
    if (index >= n - 1) {
      // Si estamos en el último elemento, usar solo ese valor
      result[j] = distances[n - 1];
    } else {
      // Promediar con el siguiente para suavizar
      result[j] = (distances[index] + distances[index + 1]) / 2.0;
    }
  }

  return result;
}

float * generateByMean(float *distances) {
  int i;
  int n = pbifp->nPermutants * pbifp->size;
  float *result = malloc(sizeof(float) * pbifp->nFicticious);

  // Buscar el primer elemento no-cero
  for (i = 0; i < n && distanceEvaluationsSorted[i] == 0; i++);

  int validSize = n - i;

  // Calcular la media de las distancias válidas
  float mean = 0;
  for (int j = i; j < n; j++) {
    mean += distances[j];
  }
  mean /= validSize;
  
  // Calcular la varianza
  float variance = 0;
  for (int j = i; j < n; j++) {
    float diff = distances[j] - mean;
    variance += diff * diff;
  }
  variance /= validSize;

  float deviation = sqrt(variance);

  // Definir rango: [media - 2σ, media + σ]
  float min_dist = mean - 2 * deviation;
  float max_dist = mean + deviation;

  // Asegurar que min_dist no sea negativo (las distancias son ≥ 0)
  if (min_dist < 0) min_dist = 0;

  // Distribuir pivotes ficticios uniformemente en el rango estadístico
  float t = (max_dist - min_dist) / pbifp->nFicticious;

  for (int j = 0; j < pbifp->nFicticious; j++) {
    // IMPORTANTE: Agregar min_dist como offset base
    result[j] = min_dist + t / 2 + t * j;
  }

  return result;
}


Index build(char *dbname, int n, int *argc, char ***argv) {
  // argv[0] = ./index.out
  // argv[1] = <data file>
  // argv[2] = <index name>
  // argv[3] = <n elements>
  // argv[4] = <permutants>
  // argv[5] = <ficticious permutants>
  // argv[6] = <method>
  fileHeader *header = malloc(sizeof(fileHeader));

  header->dbname = malloc(sizeof(char) * (strlen(dbname) + 1));

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
  pbifp->size = header->n;

  distanceEvaluations = malloc(sizeof(float) * (pbifp->size * pbifp->nPermutants));
  distanceEvaluationsSorted = malloc(sizeof(float) * (pbifp->size * pbifp->nPermutants));

    // we have to check the arguments
  if (!atoi((*argv)[6]))
    pbifp->g = generateByDistance; // distance
  else if (atoi((*argv)[6]) == 2)
    pbifp->g = generateByMean;    // mean
  else
    pbifp->g = generateByFrecuency; // frecuency

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

// We calculate the permutation sorting by the distances for every permutant
void quicksort(float *distances, int *permutation, int n) {

  if (n < 2)
    return;

  int i, j;
  float p;
  float t;
  int tp;

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
  quicksort(distances + i, permutation + i, n - i);
}

void loadObjects(fileHeader *h, int nPermutants) {
  int i, k;


  for (i = 1; i <= pbifp->size; i++) {
    for (k = 0; k < nPermutants; k++) {
      // Save the distances evaluation for every permutants
      // until we have the generated distances
      distanceEvaluationsSorted[(i - 1) * nPermutants + k] =
      distanceEvaluations[(i - 1) * nPermutants + k] = 
      distance(pbifp->permutants[k], i);
      numDistances++;
    }
  }

  qsort(distanceEvaluationsSorted, nPermutants * pbifp->size, sizeof(float), comparateFloat);

  // generate the ficticious distances
  pbifp->ficticiousDistances = pbifp->g(distanceEvaluationsSorted);

  float *distances = malloc(sizeof(float) * (nPermutants + pbifp->nFicticious));

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

  fclose(fp);
}

Index loadIndex(char *filename) {
  char str[10000];
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
 
  while ((*ptr++ = getc(fp)));
  header->dbname = malloc(ptr - str);
  strcpy(header->dbname, str);

  fread(&header->n, sizeof(int), 1, fp);
  pbifp->size = header->n;

  fread(&header->dim, sizeof(int), 1, fp);

  fread(&pbifp->nPermutants, sizeof(int), 1, fp);
  pbifp->permutants = malloc(sizeof(int) * pbifp->nPermutants);

  fread(&pbifp->nFicticious, sizeof(int), 1, fp);
  pbifp->ficticiousDistances = malloc(sizeof(float) * pbifp->nFicticious);

  pbifp->permutationSize = pbifp->nPermutants + pbifp->nFicticious;

  for (i = 0; i < pbifp->nPermutants; i++) {
    fread(&(pbifp->permutants[i]), sizeof(int), 1, fp);
  }

  for (i = 0 ; i < pbifp->nFicticious; i++) {
    fread(&(pbifp->ficticiousDistances[i]), sizeof(float), 1, fp);
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
  Object *_a = (Object *)a;
  Object *_b = (Object *)b;

  return (_a->spearmanRhoToQuery - _b->spearmanRhoToQuery);
}

int comparateNNElems(Item a, Item b) {
  NNelem *_a = (NNelem *)a;
  NNelem *_b = (NNelem *)b;

  if (_a->dist < _b->dist)
    return -1;
  else if (_a->dist > _b->dist)
    return 1;

  return 0;
}

int comparateNNElems2(const void* a, const void* b) {
  NNelem *_a = (NNelem *)a;
  NNelem *_b = (NNelem *)b;

  if (_a->dist < _b->dist)
    return -1;
  else if (_a->dist > _b->dist)
    return 1;

  return 0;
}

void printPQ(PQ *pq) {
  for (int i = 1; i <= pq->heapSize; i++) {
    printf("%d %f %p %p\n", ((NNelem *)pq->heap[i])->id,
           ((NNelem *)pq->heap[i])->dist, pq->heap + i, pq->heap[i]);
  }
  printf("\n-------------------------\n");
}

void queryPermutationProcess(int *queryPermutation, float *distances, int n) {

  for (int i = 0; i < n; i++) {
    queryPermutation[i] = i;
    if (i < pbifp->nPermutants) {
      distances[i] = distance(pbifp->permutants[i], NewObj);
      numDistances++;
    }
  }

  memcpy(distances + pbifp->nPermutants, pbifp->ficticiousDistances, sizeof(float) * pbifp->nFicticious);
  quicksort(distances, queryPermutation, n);

  // We calculate the Spearman Rho between the query and the database
  for (int i = 0; i < pbifp->size; i++) {
    pbifp->objects[i].spearmanRhoToQuery = spearmanRho(
      pbifp->objects[i].permutation, queryPermutation, n);
  }

  // We sort the database by the Spearman Rho
  qsort(pbifp->objects, pbifp->size, sizeof(Object), comparateObjects);
}

float kNNSearch(Index S, int obj, int k, bool show) {
  fileHeader *header = (fileHeader *)S;
  int *queryPermutation = malloc(sizeof(int) * pbifp->permutationSize);
  float *distances = malloc(sizeof(float) * pbifp->permutationSize);
  int n = header->n * percentage;
  NNCandidates nn;

  queryPermutationProcess(queryPermutation, distances, pbifp->permutationSize);

  PQ *pq = createPQ(k, comparateNNElems, sizeof(NNelem));

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
        free(extractMaxPQ(pq));
        insertPQ(pq, elem);
      }else {
        free(elem);
      }
    } else {
      insertPQ(pq, elem);
    }
  }

  for (int i = 0; !isEmptyPQ(pq) && i < k; i++) {
    NNelem *element = (NNelem *)extractMaxPQ(pq);
    nn.elements[i] = *element;
    nn.size++;
    free(element);
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

// we calculate the spearman rho distance between the query and the database
// we sort the database by the spearman rho similarity
// we show the elements with distance less than r
// Finally returns the number of candidates in the range r
//
int rangeSearch(Index S, int obj, float r, bool show) {
  fileHeader *header = (fileHeader *)S;
  int *queryPermutation = malloc(sizeof(int) * pbifp->permutationSize);
  float *distances = malloc(sizeof(float) * pbifp->permutationSize);
  unsigned count = 0;
  // We look in a percentage of the database
  int n = header->n * percentage;

  queryPermutationProcess(queryPermutation, distances, pbifp->permutationSize);

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
