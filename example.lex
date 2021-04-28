%{ 
/* C-Deklarationen - werden direkt kopiert */
#include <stdlib.h>
#include "example.tab.h"
void yyerror(char *);
%}
%%
	/* variables */
    /* regex         zugehörige Aktion / C-Anweisung */
[a-z]+				{   
						yylval = *yytext - 'a';
						return VARIABLE;
					}
	/* integers */
[0-9]+			{
						yylval = atoi(yytext);
						return INTEGER;
					}
	/* operators */
[-+()=/*\n]			{ return *yytext; }
	/* skip whitespace */
[ \t]					;
	/* anything else is an error */
.						yyerror("invalid character");
%%
/* Definitonen von Datenstrukturen und Funktionen die in Scanner kopiert werden*/
int yywrap(void){
	return 1;
}
