#ifndef T4_HEADER_H
#define T4_HEADER_H

/* binary search tree for variable identifiers */
   // https://www.geeksforgeeks.org/binary-tree-to-binary-search-tree-conversion/?ref=rp

// union for difference between int or string for later
typedef struct Dict {
   int value;
   char* key;
   struct Dict* next;
} Dict;

extern Dict* head;
extern Dict* tail;

Dict* dict_next(Dict*);
int dict_getValue(char*);
void dict_add(int, char*);

extern int DEBUG;
int debug(const char*, ...);

/* node structure */
   // https://stackoverflow.com/questions/1675351/typedef-struct-vs-struct-definitions

/* Font Colors */
void colorize_err_out();
void reset_err_color();

/* Wrapper around error for red font */
void error_with_color(char*);

void print_help();

/* function with n parameters and m are defined --> function(int n, ...) */
   // https://manderc.com/types/ellipsisparameter/index.php

typedef enum {
   typeCon,
   typeId,
   typeOpr
} NodeEnum;

typedef struct {
   int value;
} ConNodeType;

typedef struct {
   char* str;
} IdNodeType;

typedef struct {
   int oper;
   int nops;
   struct NodeTypeTag *op[1];
} OprNodeType;

typedef struct NodeTypeTag {
   NodeEnum type;
   union {
      ConNodeType con;
      IdNodeType id;
      OprNodeType opr;
   };
} NodeType;

#endif