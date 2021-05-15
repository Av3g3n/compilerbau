FLEXFILE=t4_analyzer
BISONFILE=t4_parser_gen
OUTPUTFILE=t4compiler
MODE=$(FMODE)

t4compiler: $(BISONFILE).tab.c lex.yy.c t4_$(MODE).c
	cc $(BISONFILE).tab.c lex.yy.c t4_$(MODE).c -o $(OUTPUTFILE) -lm

$(BISONFILE).tab.c $(BISONFILE).tab.h: $(BISONFILE).y
	bison -d $(BISONFILE).y

lex.yy.c: $(FLEXFILE).lex
	flex $(FLEXFILE).lex

clean:
	rm $(BISONFILE).tab.h $(BISONFILE).tab.c lex.yy.c $(OUTPUTFILE)
