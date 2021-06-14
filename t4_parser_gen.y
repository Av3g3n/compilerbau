%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <unistd.h>
#include "t4_header.h"
#include "ansi_colors.h"

int yylex(void);
Dict *head = NULL;
Dict *tail = NULL;
SymT *scope = NULL;
SymT *globalscope = NULL;
funcdict *func = NULL;
int ttyout;
int DEBUG;
int FUNEVAL;
%}

//%define parse.error verbose
//%glr-parser

%union {
	int int_val;
	char *var_val;
	struct NodeTypeTag *node_ptr;
}

%start program
%token <int_val> INTEGER
%token <var_val> VARIABLE
%token IF ELSE PRINT WHILE AND OR FUN GLOBAL
%nonassoc IFX
%nonassoc ELSE
%precedence '='
%left GE LE EQ NE '<' '>'
%left AND OR
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS
%right '^'
%type <node_ptr> statement expression condition cond_list stmt_list param_list expr_list function

%%
program:
	/* empty */
	| program statement													{ ex($2); freeNode($2); }
	| program function													{ 
																					if(func == NULL){
																						func = malloc(sizeof(funcdict));
																						func->fun = $2;
																						func->ptr = NULL;
																					}
																					else {
																						funcdict *temp = malloc(sizeof(funcdict));
																						temp->ptr = func;
																						temp->fun = $2;
																						func = temp;
																					}
	 																			}
	;

function:
	FUN VARIABLE '(' param_list ')' '{' stmt_list '}'			{ $$ = fun($2, $4, $7); }
	;

param_list:
	/* empty */																{ $$ = NULL; }
	| VARIABLE																{ $$ = var($1); }
	| param_list ',' VARIABLE											{ $$ = opr(',', 2, $1, var($3)); }
	;

statement:
	';'																						{
																									//debug("statement --> \\n\n"); 
																									$$ = opr(';', 2, NULL, NULL); 
																								}
	| expression ';'			    														{ $$ = $1; }
	| '(' condition ')' ';'																{ $$ = $2; }
	| VARIABLE '=' expression ';'														{ 
																									//debug("GRAMMAR: statement --> %s = expression\n", $1);
																									$$ = opr('=', 2, var($1), $3); 
																								}
	| PRINT expression ';'																{ $$ = opr(PRINT, 1, $2); }
	| WHILE '(' condition ')' '{' stmt_list '}'									{ 
																									$$ = opr(WHILE, 2, $3, $6);
																								}
	| IF '(' condition ')' '{' stmt_list '}' %prec IFX 						{ 
																									//debug("GRAMMAR: statement --> IF ...\n");
																									$$ = opr(IF, 2, $3, $6);
																								}
	| IF '(' condition ')' '{' stmt_list '}' ELSE '{' stmt_list '}'		{ $$ = opr(IF, 3, $3, $6, $10); }
	| GLOBAL VARIABLE '=' expression ';'											{ $$ = opr(GLOBAL, 2, var($2), $4); }
	| error ';'																				{ yyclearin; yyerrok; }
	| error '=' expression ';'															{ yyclearin; yyerrok; }
	;

stmt_list:
	statement stmt_list										{
																		//debug("GRAMMAR: stmt_list --> tabs statement stmt_list\n");
																		$$ = opr(';', 2, $1, $2);
																	}
	| statement													{
																		// comes first
																		//debug("GRAMMAR: stmt_list --> tabs statement\n");
																		$$ = $1; 
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
																				if(ttyout)
																					fprintf(stderr, BIRED "%d.%d-%d.%d: division by zero\n" CRST,
																					@3.first_line, @3.first_column, @3.last_line, @3.last_column);
																				else
																					fprintf(stderr,"%d.%d-%d.%d: division by zero\n",
																					@3.first_line, @3.first_column, @3.last_line, @3.last_column);
																			} 
																		}
	| expression '^' expression								{ $$ = opr('^', 2, $1, $3); }
	| '(' expression ')'			   							{ $$ = $2; }
	| VARIABLE '(' expr_list ')'								{ $$ = opr(FUN, 2, var($1), $3); }
	;

