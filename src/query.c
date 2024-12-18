#include <stdlib.h>
#include <sys/stat.h>
#include <sys/times.h>
#include <sys/types.h>

#include "db/vectors/vectors.h"
#include "index/index.h"
// #include "index/pbi/pbi.h"
#include "string.h"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
  char str[10000];
  int k;
  float r;

  struct stat sdata;
  struct tms t1, t2;

  int numQueries = 0;

  if (argc < 3 || argc > 4) {
    fprintf(stderr, "Usage: %s <index-file> [percentage]\n", argv[0]);
    exit(1);
  }


  fprintf(stderr, "reading index\n");

  Index index = loadIndex(argv[1]);

  stat(argv[1], &sdata);
  fprintf(stderr, "read %lli bytes\n", 
          (long long)sdata.st_size);

  percentage = 0.1;

  if (argc == 3) {
    percentage = atof(argv[2]);
  }

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
    query = parseObj(str);

    // we run the query
    
    numQueries++;
    if (fixed) {
      times(&t1);
      size = rangeSearch(index, query, r, true);
      times(&t2);
      fprintf(stderr, "%i objects found\n", size);
    } else {
      times(&t1);
      r = kNNSearch(index, query, k, true);
      size = k;
      times(&t2);
      fprintf(stderr, "kNNs at distance %f\n", r);
    }
    fflush(stderr);
    fflush(stdout);

  }

  fprintf(stderr, "Total distances per query: %f\n", 
          numDistances / (float)numQueries);
  fprintf(stderr , "freeing...\n");
  freeIndex(index, true);
  fprintf(stderr, "done\n");

  
  return 0;
}
