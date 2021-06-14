#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <unistd.h>
#include "t4_header.h"
#include "t4_parser_gen.tab.h"
#include "ansi_colors.h"

int ex(NodeType *p) {
   if (!p) return 0;
   switch(p->type) {
      case type_constant:     return p->con.value;
      case type_variable:     //debug("INTERPRETER: type_variable: %s\n", p->var.str);
                              return scope_getValue(p->var.str);
      case type_function:     //
                              return;
      case type_operator:
      switch(p->opr.oper) {
         case FUN:            // get functionNode via string
                              // def params
                              // exec
                              return 0;
         case WHILE:          new_scope();
                              while(ex(p->opr.op[0]))
                                 ex(p->opr.op[1]);
                              free_scope();
                              return 0;
         case IF:             //debug("INTERPRETER: IF\n");
                              if (ex(p->opr.op[0])){
                                 new_scope();
                                 ex(p->opr.op[1]);
                                 free_scope();
                              }
                              else if (p->opr.nops == 3){
                                 new_scope();
                                 ex(p->opr.op[2]);
                                 free_scope();
                              }
                              return 0;
         case PRINT:          if(ttyout)
                                 printf(BIBLA WHIB ">>>" CRST BPUR " %d\n" CRST, ex(p->opr.op[0]));
                              else
                                 printf("%d\n", ex(p->opr.op[0]));
                              return 0;
         case GLOBAL:         globalscope_add(ex(p->opr.op[1]), p->opr.op[0]->var.str);
                              debug("\n\n>>> PRINTFULLSCOPE GLOBAL <<<\n\n");
                              printFromFullScope();
                              return scope_getValue(p->opr.op[0]->var.str);
         case ';':            // works right?
                              //debug("INTERPRETER: \\n\n");
                              ex(p->opr.op[0]); return ex(p->opr.op[1]);
         case '=':            //debug("INTERPRETER: %s = %d\n", p->opr.op[0]->var.str, ex(p->opr.op[1]));
                              scope_add(ex(p->opr.op[1]), p->opr.op[0]->var.str);
                              debug("\n\n>>> PRINTFULLSCOPE = <<<\n\n");
                              printFromFullScope();
                              //debug("INTERPRETER: GETVALUE --> %d\n", scope_getValue(p->opr.op[0]->var.str));
                              return scope_getValue(p->opr.op[0]->var.str);
         case ',':            // works ?
                              ex(p->opr.op[0]); return ex(p->opr.op[1]);
         case UMINUS:         return -ex(p->opr.op[0]);
         case '+':            return ex(p->opr.op[0]) + ex(p->opr.op[1]);
         case '-':            return ex(p->opr.op[0]) - ex(p->opr.op[1]);
         case '*':            return ex(p->opr.op[0]) * ex(p->opr.op[1]);
         case '/':            return ex(p->opr.op[0]) / ex(p->opr.op[1]);
         case '<':            return ex(p->opr.op[0]) < ex(p->opr.op[1]);
         case '>':            return ex(p->opr.op[0]) > ex(p->opr.op[1]);
         case '^':            return pow(ex(p->opr.op[0]), ex(p->opr.op[1]));
         case GE:             return ex(p->opr.op[0]) >= ex(p->opr.op[1]);
         case LE:             return ex(p->opr.op[0]) <= ex(p->opr.op[1]);
         case NE:             return ex(p->opr.op[0]) != ex(p->opr.op[1]);
         case EQ:             return ex(p->opr.op[0]) == ex(p->opr.op[1]);
         case AND:            return ex(p->opr.op[0]) && ex(p->opr.op[1]);
         case OR:             return ex(p->opr.op[0]) || ex(p->opr.op[1]);      
      }
   }
   return 0;
}