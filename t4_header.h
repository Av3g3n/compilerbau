#ifndef T4_HEADER_H
#define T4_HEADER_H

/* F U N C T I O N  E V A L U A T I O N */
#define ERR_FUNEVAL -1
extern int FUNEVAL;

/* D I C T I O N A R Y */ 
// union for difference between int or string for later
typedef struct Dict {
   int value;
   char* key;
   struct Dict* next;
} Dict;

extern Dict* head;
extern Dict* tail;

Dict* dict_next(Dict*); // NEEDED?
int dict_getValue(const char* restricted);
void dict_add(int, char*);
Dict* dict_keyExists(const char* restricted);
void free_dict();
void printDict(Dict*, int);

/* S Y M B O L T A B L E */
typedef struct SymT {
	struct Dict* dhead;
	struct Dict* dtail;
        struct SymT* ptr;
} SymT;

extern SymT* scope;
extern SymT* globalscope;

void new_scope();
int scope_getValue(const char* restricted);
void scope_add(int, char*);
Dict* scope_keyExists(const char* restricted);
void free_scope();
void printFromFullScope();

/* D E B U G  M O D E */
extern int DEBUG;
int debug(const char*, ...);

/* H E L P  M E S S A G E */
void print_help();

/* S T R U C T U R E S  F O R  G R A M M A R  R U L E S */

#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p) // NEEDED?

typedef enum {
   type_constant,
   type_variable,
   type_function,
   type_operator
} NodeEnum;

typedef struct {
   int value;
} ConstantNode;

typedef struct {
   char* str;
} VariableNode;

typedef struct {
   char* str1;
   char* str2;
} FunctionNode;

typedef struct {
   int oper;
   int nops;
   struct NodeTypeTag *op[1];
} OperatorNode;

typedef struct NodeTypeTag {
   NodeEnum type;
   union {
      ConstantNode con;
      VariableNode var;
      FunctionNode fun;
      OperatorNode opr;
   };
} NodeType;

NodeType* opr(int, int, ...);
NodeType* var(char*);
NodeType* fun(NodeType*, NodeType*, NodeType*);
NodeType* con(int);
void freeNode(NodeType*);
int ex(NodeType*);

/* O T H E R */

extern int tabCount; // NEEDED?

/* T E M P O R A R Y  F U N C T I O N S ? */
void prompt_in(); // NEEDED?
void prompt_out(); // NEEDED?
int trim_char(char* restrict, const char* restrict, const char); // NEEDED?
int copy_until_char(char* restrict, const char* restrict, const char); // NEEDED?
void colorize_err_out(); // NEEDED?
void reset_err_color(); // NEEDED?

#endif