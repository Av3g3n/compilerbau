#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include "t4_header.h"
#include "t4_parser_gen.tab.h"

#define lmax 200
#define cmax 200
char graph[lmax][cmax];
char leer = ' ';
int line = 0;
int graphennummer = 0;

void initial();
void drawline(int l, int c);
void draw(char *s, int l, int c);
void ausgabe();
void nodetest(NodeType *p,int c);

int ex (NodeType *p) {
	initial();
	line = 0;
	nodetest(p,0);
	ausgabe();
	return 0;
}

void nodetest(
NodeType *p,
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
				case GLOBAL: s = "GLOBAL";
					break;
				case FUN:
					return;break;
				case IF: s="wenn";
					break;
				case PRINT: s="hau_raus";
					break;
				case '\n': s= "[--]";
					break;
				case '=': s="[=]";
					break;
				case ';': s="[;]";
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
	
	if(line==0&&c==0)
	{	
		if(s!="[--]"){
			draw(s,line,c);
			c--;
		}
		
	}else if(line>0&&c>0)	{
		int d = c;
		char seq[20]="???";
		sprintf(seq," >----%s",s);
		s = seq;
		
		for(int x = 1;x<c;x++){
			d=d+3;
		}
		draw(s,line,d);
		
	}else{
		int d = c;
		char seq[20]="???";
		sprintf(seq," >----%s",s);
		s = seq;
		if(c>1){
			for(int i = 0;i<c;i++){
				d=d+3;
			}
		}
		draw(s,line,d);
	}
	
	if(p->type==type_operator){
		if (p->opr.nops > 0)
			nodetest(p->opr.op[0],c+2);
		if (p->opr.nops > 1)
			nodetest(p->opr.op[1],c+2);
		if (p->opr.nops > 2)
			nodetest(p->opr.op[2],c+2);
	}
}

void initial(){
	for(int x = 0; x<=lmax; x++){
		for(int y = 0; y<=cmax; y++){
			graph[x][y]=leer;	
		}
	}
}

void drawline(int l, int c){
	for(int x = l-1; x >= 0 ; x--){
		if(graph[x][c]!=leer)
			break;
		graph[x][c]='|';
	}
}

void draw(char *s, int l, int c){
	int size = 0;
	for(int x = 0; s[x]!='\0';x++){
		size++;
	}	
	for(int y = 0; y <= size; y++){
		if((c+y)<=cmax)
			graph[line][c+y]=s[y];
	}
	line=line +1;
	drawline(line,c);
}

void ausgabe(){
	if(graph[0][0]!=leer)
		printf("Graph: %d:\n\n",graphennummer++);
	for(int x = 0; x < lmax; x++){

		int clast = cmax;
		for(clast; clast>=0; clast--){
			if(graph[x][clast]!=leer)
			{	
				clast++;
				break;
			}
		}
		
		int y = 0;
		for(y; y < clast; y++){
			printf("%c",graph[x][y]);
		}
		if(y != 0){
			printf("\n");
		}
	}
	printf("\n");
}