%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <unistd.h>
#include "t4_header.h"
NodeType *opr(int oper, int nops, ...);
NodeType *id(char* str);
NodeType *con(int value);
void freeNode(NodeType *p);
int ex(NodeType *p);
void yyerror(char *);
int yylex(void);
Dict* head = NULL;
Dict* tail = NULL;
int DEBUG = 0;
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
// %precedence '=' // for something like print(x=2);
%left GE LE EQ NE '<' '>'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS
%right '^'
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
		| expression '/' expression								{ 
																				if($3) $$ = opr('/', 2, $1, $3);
																				else {
																					$$->con.value = 1;
																					fprintf(stderr, "%d.%d-%d.%d: division by zero",
																								@3.first_line, @3.first_column,
																								@3.last_line, @3.last_column);
																				} 
																			}
		| expression '<' expression								{ $$ = opr('<', 2, $1, $3); }
		| expression '>' expression								{ $$ = opr('>', 2, $1, $3); }
		| expression '^' expression								{ $$ = opr('^', 2, $1, $3); }
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
	colorize_err_out();
   fprintf(stderr, "%s\n", s);
	reset_err_color();
	exit(1);
}

int debug(const char* str, ...){
	if(DEBUG){
		va_list arg;
		int done;
		va_start(arg, str);
		done = vfprintf(stdout, str, arg);
		va_end(arg);
		return done;
	}
	return 0;
}

void colorize_err_out(){
   fprintf(stderr, "\033[0;31m");
}

void reset_err_color(){
   fprintf(stderr, "\033[0m");
}

void print_help(){
	char flag_d[] = "\t-d --> activates debug messages\n";
	char flag_f[] = "\t-f FILE --> file to read from\n";
	char flag_h[] = "\t-h --> print help message\n";
	printf("t4compiler [OPTIONS]\nOPTIIONS:\n%s%s%s", flag_d, flag_f, flag_h);
}

int main(int argc, char const* argv[]){
   if(argc == 1){
		return yyparse();
	}
	for(int i = 1; i < argc; i++){
		if(strcmp(argv[i], "-d") == 0){
			DEBUG = 1;
			yyparse();
		}
		else if(strcmp(argv[i], "-f") == 0){
			if(argv[i+1] == NULL){
				colorize_err_out();
				fprintf(stderr, "Option -f requires a filename\nSee help message for correct syntax:\n\n");
				reset_err_color();
				print_help();
				return 1;
			}
			// TODO
			if(access(argv[i+1], R_OK) == 0){
				FILE *yyin;
				yyin = fopen(argv[i+1], "r");
				yyparse();
				fclose(yyin);
			} else {
				colorize_err_out();
				fprintf(stderr, "File \"%s\" does not exist or read rights are missing\n", argv[i+1]);
				reset_err_color();
				return 1;
			}
		} else if(strcmp(argv[i], "-h") == 0){
			print_help();
		} else {
			colorize_err_out();
			fprintf(stderr, "Invalid Option \"%s\"\nSee help message for available options:\n\n", argv[i]);
			reset_err_color();
			print_help();
			return 1;
		}
	}
	return 0;
}