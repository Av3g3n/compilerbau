%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "customHeader.h"
NodeType *opr(int oper, int nops, ...);
NodeType *id(char* str);
NodeType *con(int value);
void freeNode(NodeType *p);
int ex(NodeType *p);
void yyerror(char *);
int yylex(void);
Dict* head = NULL;
Dict* tail = NULL;
%}

%union {
	int _int;
	char* _str;
	struct NodeTypeTag* ptr;
}

%token <_int> INTEGER
%token <_str> VARIABLE
%token IF ELSE COMMENT PRINT WHILE AND OR CONST
%nonassoc IFX
%nonassoc ELSE
%left GE LE EQ NE '<' '>'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS
%type <ptr> statement expression

%%
program:
	program statement comment '\n'								{ ex($2); freeNode($2); }
	| program comment '\n'
	|
	;

statement:
		expression					    								{ $$ = $1; }
		| VARIABLE '=' expression									{ printf("Variable content inside grammar: %s\n", $1); $$ = opr('=', 2, id($1), $3); }
		| PRINT expression comment									{ $$ = opr(PRINT, 1, $2); }
		| WHILE '('  expression ')' statement					{ $$ = opr(WHILE, 2, $3, $5); }
		| IF '(' expression ')' statement %prec IFX			{ $$ = opr(IF, 2, $3, $5); }
		| IF '(' expression ')' statement ELSE statement	{ $$ = opr(IF, 2, $3, $5, $7); }
		// const missing
		;

expression:
		INTEGER															{ $$ = con($1);}
		| VARIABLE				   									{ $$ = id($1); }
		| '-' expression %prec UMINUS								{ $$ = opr(UMINUS, 1, $2); }
		| expression '+' expression								{ $$ = opr('+', 2, $1, $3); }
		| expression '-' expression								{ $$ = opr('-', 2, $1, $3); }
		| expression '*' expression								{ $$ = opr('*', 2, $1, $3); }
		| expression '/' expression								{ $$ = opr('/', 2, $1, $3); }
		| expression '<' expression								{ $$ = opr('<', 2, $1, $3); }
		| expression '>' expression								{ $$ = opr('>', 2, $1, $3); }
		| expression GE expression									{ $$ = opr(GE, 2, $1, $3); }
		| expression LE expression									{ $$ = opr(LE, 2, $1, $3); }
		| expression EQ expression									{ $$ = opr(EQ, 2, $1, $3); }
		| expression NE expression									{ $$ = opr(NE, 2, $1, $3); }
		| '(' expression ')'			   							{ $$ = $2;}
		;

comment:
		COMMENT															{ printf("Real Comment\n"); }
		|																	{ printf("Empty Comment for grammar\n"); }
		;

%%
Dict* dict_next(Dict* ptr){
   return ptr->next;
}
int dict_getValue(char* str){
   Dict* current = head;
   while(current != NULL){
      if(strcmp(current->key, str) == 0){
         return current->value;
      } else {
         current = dict_next(current);
      }
   }
}
void dict_add(int val, char* str){
   Dict* dict = (Dict*)malloc(sizeof(Dict));
   dict->value = val;
   dict->key = str;
   if(tail != NULL){
      tail->next = dict;
      dict->next = NULL;
      tail = dict;
   } else {
      head = dict;
      tail = dict;
   }
}

#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)
NodeType *con(int value) {
	printf("function \"con\" parameter: %d\n", value); //DEBUG
   NodeType *p;
   if ((p = malloc(sizeof(NodeType))) == NULL)
      yyerror("out of memory");
   p->type = typeCon;
   p->con.value = value;
   return p;
}
NodeType *id(char* str) {
	printf("function \"id\" parameter: %s\n", str); //DEBUG
   NodeType *p;
   if ((p = malloc(sizeof(NodeType))) == NULL)
      yyerror("out of memory");
   p->type = typeId;
   p->id.str = str;
   return p;
}
NodeType *opr(int oper, int nops, ...) {
   va_list ap;
   NodeType *p;
   int i;
   if ((p = malloc(sizeof(NodeType) + (nops-1) * sizeof(NodeType *))) == NULL)
      yyerror("out of memory");
   p->type = typeOpr;
   p->opr.oper = oper;
   p->opr.nops = nops;
   va_start(ap, nops);
   for (i = 0; i < nops; i++)
      p->opr.op[i] = va_arg(ap, NodeType*);
   va_end(ap);
   return p;
}
void freeNode(NodeType *p) {
   int i;
   if (!p) return;
   if (p->type == typeOpr) {
      for (i = 0; i < p->opr.nops; i++)
         freeNode(p->opr.op[i]);
   }
   free (p);
}

void yyerror(char *s){
   fprintf(stderr, "%s\n", s);
	exit(1);
}
int main(int argc, char *argv[]){
   if(argv[1] == NULL){
		yyparse();
		return 0;
	}
	else {
		FILE *yyin;
		yyin = fopen(argv[1], "r");
		yyparse();
		return 0;
		fclose(yyin);
	}
}