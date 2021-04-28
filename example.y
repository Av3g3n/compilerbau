/* Definitions Section */
%token INTEGER VARIABLE
%left '+' '-'
%left '*' '/'

%{
/* C - Declarations */ 
#include <stdio.h>
#include <stdlib.h>
void yyerror(char *);
int yylex(void);
int sym[50];
%}

%%
/* Rules Section - where the magic happens */
/* Grammatik und Aktionen */ 
program:
		program statement '\n'
		|
		;
		
statement:	
		expr					      { printf("%d\n", $1); }
		| VARIABLE '=' expr		{ sym[$1] = $3; }
		;

expr:
		INTEGER
		| VARIABLE				   { $$ = sym[$1]; }
		| '-' expr					{ $$ = -$2; }
		| expr '+' expr			{ $$ = $1 + $3;}
		| expr '-' expr			{ $$ = $1 - $3;}
		| expr '*' expr			{ $$ = $1 * $3;}
		| expr '/' expr			{ $$ = $1 / $3;}
		| '(' expr ')'			   { $$ = $2;}
		;

%%
/* C-Definitons/C-Routinen + Subroutinen */ 
void yyerror(char *s){
   fprintf(stderr, "%s\n", s);
	exit(1);
}
int main(void){
   yyparse();
   return 0;
}
