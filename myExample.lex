%{
	#include <stdio.h>
	yylex();
%}
%option noyywrap

%%

"Wenn"		my_return("IF");
"Dann"		my_return("THEN");
"Sonst"		my_return("ELSE");
"Wahr"		my_return("TRUE");
"Falsch"		my_return("FALSE");
[ \n\t]		;
0[0-9]+		my_return("MALFORMED INPUT");
0				my_return("INTEGER");
[1-9][0-9]*	my_return("INTEGER");
[a-zA-Z]+	my_return("STRING");
.				my_return("NOT IMPLEMENTED INPUT");

%%

int main(){
	while(yylex());
}

int my_return(char *token){
	printf("%s\n", token);
}