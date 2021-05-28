#ifndef T4_HEADER_H
#define T4_HEADER_H

/* D I C T I O N A R Y */ 
// union for difference between int or string for later
typedef struct Dict {
   int value;
   char* key;
   struct Dict* next;
} Dict;

extern Dict* head;
extern Dict* tail;

Dict* dict_next(Dict*);
int dict_getValue(const char* restricted);
void dict_add(int, char*);
Dict* dict_keyExists(const char* restricted);

/* D E B U G  M O D E */
extern int DEBUG;
int debug(const char*, ...);

/* E R R O R  C O L O R */
void colorize_err_out();
void reset_err_color();

/* H E L P  M E S S A G E */
void print_help();

/* S T R U C T U R E S  F O R  G R A M M A R  R U L E S */
typedef enum {
   type_constant,
   type_variable,
   type_operator
} NodeEnum;

typedef struct {
   int value;
} ConstantNode;

typedef struct {
   char* str;
} VariableNode;

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
      OperatorNode opr;
   };
} NodeType;

/* T E M P O R A R Y  F U N C T I O N S ? */
void prompt_in();
void prompt_out();
int trim_char(char* restrict, const char* restrict, const char);
int copy_until_char(char* restrict, const char* restrict, const char);

#endif