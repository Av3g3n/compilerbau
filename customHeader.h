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

/* node structure */
   // https://stackoverflow.com/questions/1675351/typedef-struct-vs-struct-definitions

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