#pragma once
#include <stdio.h>
#include <stdlib.h>

typedef void *Item;

// Priority Queue implementation using a heap
typedef struct PriorityQueue {
  Item *heap;
  int heapSize;               // Current size of the heap
  int capacity;               // Max size of the heap
  int (*compare)(Item, Item); // function pointer to compare two items
  int sizeItem;               // Size of the Item
} PQ;

/* Create a new priority Queue */
PQ *createPQ(int size, int (*compare)(Item, Item), int sizeItem);

/* Insert an item into the priority queue */
int insertPQ(PQ *pq, Item item);

/* Return the item with the highest priority from the priority queue */
Item peekPQ(PQ *pq);

/* Remove the item with the highest priority from the priority queue */
Item extractMinPQ(PQ *pq);

/* Destroy the priority queue */
void destroyPQ(PQ *pq);

/* Print the priority queue */
void printPQ(PQ *pq);

int isEmptyPQ(PQ *pq);

/* Increase the capacity of the priority queue */
void increaseCapacityPQ(PQ *pq, int size);
