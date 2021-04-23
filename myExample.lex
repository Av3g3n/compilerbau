%{
	#include <stdio.h>
	yylex();
%}
%option noyywrap

%%
	/* Kontrollstrukturen */
(?i:WENN)		my_return("IF");
(?i:DANN)		my_return("THEN");
(?i:SONST)		my_return("ELSE");
(?i:NAIS)		my_return("TRUE");
(?i:FALSCH)		my_return("FALSE");
(?i:MERKELN)		my_return("WHILE");
(?i:LOST)		my_return("NULL");

	/* Vergleichsoperatoren */
"=="			my_return("EQUALS");
"!="			my_return("NOT EQUALS");
"<="			my_return("LESS EQUALS");
">="			my_return("MORE EQUALS");
"<"			my_return("LESS");
">"			my_return("MORE");

	/* Zeichen */
"+"			my_return("PLUS");
"-"			my_return("MINUS");
"*"			my_return("MULTIPLY");
"/"			my_return("DIVIDE");
"=" 			my_return("VALUE ASSIGNMENT");
";"			my_return("END OF LINE");

	/* Variablen Bezeichner */ 
(?i:INT)		my_return("INT");
(?i:STRING)		my_return("STRING");

	/* Variablen Werte */
[ \n\t]			;
0[0-9]+			my_return("MALFORMED INPUT");
0			my_return("INTEGER");
[1-9][0-9]*		my_return("INTEGER");
(\"[a-zA-Z0-9 ']*\"|'[a-zA-Z0-9 "]')	my_return("STRINGTEXT");
\"			my_return("FEHLERHAFTE EINGABE");

	/* Variablen Namen */
[a-zA-Z]+[a-zA-Z0-9]*	my_return("VARNAME");

	/* Default Case */
.			my_return("NOT IMPLEMENTED INPUT");

%%

int main(){
	while(yylex());
}

int my_return(char *token){
	printf("%s\n", token);
}
