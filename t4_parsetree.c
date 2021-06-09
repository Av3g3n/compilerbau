#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include "t4_header.h"
#include "t4_parser_gen.tab.h"


int del = 1; /* distance of graph columns */
int eps = 3; /* distance of graph lines */
int graphennummer = 0;

void nodetest(NodeType *p,int l,int c);


int ex (NodeType *p) {
	nodetest(p,0,0);
	return 0;
}


void nodetest(
NodeType *p,
int l,
int c
){
	char* s;
	char word[20]; 
	strcpy (word, "???"); 
	s = word;
	
	if (!p) return;
	switch(p->type) {
		case type_constant:
			sprintf (word, "c(%d)", p->con.value); 
			break;
		case type_variable:
			sprintf (word,"var(%s)", p->var.str);
			break;
		case type_operator:
			switch(p->opr.oper){
				case WHILE: s="schleife";
					break;
				case IF: s="wenn";
					break;
				case PRINT: s="hau_raus";
					break;
				case '\n': s= "[  ]";
					break;
				case '=': s="[=]";
					break;
				case UMINUS: s="[_]"; break;
				case '+':  s="[+]";
					break;
				case '-':  s="[-]";
					break;
				case '*':  s="[*]";
					break;
				case '/':  s="[/]";
					break;
				case '<':  s="[<]";
					break;
				case '>': s="[>]";
					break;
				case '^':  s="[^]";
					break;
				case GE:  s="[>=]"; 
					break;
				case LE:  s="[<=]";
					break;
				case NE:  s="[!=]"; 
					break;
				case EQ:  s="[==]";
					break;
				case AND:  s="[&&]"; 
					break;
				case OR:  s="[||]"; 
					break;
			}
	}
		
	
	if(l==0&&c==0)
	{	
		if(s!="[  ]"){
			printf("\n");
			printf("Graph %d:\n\n",graphennummer);
			printf("%s\n",s);
			graphennummer++;
			l++;
		}
	}else if(l>0&&c>0)
	{
		for(int x = 1;x<c;x++){
			printf(" |  ");printf("   ");
		}
		printf(" >----%s\n",s);
	}else{
		printf(" |  ");
		if(c>1){
			for(int i = 0;i<c;i++){
				printf("   ");
			}
		}
		printf("%s\n",s);
		l++;
	}
	
	if(p->type==type_operator){
		if (p->opr.nops > 0)
			nodetest(p->opr.op[0],l,c+1);
		if (p->opr.nops > 1)
			nodetest(p->opr.op[1],l,c+1);
		if (p->opr.nops > 2)
			nodetest(p->opr.op[2],l,c+1);
	}
	
	
}
