%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <unistd.h>
#include "t4_header.h"

void yyerror(char *);
int yylex(void);
Dict* head = NULL;
Dict* tail = NULL;
SymT* scope = NULL;
SymT* globalscope = NULL; // NEEDED?
int currentTabCount;
int DEBUG;
int FUNEVAL;
%}

//%define parse.error verbose
//%glr-parser

%union {
	int int_val;
	char* var_val;
	struct NodeTypeTag* node_ptr;
}

%start program
%token <int_val> INTEGER
%token <var_val> VARIABLE
%token IF ELSE PRINT WHILE AND OR /* FUN CONST */
%nonassoc IFX
%nonassoc ELSE
%precedence '='
%left GE LE EQ NE '<' '>'
%left AND OR
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS
%right '^'
%type <node_ptr> statement expression condition cond_list stmt_list /* var_list function */

%%
program:
	program statement													{ ex($2); freeNode($2); }
	/* program function													{ ex($2); freeNode($2); } */
	|
	;

/* function:
	FUN VARIABLE '(' var_list ')' ':' '\n' stmt_list		{ ; }
	;

var_list:
	VARIABLE ',' var_list											{ ; }
	|																		{ ; }
	; */

statement:
		'\n'																						{
																										//debug("statement --> \\n\n"); 
																										$$ = opr('\n', 2, NULL, NULL); 
																									}
		| expression '\n'			    														{ $$ = $1; }
		| '(' condition ')' '\n'															{ $$ = $2; }
		| VARIABLE '=' expression '\n'													{ 
																										debug("GRAMMAR: statement --> %s = expression\n", $1);
																										$$ = opr('=', 2, var($1), $3); 
																									}
		| PRINT expression '\n'																{ $$ = opr(PRINT, 1, $2); }
		| WHILE '(' condition ')' ':' '\n' stmt_list									{ $$ = opr(WHILE, 2, $3, $7); }
		| IF '(' condition ')' ':' '\n' stmt_list %prec IFX						{ 
																										debug("GRAMMAR: statement --> IF ...\n");
																										tabCount--;
																										$$ = opr(IF, 2, $3, $7);
																									}
		| IF '(' condition ')' ':' '\n' stmt_list ELSE ':' '\n' stmt_list		{ $$ = opr(IF, 3, $3, $7, $11); } 
		;

stmt_list:
		tabs statement stmt_list								{
																			debug("GRAMMAR: stmt_list --> tabs statement stmt_list\n");
																			$$ = opr('\n', 2, $2, $3);
																		}
		| tabs statement											{
																			debug("GRAMMAR: stmt_list --> tabs statement\n");
																			$$ = $2; 
																		}
		;

tabs:
 	tabs '\t' 														{
																			currentTabCount++;
																			//
	 																	}
	| '\t'															{
																			if(tabCount > 1){
																				currentTabCount++;
																			}
																		}
	;

condition:
		'(' condition ')'												{ $$ = $2; }
		| expression GE expression									{ $$ = opr(GE, 2, $1, $3); }
		| expression LE expression									{ $$ = opr(LE, 2, $1, $3); }
		| expression EQ expression									{ $$ = opr(EQ, 2, $1, $3); }
		| expression NE expression									{ $$ = opr(NE, 2, $1, $3); }
		| expression '<' expression								{ $$ = opr('<', 2, $1, $3); }
		| expression '>' expression								{ $$ = opr('>', 2, $1, $3); }
		| cond_list														{ $$ = $1; }
		;

cond_list:
		condition AND condition										{ $$ = opr(AND, 2, $1, $3); }
		| condition OR condition									{ $$ = opr(OR, 2, $1, $3); }
		;

expression:
		INTEGER															{
																				//debug("expression --> INTEGER\n\tVALUE: %d\n", $1);
																				$$ = con($1);
																			}
		| VARIABLE				   									{ 
																				//debug("expression --> VARIABLE\n\tVALUE: %s\n", $1);
																				$$ = var($1);
																			}
		| '-' expression %prec UMINUS								{ $$ = opr(UMINUS, 1, $2); }
		| expression '+' expression								{ $$ = opr('+', 2, $1, $3); }
		| expression '-' expression								{ $$ = opr('-', 2, $1, $3); }
		| expression '*' expression								{ $$ = opr('*', 2, $1, $3); }
		| expression '/' expression								{ // TODO
																				if($3->con.value){
																					$$ = opr('/', 2, $1, $3);
																				} else {
																					colorize_err_out();
																					fprintf(stderr, "%d.%d-%d.%d: division by zero\n",
																								@3.first_line, @3.first_column,
																								@3.last_line, @3.last_column);
																					reset_err_color();
																				} 
																			}
		| expression '^' expression								{ $$ = opr('^', 2, $1, $3); }
		| '(' expression ')'			   							{ $$ = $2;}
		;

