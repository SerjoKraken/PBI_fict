
#include "priorityQueue.h"
#include "string.h"

void swap(Item a, Item b, int sizeItem) {
  Item temp = (Item)malloc(sizeItem);
  memcpy(temp, a, sizeItem);
  memcpy(a, b, sizeItem);
  memcpy(b, temp, sizeItem);
  free(temp);
}

int isEmptyPQ(PQ *pq) { return pq->heapSize == 0; }

PQ *createPQ(int size, int (*compare)(void *, void *), int sizeItem) {
  PQ *pq = (PQ *)malloc(sizeof(PQ));
  pq->heapSize = 0;
  pq->capacity = size;
  pq->compare = compare;
  pq->heap = (Item)malloc((size + 1) * sizeItem); // pq->heap[0] is not used

  return pq;
}

void shiftUp(PQ *pq, int i) {
  while (i > 1 && pq->compare(pq->heap[i / 2], pq->heap[i]) > 0) {
    swap(&pq->heap[i], &pq->heap[i / 2], sizeof(Item));
    i /= 2;
  }
}

void shiftDown(PQ *pq, int i) {
  int left = 2 * i;
  int right = 2 * i + 1;
  int smallest = i;

  if (left <= pq->heapSize &&
      pq->compare(pq->heap[left], pq->heap[smallest]) < 0)
    smallest = left;
  if (right <= pq->heapSize &&
      pq->compare(pq->heap[right], pq->heap[smallest]) < 0)
    smallest = right;

  if (smallest != i) {
    swap(&pq->heap[i], &pq->heap[smallest], sizeof(Item));
    shiftDown(pq, smallest);
  }
}

int insertPQ(PQ *pq, Item item) {
  if (pq->heapSize == pq->capacity) // Check if the heap is full
    return 0;

  pq->heapSize++;
  int i = pq->heapSize;
  pq->heap[i] = item; // insert the element

  shiftUp(pq, i);

  return 1;
}

Item extractMinPQ(PQ *pq) {
  if (pq->heapSize == 0)
    return NULL;

  Item min = pq->heap[1];

  swap(&pq->heap[1], &pq->heap[pq->heapSize], sizeof(Item));
  //
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
  free(pq->heap);
  free(pq);
}
