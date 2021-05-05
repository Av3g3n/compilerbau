digit			[0-9]
letter		([a-z]|[A-Z])
letter_low	[a-z]
letter_high [A-Z]
number		(0|[1-9]{digit}*)
exit			(V|v)(E|e)(R|r)(L|l)(A|a)(S|s){2}(E|e)(N|n)
if				(W|w)(E|e)(N|n){2}
else			(S|s)(O|o)(N|n)(S|s)(T|t)
%{ 
/* C-Deklarationen - werden direkt kopiert */
#include <stdlib.h>
#include <string.h>
#include "example.tab.h"
void yyerror(char *);
int line_number = 1;
%}

%%

{exit}	return EXIT;
{if}		return IF;
{else}	return ELSE;
\>=		return GE;
\<=		return LE;
==			return EQ;
!=			return NE;
&&			return AND;
\|\|			return OR;

	/* ----- V A R I A B L E S ----- */
	/* regex          	zugehörige Aktion / C-Anweisung */
	/* NOTE: does not work as expected --> zzz=50 -> z=50 */

{letter}+									{
													yylval = *yytext;
													return VARIABLE;
												}

	/* -------- V A L U E S -------- */

{number}										{
													yylval = atoi(yytext);
													return INTEGER;
												}

	/* ------ O P E R A N D S ------ */

[-+()=<>/*]									return *yytext;

	/* --- W H I T E S P A C E S --- */

[ \t]											;

	/* ------- N E W L I N E ------- */

\n 											{
													line_number++;
													return *yytext;
												}

	/* ------ C O M M E N T S ------ */

\/\/.*										return COMMENT;

	/* -------- E R R O R S -------- */
	/* any input, which is not matched, is identified as an error */

.												{
													char error_msg[] = "invalid input, see line:";
													char tmp[10];
													snprintf(tmp,10,"%d", line_number);
													strncat(error_msg,tmp,strlen(tmp));
													yyerror(error_msg);
												}

%%

/* Definitonen von Datenstrukturen und Funktionen die in Scanner kopiert werden */
int yywrap(void){
	return 1;
}
