FILEPREFIX=$(FIN)
OUTPUTFILE=$(FOUT)

myexe: $(FILEPREFIX).tab.c lex.yy.c
	cc $(FILEPREFIX).tab.c lex.yy.c -o $(OUTPUTFILE)

$(FILEPREFIX).tab.c $(FILEPREFIX).tab.h: $(FILEPREFIX).y
	bison -d $(FILEPREFIX).y

lex.yy.c: $(FILEPREFIX).lex
	flex $(FILEPREFIX).lex

clean:
	rm $(FILEPREFIX).tab.h $(FILEPREFIX).tab.c lex.yy.c $(OUTPUTFILE)
