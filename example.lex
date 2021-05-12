digit			[0-9]
letter		([a-z]|[A-Z])
number		(0|[1-9]{digit}*)
if				(W|w)(E|e)(N|n){2}
else			(S|s)(O|o)(N|n)(S|s)(T|t)
while			(S|s)(C|c)(H|h)(L|l)(E|e)(I|i)(F|f)(E|e)
const			(S|s)(T|t)(A|a)(B|b)(I|i)(L|l)
print			(H|h)(A|a)(U|u)_(R|r)(A|a)(U|u)(S|s)

%{ 
#include <stdlib.h>
#include <string.h>
#include "example.tab.h"
void yyerror(char *);
int line_number = 1;
%}

%%

{if}		return IF;
{else}	return ELSE;
{while}	return WHILE;
{const}	return CONST;
{print}	return PRINT;
\>=		return GE;
\<=		return LE;
==			return EQ;
!=			return NE;
&&			return AND;
\|\|		return OR;

	/* ----- V A R I A B L E S ----- */

({letter}|_)({letter}|{digit}|_)*	{
													yylval._str = yytext;
													printf("Variable detected: %s\n", yytext);
													return VARIABLE;
												}

	/* -------- V A L U E S -------- */

{number}										{
													yylval._int = atoi(yytext);
													printf("Integer detected: %d\n", atoi(yytext));
													return INTEGER;
												}

	/* ------ O P E R A N D S ------ */

[-+()=<>/*]									return *yytext;

	/* --- W H I T E S P A C E S --- */

[ \t]											;

	/* ------- N E W L I N E ------- */

\n 											{
													line_number++;
													printf("Newline detected\n");
													return *yytext;
												}

	/* ------ C O M M E N T S ------ */

\/\/.*										printf("Comment detected\n"); return COMMENT;

	/* -------- E R R O R S -------- */
	/* any input, which is not matched, is identified as an error */

.												{
													char error_msg[] = "not recognized input, see line:";
													char tmp[10];
													snprintf(tmp,10,"%d", line_number);
													strncat(error_msg,tmp,strlen(tmp));
													yyerror(error_msg);
												}

%%

int yywrap(void){
	return 1;
}
