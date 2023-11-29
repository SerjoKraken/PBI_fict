#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/times.h>
#include <time.h>

#include <stdio.h>
#include <stdlib.h>
#include "db.h"
#include "index/index.h"
#include "index/pbi.h"
#include "string.h"

int main(int argc, char *argv[]) {
  char query[1024];
  time_t start, end;

  Index index = loadIndex("index.bin");
  printf("Index loaded\n");

  printPBI();

  start = time(NULL);
  end = time(NULL);
}
