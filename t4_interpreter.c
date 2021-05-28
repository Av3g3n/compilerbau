#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "t4_header.h"
#include "t4_parser_gen.tab.h"
int ex(NodeType *p) {
   if (!p) return 0;
   switch(p->type) {
      case type_constant:     return p->con.value;
      case type_variable:     {
                                 debug("RETURN VARIABLE VALUE: \"%s\"\n", p->var.str);
                                 return dict_getValue(p->var.str);
                              }
      case type_operator:
      switch(p->opr.oper) {
         case WHILE:          while(ex(p->opr.op[0]))
                                 ex(p->opr.op[1]);
                              return 0;
         case IF:             if (ex(p->opr.op[0]))
                                 ex(p->opr.op[1]);
                              else if (p->opr.nops > 2)
                                 ex(p->opr.op[2]);
                              return 0;
         case PRINT:          printf("%d\n", ex(p->opr.op[0]));
                              return 0;
         case '\n':           /* WORKS? */
                              debug("Section \"\\n\"\n\tNode1: \"%d\"\n\tNode2: \"%d\"\n", ex(p->opr.op[0]), ex(p->opr.op[1]));
                              ex(p->opr.op[0]); return ex(p->opr.op[1]);
         case '=':            debug("Section \"=\"\vVariable: \"%s\"\vValue: \"%d\"\n", p->opr.op[0]->var.str, ex(p->opr.op[1]));
                              dict_add(ex(p->opr.op[1]), p->opr.op[0]->var.str);
                              debug("Value of return is: %d\n", dict_getValue(p->opr.op[0]->var.str));
                              return dict_getValue(p->opr.op[0]->var.str);
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