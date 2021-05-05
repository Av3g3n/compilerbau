/* Definition Section */
%{
/* C - Declarations */ 
#include <stdio.h>
#include <stdlib.h>
void yyerror(char *);
int yylex(void);
int sym[1000];
%}

/* union here! */

%token INTEGER VARIABLE
%token IF ELSE EXIT COMMENT OR AND
%nonassoc IFX
%nonassoc ELSE
%left GE LE EQ NE '<' '>'
%left '+' '-'
%left '*' '/'

%%
/* Rules Section - where the magic happens */

program:
		program statement '\n'
		| program statement comment '\n'
		| program comment '\n'
		|
		;
		
statement:	
		expr					      							{ printf("%d\n", $1); }
		| VARIABLE '=' expr									{ sym[$1] = $3; }
		| IF '(' cond ')' statement %prec IFX			{ 	if($3){
																			$$=$5;
																		}
																	}
		| IF '(' cond ')' statement ELSE statement	{ 
																		if($3){
																			$$=$5;
																		} else {
																			$$=$7; 
																		}
																	}
		| EXIT													{ exit(0); }
		;

cond:
		| expr '<' expr			{ $$ = ($1 < $3); }
		| expr '>' expr			{ $$ = ($1 > $3); }
		| expr GE expr				{ $$ = ($1 >= $3); }
		| expr LE expr				{ $$ = ($1 <= $3); }
		| expr EQ expr				{ $$ = ($1 == $3); }
		| expr NE expr				{ $$ = ($1 != $3); }
		| cond AND cond			{ $$ = ($1 && $3); }
		| cond OR cond				{ $$ = ($1 || $3); }
		;

expr:
		INTEGER
		| VARIABLE				   { $$ = sym[$1]; }
		| '-' expr					{ $$ = -$2; }
		| expr '+' expr			{ $$ = $1 + $3; }
		| expr '-' expr			{ $$ = $1 - $3; }
		| expr '*' expr			{ $$ = $1 * $3; }
		| expr '/' expr			{ $$ = $1 / $3; }
		| '(' expr ')'			   { $$ = $2; }
		;

comment:
		COMMENT						;
		;

%%
/* C-Definitons/C-Routinen + Subroutinen */ 
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
