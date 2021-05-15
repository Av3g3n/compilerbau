#include <stdio.h>
#include <math.h>
#include "t4_header.h"
#include "t4_parser_gen.tab.h"
int ex(NodeType *p) {
   if (!p) return 0;
   switch(p->type) {
      case typeCon:     return p->con.value;
      case typeId:      return dict_getValue(p->id.str);
      case typeOpr:
      switch(p->opr.oper) {
         case WHILE:    while(ex(p->opr.op[0]))
                           ex(p->opr.op[1]);
                        return 0;
         case IF:       if (ex(p->opr.op[0]))
                           ex(p->opr.op[1]);
                        else if (p->opr.nops > 2)
                           ex(p->opr.op[2]);
                        return 0;
         case PRINT:    printf("%d\n", ex(p->opr.op[0]));
                        return 0;
         case '\n':     ex(p->opr.op[0]); return ex(p->opr.op[1]);
         case '=':      dict_add(ex(p->opr.op[1]), p->opr.op[0]->id.str);
                        printf("Variable: %s, Value: %d\n", p->opr.op[0]->id.str,ex(p->opr.op[1]));
                        return dict_getValue(p->opr.op[0]->id.str);
         case UMINUS:   return -ex(p->opr.op[0]);
         case '+':      return ex(p->opr.op[0]) + ex(p->opr.op[1]);
         case '-':      return ex(p->opr.op[0]) - ex(p->opr.op[1]);
         case '*':      return ex(p->opr.op[0]) * ex(p->opr.op[1]);
         case '/':      return ex(p->opr.op[0]) / ex(p->opr.op[1]);
         case '<':      return ex(p->opr.op[0]) < ex(p->opr.op[1]);
         case '>':      return ex(p->opr.op[0]) > ex(p->opr.op[1]);
         case '^':      return pow(ex(p->opr.op[0]), ex(p->opr.op[1]));
         case GE:       return ex(p->opr.op[0]) >= ex(p->opr.op[1]);
         case LE:       return ex(p->opr.op[0]) <= ex(p->opr.op[1]);
         case NE:       return ex(p->opr.op[0]) != ex(p->opr.op[1]);
         case EQ:       return ex(p->opr.op[0]) == ex(p->opr.op[1]);
      }
   }
   return 0;
}