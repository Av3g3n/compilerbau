digit			[0-9]
letter		([a-z]|[A-Z])
number		(0|[1-9]{digit}*)
if				(W|w)(E|e)(N|n){2}
else			(S|s)(O|o)(N|n)(S|s)(T|t)
while			(S|s)(C|c)(H|h)(L|l)(E|e)(I|i)(F|f)(E|e)
global		(G|g)(L|l)(O|o)(B|b)(A|a)(L|l)
print			(H|h)(A|a)(U|u)_(R|r)(A|a)(U|u)(S|s)
bad_chars 	([äÄöÖüÜß])
function		(F|f)(U|u)(N|n)(K|k)(T|t)(I|i)(O|o)(N|n)
showenv		(Z|z)(E|e)(I|i)(G|g)_(V|v)(A|a)(R|r)(S|s)

%{ 
#include <stdlib.h>
#include <string.h>
#include "t4_parser_gen.tab.h"
#include "t4_header.h"
#include "ansi_colors.h"
int line_number = 1;
%}

%%

{if}			return IF;
{else}		return ELSE;
{while}		return WHILE;
{global}		return GLOBAL;
{print}		return PRINT;
{function}	return FUN;
{showenv}	printFromFullScope();
\>=			return GE;
\<=			return LE;
==				return EQ;
!=				return NE;
&&				return AND;
\|\|			return OR;


	/* ----- V A R I A B L E S ----- */

({letter}|_)({letter}|{digit}|_)*	{
													//debug("(l.%d) Variable detected: \"%s\", Length is: %d\n", line_number, yytext, yyleng);
													yylval.var_val = strdup(yytext);
													return VARIABLE;
												}

	/* -------- V A L U E S -------- */

{number}										{
													//debug("(l.%d) Integer detected: %d\n", line_number, atoi(yytext));
													yylval.int_val = atoi(yytext);
													return INTEGER;
												}

	/* ------ O P E R A T O R ------ */

[-+()=<>?:/*^,;{}]								{
													//debug("(l.%d) Operator detected: %c\n", line_number, *yytext);
													char tmp = *yytext;
													return tmp;
												}

	/* --- W H I T E S P A C E S --- */

[ \t]											;

	/* ------- N E W L I N E ------- */

\n 											{
													debug("(l.%d) Newline detected\n", line_number);
													line_number++;
												}

	/* ------ C O M M E N T S ------ */

\/\/.*										{
													//debug("(l.%d) Comment detected\n", line_number);
												}

	/* -------- E R R O R S -------- */
	/* special faulty chars */
{bad_chars}									{
													if(ttyout)
														fprintf(stderr, BIRED "in bad chars: , %d\n" CRST, *yytext);
													else
														fprintf(stderr, "in bad chars: , %d\n", *yytext);
												}

	/* any input, which is not matched, is identified as an error */
.												{
   												if(ttyout)	
														fprintf(stderr, BIRED "Invalid character at line: %d\n" CRST, line_number);
													else
														fprintf(stderr, "Invalid character at line: %d\n", line_number);
												}

%%

int yywrap(void){
	return 1;
}