expr_list:
	/* empty */														{ $$ = NULL; }
	| expression													{ $$ = $1; } 
	| expr_list ',' expression									{ $$ = opr(',', 2, $1, $3); }
	;

%%
// ----------------------
/* D I C T I O N A R Y */
// ----------------------

Dict* dict_next(Dict* ptr){
   return ptr->next;
}

int dict_getValue(const char* restrict str){
	Dict* temp = dict_keyExists(str);
	if(temp != NULL){
		FUNEVAL = 1;
		debug("FUN: dict_getValue(%s) --> %d\n", str, temp->value);
		return temp->value;
	}
	FUNEVAL = 0;
	return ERR_FUNEVAL;
}

void dict_add(int val, char* str){
	Dict* dict = (Dict*)malloc(sizeof(Dict));
   dict->value = val;
   dict->key = str;
	dict->next = NULL;
   if(tail != NULL){
      tail->next = dict;
      tail = dict;
		debug("FUN: dict_add(%d,%s) as tail in scope: %p with scope-head: %p of head: %p\n", val, str, scope, scope->dhead, head);
   } else {
      head = dict;
      tail = dict;
		scope->dhead = head;
		scope->dtail = tail;
		debug("FUN: dict_add(%d,%s) as head in scope: %p with scope-head: %p of head: %p\n", val, str, scope, scope->dhead, head);
   }
}

void dict_remove(char* str){
	Dict* current = head;
	if(current == NULL) return;
	if(strcmp(str, current->key) == 0){
		head = current->next;
		free(current);
		current = NULL;
		debug("FUN: dict_remove(%s) successfull (head)\n", str);
	}
	else {
		while(current != NULL){
			Dict* curnext = dict_next(current);
			if(strcmp(str, curnext->key) == 0){
				current->next = dict_next(curnext);
				if(curnext == tail){
					tail = current;
					return;
					debug("FUN: dict_remove(%s) successfull (tail)\n", str);
				}
				else {
					debug("FUN: dict_remove(%s) successfull (between)\n", str);
				}
				free(curnext);
				curnext = NULL;
				return;
			}
			current = dict_next(current);
		}
	}
}

Dict* dict_keyExists(const char* restrict str){
	debug("FUN: dict_keyExists(%s)\n", str);
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
	while(current != NULL){
		cnt++;
		printf("\t%d) %s | %d\n", cnt, current->key, current->value);
		current = dict_next(current);
	}
}

// ------------------------
/* S Y M B O L T A B L E */
// ------------------------

void new_scope(){
	debug("FUN: new_scope()\n");
	SymT* symt = (SymT*) malloc(sizeof(SymT));
	if(scope != NULL){
		scope->dhead = head;
		scope->dtail = tail;
		symt->ptr = scope;
		scope = symt;
		head = NULL;
		tail = NULL;
		debug("FUN: New Scope %p existing Scope %p\n", scope, scope->ptr);
	}
	else {
		globalscope = symt;
		globalscope->ptr = NULL;
		SymT* symt2 = (SymT*) malloc(sizeof(SymT));
		scope = symt2;
		scope->ptr = globalscope;
		debug("FUN: New Scope %p Global Scope %p\n", scope, globalscope);
	}
}

void globalscope_add(int val, char* str){
	Dict *temp = globalscope_keyExists(str);
	Dict *temp2 = scope_keyExists(str);
	debug("FUN: globalscope_add(%d, %s) global: %p, scope: %p\n", val, str, temp, temp2);
	if(temp2 != NULL && temp != temp2){
		debug("FUN: globalscope_add remove dict entry with %s\n", str);
		dict_remove(str);
	}
	if(temp == NULL){
		Dict* ndict = malloc(sizeof(Dict *));
		ndict->value = val;
		ndict->key = str;
		ndict->next = NULL;
		if(globalscope->dtail != NULL){
			globalscope->dtail->next = ndict;
			globalscope->dtail = ndict;
			debug("FUN: globalscope_add as tail\n");
		} 
		else {
			globalscope->dhead = ndict;
			globalscope->dtail = ndict;
			debug("FUN: globalscope_add as head\n");
		}
	}
	else {
		temp->value = val;
		debug("FUN: globalscope_add update\n");
	}
}

