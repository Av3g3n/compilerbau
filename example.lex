digit			[0-9]
letter		([a-z]|[A-Z])
letter_low	[a-z]
letter_high [A-Z]
number		(0|[1-9]{digit}*)
number_neg	[1-9]{digit}*
%{ 
/* C-Deklarationen - werden direkt kopiert */
#include <stdlib.h>
#include "example.tab.h"
void yyerror(char *);
%}

%%

	/* ----------------------------- */
	/* ----- V A R I A B L E S ----- */
	/* ----------------------------- */
	/* regex          	zugehörige Aktion / C-Anweisung */

{letter}+									{   
													yylval = *yytext;
													return VARIABLE;
												}
	/* ----------------------------- */
	/* -------- V A L U E S -------- */
	/* ----------------------------- */
	/* EXPLANATION PLEASE */

{number}										{
													yylval = atoi(yytext);
													return INTEGER;
												}
	/* ----------------------------- */
	/* ----- O P E R A T O R S ----- */
	/* ----------------------------- */
	/* EXPLANATION PLEASE */

[-+()=/*\n]									return *yytext;
	/* ----------------------------- */
	/* --- W H I T E S P A C E S --- */
	/* ----------------------------- */
	/* EXPLANATION PLEASE */

[ \t]											;
	/* ----------------------------- */
	/* -------- E R R O R S -------- */
	/* ----------------------------- */
	/* any input, which is not matched, is identified as an error */

.												yyerror("invalid input");

%%

/* Definitonen von Datenstrukturen und Funktionen die in Scanner kopiert werden */
int yywrap(void){
	return 1;
}
