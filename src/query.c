#include <stdlib.h>
#include <sys/stat.h>
#include <sys/times.h>
#include <sys/types.h>

#include "db/vectors/vectors.h"
#include "index/pbi/pbi.h"
#include "string.h"
#include <stdio.h>
#include <stdlib.h>

void parseQuery(char *p, float *query, int dim) {
  int i, step;
  for (i = 0; i < dim - 1; i++) {
    sscanf(p, "%f,%n", query + i, &step);
    p += step;
  }
  sscanf(p, "%f", query + i);
}

int main(int argc, char *argv[]) {
  char str[1024];
  int k;
  float r;

  struct stat sdata;
  struct tms t1, t2;

  int numQueries = 0;

  if (argc != 2) {
    fprintf(stderr, "Usage: %s index-file\n", argv[0]);
    exit(1);
  }

  Index index = (fileHeader *)loadIndex(argv[1]);

  printPBI();
  // printf("%d\n", ((fileHeader*)index)->dim);

  float *query_values = malloc(sizeof(float) * ((fileHeader *)index)->dim);

  while (true) {
    int query;
    int size;
    bool fixed;

    if (scanf("%[0123456789-.]s", str) == 0) {
      break;
    }

    // -0 finalize the program
    if (!strcmp(str, "-0")) {
      break;
    }

    // negative -> KNN
    if (str[0] == '-') {
      fixed = false;
      if (sscanf(str + 1, "%d", &k) == 0)
        break;

    }
    // otherwise -> range
    else {
      fixed = true;
      if (sscanf(str, "%f", &r) == 0)
        break;
    }

    if (getchar() != ',')
      break;
    if (scanf("%[^\n]s", str) == 0)
      break;
    if (getchar() != '\n')
      break;

    // we parse the query and store it in the db

    // parseQuery(str, query_values, ((fileHeader*)index)->dim);
    parseObj(str);

    // we run the query
    if (fixed) {
      printf("RANGE QUERY: %f\n", r);

      // for (int i = 0; i < ((fileHeader *)index)->dim; i++) {
      //   printf("%f ", query_values[i]);
      // }

      for (int i = 0; i < db.coords; i++) {
        printf("%f ", *(db(NewObj) + i));
      }
      printf("\n");

      size = rangeSearch(index, NewObj, r, true);
    } else {

      printf("KNN QUERY: %d\n", k);

      for (int i = 0; i < db.coords; i++) {
        printf("%f ", *(db(NewObj) + i));
      }
      printf("\n");
      r = kNNSearch(index, NewObj, k, true);
      size = k;
    }

    printf("-------------\n");
  }

  // printPBI();
}