Dict* globalscope_keyExists(const char* restrict str){
	debug("FUN: Inside globalscope_keyExists()\n");
	Dict *storhead = head;
	head = globalscope->dhead;
	Dict* temp = dict_keyExists(str);
	head = storhead;
	debug("FUN: Leaving globalscope_keyExists()\n");
	return temp;
}

void scope_add(int val, char* str){
	Dict* temp = scope_keyExists(str);
	if(temp == NULL){
		debug("FUN: scope_add adds new key\n");
		dict_add(val, str);
	}
	else {
		debug("FUN: scope_add updates value\n");
		temp->value = val;
	}
}

int scope_getValue(const char* restrict str){
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
	debug("FUN: scope_keyExists(%s), scope: %p, scopehead: %p, head: %p\n", str, scope, scope->dhead, head);
	SymT* current = scope;
	while(current != NULL){
		debug("FUN: scope_keyExists(%s), scope: %p, scopehead: %p, head: %p\n", str, scope, current->dhead, head);
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
	head = scope->dhead;
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
	debug("Head0: %p\n", head);
	printDict(head, i);
	if(!scope->ptr) return;
	SymT* current = scope->ptr;
	while(current != NULL){
		i++;
		debug("Head%d: %p\n", i, current->dhead);
		printDict(current->dhead, i);
		current = current->ptr;
	}
}

// -------------------------------------------------------
/* S T R U C T U R E S  F O R  G R A M M A R  R U L E S */
// -------------------------------------------------------

NodeType* con(int value) {
	//debug("Function \"con\" parameter: %d\n", value);
   NodeType *p;
   if ((p = malloc(sizeof(NodeType))) == NULL)
      yyerror("out of memory");
   p->type = type_constant;
   p->con.value = value;
   return p;
}

NodeType* var(char *str) {
	//debug("Function \"var\" parameter: %s\n", str);
   NodeType *p;
   if ((p = malloc(sizeof(NodeType))) == NULL)
      yyerror("out of memory");
   p->type = type_variable;
   p->var.str = str;
   return p;
}

NodeType* fun(char *str, NodeType *params, NodeType *stmts){
	NodeType *p;
	if((p = malloc(sizeof(NodeType))) == NULL)
		yyerror("out of memory");
	p->type = type_function;
	if((p->fun.str = malloc(strlen(str+1) * sizeof(char))) == NULL)
		yyerror("out of memory");
	p->fun.str = str;
	p->fun.func[0] = params;
	p->fun.func[1] = stmts;
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

void freeNode(NodeType* p) {
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

void yyerror(const char *err){
	if(ttyout)
		fprintf(stderr, BIRED "%s\n" CRST, err);
	else
		fprintf(stderr, "%s\n", err);
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
	char flag_h[] = "\t-h --> print help message\n";
	if(ttyout)
		printf(BCYN "t4compiler [OPTIONS]\nOPTIONS:\n%s%s" CRST, flag_v, flag_h);
	else
		printf("t4compiler [OPTIONS]\nOPTIONS:\n%s%s", flag_v, flag_h);
}

// ----------------------------
/* S T D O U T - C O L O R ? */
// ----------------------------

void check_stdout_color(){
	if(isatty(1)){
		if(strstr(getenv("TERM"), "color") != NULL){
			ttyout = 1;
		}
	}
}

// ===========================
/* M A I N  F U N C T I O N */
// ===========================

int main(int argc, char const* argv[]){
	check_stdout_color();
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
		else if(strcmp(argv[i], "-h") == 0){
			print_help();
		} 
		else {
			if(ttyout)
				fprintf(stderr, BRED "Invalid Option \"%s\"\nSee help message for available options:\n\n" CRST, argv[i]);
			else
				fprintf(stderr, "Invalid Option \"%s\"\nSee help message for available options:\n\n", argv[i]);
			print_help();
			return 1;
		}
	}
	return 0;
}
