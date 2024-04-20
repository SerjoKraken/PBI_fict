
#include "priorityQueue.h"
#include "string.h"
#include <stdio.h>
#include <stdlib.h>

/*
 * Swap the bytes in memory between two pointers
 * */
void swapPQ(Item *a, Item *b, int sizeItem) {
  Item temp = malloc(sizeItem);
  memcpy(temp, *a, sizeItem);
  memcpy(*a, *b, sizeItem);
  memcpy(*b, temp, sizeItem);

  free(temp);
}

int isEmptyPQ(PQ *pq) { return pq->heapSize == 0; }

PQ *createPQ(int size, int (*compare)(void *, void *), int sizeItem) {
  PQ *pq = (PQ *)malloc(sizeof(PQ));
  pq->heapSize = 0;
  pq->capacity = size;
  pq->compare = compare;
  pq->heap = malloc((size + 1) * sizeof(Item)); // pq->heap[0] is not used
  pq->sizeItem = sizeItem;

  return pq;
}

void shiftUp(PQ *pq, int i) {
  while (i > 1 && pq->compare(pq->heap[i / 2], pq->heap[i]) < 0) {
    swapPQ((pq->heap + i), (pq->heap + i / 2), pq->sizeItem);
    i = i / 2;
  }
}

void shiftDown(PQ *pq, int i) {
  int left = 2 * i;
  int right = 2 * i + 1;
  int smallest = i;

  if (left <= pq->heapSize &&
      pq->compare(pq->heap[left], pq->heap[smallest]) > 0)
    smallest = left;
  if (right <= pq->heapSize &&
      pq->compare(pq->heap[right], pq->heap[smallest]) > 0)
    smallest = right;

  if (smallest != i) {
    swapPQ(&pq->heap[i], &pq->heap[smallest], pq->sizeItem);
    shiftDown(pq, smallest);
  }
}

int insertPQ(PQ *pq, Item item) {
  if (pq->heapSize == pq->capacity) // Check if the heap is full
    return 0;

  pq->heapSize++;
  pq->heap[pq->heapSize] = item;

  shiftUp(pq, pq->heapSize);

  return 1;
}

Item extractMaxPQ(PQ *pq) {
  if (pq->heapSize == 0)
    return NULL;

  Item min = malloc(pq->sizeItem);

  // min = pq->heap[pq->heapSize--];
  memcpy(min, pq->heap[1], pq->sizeItem);

  swapPQ(&pq->heap[1], &pq->heap[pq->heapSize], pq->sizeItem);

  pq->heapSize--;

  shiftDown(pq, 1);

  return min;
}

Item peekPQ(PQ *pq) {
  if (pq->heapSize == 0)
    return NULL;
  return pq->heap[1];
}

void destroyPQ(PQ *pq) {
  // We have to call some "Item" methods
  // to free the memory of that elements
  // and their members
  for (int i = 1; i <= pq->heapSize; i++) {
    free(pq->heap[i]);
  }
  free(pq->heap);
  free(pq);
}

void increaseCapacityPQ(PQ *pq, int size) {
  if (size <= pq->capacity)
    return;

  pq->capacity = size;
  Item *temp = realloc(pq->heap, (size + 1) * sizeof(Item));

  if (temp == NULL) {
    printf("Error reallocating memory\n");
    return;
  }

  pq->heap = temp;
}