%%
// ----------------------
/* D I C T I O N A R Y */
// ----------------------

Dict* dict_next(Dict* ptr){
   return ptr->next;
}

int dict_getValue(const char* restrict str){
   /* Dict* current = head;
   while(current != NULL){
      if(strcmp(current->key, str) == 0){
			FUNEVAL = 1;
         return current->value;
      } else {
         current = dict_next(current);
      }
   }
	FUNEVAL = 0;
	return ERR_FUNEVAL; */
	Dict* temp = dict_keyExists(str);
	if(temp != NULL){
		FUNEVAL = 1;
		return temp->value;
	}
	FUNEVAL = 0;
	return ERR_FUNEVAL;
}

void dict_add(int val, char* str){
	/* Dict* temp = dict_keyExists(str);
	if(temp != NULL) {
		temp->value = val;
		return;
	}
	// TODO instead of Dict* dict, use just temp */
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
		scope->dhead = head;
		scope->dtail = tail;
   }
}

Dict* dict_keyExists(const char* restrict str){
	debug("FUN: Inside dict_keyExists(), param: %s\n", str);
	Dict* current = head;
   while(current != NULL){
      if(strcmp(current->key, str) == 0){
			debug("FUN: dict_keyExists returns existing key\n");
			return current;
      } else {
         current = dict_next(current);
      }
   }
	return NULL;
}

void free_dict(){
	if(head != NULL){
		Dict* temp = head;
		head = dict_next(temp);
		free(temp);
		temp = NULL;
		free_dict();
	}
}

void printDict(Dict* ptr, int i){
	if(!ptr) return;
	Dict* current = ptr;
	int cnt = 0;
	printf("Scope%d\n", i);
	while(current){
		cnt++;
		printf("\t%d) %s | %d\n", cnt, current->key, current->value);
		current = dict_next(current);
	}
}

// ------------------------
/* S Y M B O L T A B L E */
// ------------------------

void new_scope(){
	debug("FUN: Inside new_scope()\n");
	SymT* symt = (SymT*) malloc(sizeof(SymT));
	if(scope != NULL){
		scope->dhead = head;
		scope->dtail = tail;
		symt->ptr = scope;
		scope = symt;
		head = NULL;
		tail = NULL;
		debug("FUN: New Scope\n");
	}
	else {
		scope = symt;
		globalscope = symt;
		scope->ptr = NULL;
		debug("FUN: New Scope | New Globalscope\n");
	}
	debug("FUN: Leaving new_scope()\n");
}

void scope_add(int val, char* str){
	Dict* temp = scope_keyExists(str);
	if(temp == NULL){
		dict_add(val, str);
	}
	else {
		temp->value = val;
	}
}

int scope_getValue(const char* restrict str){
	/* printFromFullScope();
	SymT* current = scope;
	while(current != NULL){
		head = current->dhead;
		int temp = dict_getValue(str);
		if(FUNEVAL){
			current = current->ptr;
		}
		else {
			head = scope->dhead;
			FUNEVAL = 1;
			return temp;
		}
	}
	FUNEVAL = 0;
	return -1; */
	Dict* temp = scope_keyExists(str);
	if(temp != NULL){
		debug("FUN: scope_getValue returns real value\n");
		FUNEVAL = 1;
		return temp->value;
	}
	FUNEVAL = 0;
	return ERR_FUNEVAL;
}

Dict* scope_keyExists(const char* restrict str){
	SymT* current = scope;
	while(current != NULL){
		debug("FUN: scope_keyExists, HEAD: %p | SCOPEHEAD: %p\n", head, current->dhead);
		head = current->dhead;
		Dict* temp = dict_keyExists(str);
		if(temp == NULL){
			current = current->ptr;
		}
		else {
			debug("FUN: scope_keyExists returns existing key\n");
			head = scope->dhead;
			return temp;
		}
	}
	return NULL;
}

