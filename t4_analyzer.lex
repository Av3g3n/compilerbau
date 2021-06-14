digit			[0-9]
letter		([a-z]|[A-Z])
number		(0|[1-9]{digit}*)
if				(W|w)(E|e)(N|n){2}
else			(S|s)(O|o)(N|n)(S|s)(T|t)
while			(S|s)(C|c)(H|h)(L|l)(E|e)(I|i)(F|f)(E|e)
const			(S|s)(T|t)(A|a)(B|b)(I|i)(L|l)
print			(H|h)(A|a)(U|u)_(R|r)(A|a)(U|u)(S|s)
bad_chars 	([äÄöÖüÜß])

%{ 
#include <stdlib.h>
#include <string.h>
#include "t4_parser_gen.tab.h"
#include "t4_header.h"
void yyerror(const char *);
int line_number = 1;
%}

%%

{if}			return IF;
{else}		return ELSE;
{while}		return WHILE;
	/* {const}	return CONST; */
{print}		return PRINT;
\>=			return GE;
\<=			return LE;
==				return EQ;
!=				return NE;
&&				return AND;
\|\|			return OR;


	/* ----- V A R I A B L E S ----- */

	/* TODO: just allow variables with underscore with following form: */
	/* _X  */
	/* __X */ 
	/* X_  */
	/* X_X */

({letter}|_)({letter}|{digit}|_)*	{
													debug("(l.%d) Variable detected: \"%s\", Length is: %d\n", line_number, yytext, yyleng);
													yylval.var_val = strdup(yytext);
													return VARIABLE;
												}

	/* -------- V A L U E S -------- */

{number}										{
													debug("(l.%d) Integer detected: %d\n", line_number, atoi(yytext));
													yylval.int_val = atoi(yytext);
													return INTEGER;
												}

	/* ------ O P E R A T O R ------ */

[-+()=<>?:/*^]								{
													debug("(l.%d) Operator detected: %c\n", line_number, *yytext);
													char tmp = *yytext;
													return tmp;
												}

	/* --- W H I T E S P A C E S --- */

[ ]											;

	/* ------- N E W L I N E ------- */

\n 											{
													debug("(l.%d) Newline detected\n", line_number);
													setCurrentLine(line_number);
													line_number++;
													return '\n';
												}

	/* ----------- T A B ----------- */

\t												{
													debug("(l.%d) Tab detected\n", line_number);
													return '\t';
												}

	/* ------ C O M M E N T S ------ */

\/\/.*										{
													debug("(l.%d) Comment detected\n", line_number);
												}

	/* -------- E R R O R S -------- */
	/* special faulty chars */
{bad_chars}											{
													printf("in bad chars: , %d\n", *yytext);
												}

	/* any input, which is not matched, is identified as an error */
.												{
   													//char *testing = strdup(yytext);
													
													char result_string[22] = "Invalid Character '";
													strcat(result_string, yytext);
													strcat(result_string, "'");
													//printf("yytext, String: %s, Zahl: %d\n", yytext , testing);
													yyerror(result_string);
													// return TRASH;
												}

%%

int yywrap(void){
	return 1;
}
