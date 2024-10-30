
#include "strings.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>


DB db;

static int never = 1;

#define distance(u, q) (db.dist(db(u), db(q)))


int ed (char *w1, char *w2) {
  register int pc, nc, i, j;
  register char cc;
  register int m = strlen(w1);
  int *c;
  if (db.csize < m) {
    db.csize = m;
    db.c = realloc(db.c, (m + 1) * sizeof(int));
  }
  c = db.c;
  nc = m;
  w1--;

  for (i = 0; i <= m; i++) {
    c[i] = i;
  }

  for (i = 0; (cc = w2[i]); i++) {
    pc = i;
    nc = i+1;
    for (j = 1; j <= m; j++) {
      if (c[j] < nc) nc = c[j];
      pc += (cc != w1[j]);
      if (pc <= nc) nc = pc;
      else nc++;
      pc = c[j];
      c[j] = nc;
    }
  }

  return nc;
}


int parseObj(char *s) {
  char *str = db(NewObj);
  if (str != NULL) free(str);
  str = malloc(strlen(s) + 1);
  strcpy(str, s);
  db(NewObj) = str;
  return NewObj;
}

void printObj(int obj) {
  printf("%s\n", db(obj));
}


int openDB(char *name) {
  char *ptr, *top;

  FILE *f;
  struct stat sdata;
  unsigned long dn;

  closeDB();
  f = fopen(name, "r");
  stat(name, &sdata);
  db.words = malloc(sdata.st_size);
  fread(db.words, sdata.st_size, 1, f);
  ptr = db.words;
  top = ptr + sdata.st_size;

  db.dist = ed;

  while (ptr < top) {
    while (*ptr != '\n') ptr++;
    dn++;
    *ptr++ = '\0';
  }
  db.ptrs = malloc((dn + 1) * sizeof(char * ));
  dn =0;
  ptr = db.words;
  db.ptrs[0] = NULL;
  while (ptr < top) {
    db.ptrs[++dn] = ptr;
    while(*ptr++);
  }
  db.nwords = dn;
  return db.nwords;
}

void closeDB(void) {
  if (never) {
    never = 0;
    db.words = NULL;
  }
  if (db.words == NULL) return;
  free(db.words);
  free(db.ptrs);
  free(db.c);
  db.csize = -1;
  db.words = NULL;
  db.ptrs = NULL;
  db.c = NULL;
}