void free_scope(){
	debug("FUN: Inside free_scope()\n");
	if(!scope) return;
	SymT* temp = scope;
	if(scope->ptr == NULL){
		free_dict();
		return;
	}
	scope = scope->ptr;
	free_dict();
	head = scope->dhead;
	tail = scope->dtail;
	free(temp);
	temp = NULL;
}

void printFromFullScope(){
	int i = 0;
	printDict(head, i);
	if(!scope->ptr) return;
	SymT* current = scope->ptr;
	while(current){
		i++;
		printDict(current->dhead, i);
		current = current->ptr;
	}
}

// -------------------------------------------------------
/* S T R U C T U R E S  F O R  G R A M M A R  R U L E S */
// -------------------------------------------------------

#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)
NodeType* con(int value) {
	//debug("Function \"con\" parameter: %d\n", value);
   NodeType *p;
   if ((p = malloc(sizeof(NodeType))) == NULL)
      yyerror("out of memory");
   p->type = type_constant;
   p->con.value = value;
   return p;
}
NodeType* var(char* str) {
	//debug("Function \"var\" parameter: %s\n", str);
   NodeType *p;
   if ((p = malloc(sizeof(NodeType))) == NULL)
      yyerror("out of memory");
   p->type = type_variable;
   p->var.str = str;
   return p;
}
NodeType* opr(int oper, int nops, ...) {
   va_list ap;
   NodeType *p;
   int i;
   if ((p = malloc(sizeof(NodeType) + (nops-1) * sizeof(NodeType *))) == NULL)
      yyerror("out of memory");
   p->type = type_operator;
   p->opr.oper = oper;
   p->opr.nops = nops;
   va_start(ap, nops);
   for (i = 0; i < nops; i++)
      p->opr.op[i] = va_arg(ap, NodeType*);
   va_end(ap);
   return p;
}

void freeNode(NodeType *p) {
   if (!p) return;
   if (p->type == type_operator) {
      for (int i = 0; i < p->opr.nops; i++)
         freeNode(p->opr.op[i]);
   }
   free (p);
	p = NULL;
}

// -----------------------------
/* E R R O R  H A N D L I N G */
// -----------------------------

void yyerror(char *s){
	colorize_err_out();
   fprintf(stderr, "%s\n", s);
	reset_err_color();
}

// ---------------------
/* D E B U G  M O D E */
// ---------------------

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

// -------------------------
/* H E L P  M E S S A G E */
// -------------------------

void print_help(){
	char flag_v[] = "\t-v --> activates verbose messages\n";
	char flag_f[] = "\t-f FILE --> file to read from\n";
	char flag_h[] = "\t-h --> print help message\n";
	printf("t4compiler [OPTIONS]\nOPTIONS:\n%s%s%s", flag_v, flag_f, flag_h);
}

/* T E M P O R A R Y  F U N C T I O N S ? */

int trim_char(char* restrict str_trim, const char* restrict str_untrim, const char c){
   while(*str_untrim != '\0'){
      if(*str_untrim != c){
         *str_trim = *str_untrim;
         str_trim++;
      }
      str_untrim++;
   }
   *str_trim = '\0';
   return 0;
}

int copy_until_char(char* restrict copy, const char* restrict orig, const char c){
   while(*orig != '\0'){
      if(*orig != c){
         *copy = *orig;
      	copy++;
         orig++;
		}
      else {
         break;
      }
   }
   *copy = '\0';
   return 0;
}

void prompt_in(){
	printf(">>> ");
}

void prompt_out(){
	printf("<<< ");
}

void colorize_err_out(){
   fprintf(stderr, "\033[0;31m");
}

void reset_err_color(){
   fprintf(stderr, "\033[0m");
}

// ===========================
/* M A I N  F U N C T I O N */
// ===========================

// read from file needed?
int main(int argc, char const* argv[]){
	if(argc == 1){
		new_scope();
		return yyparse();
	}
	for(int i = 1; i < argc; i++){
		if(strcmp(argv[i], "-v") == 0){
			DEBUG = 1;
			new_scope();
			return yyparse();
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
}