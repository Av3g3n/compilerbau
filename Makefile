FILEPREFIX=$(FIN)
OUTPUTFILE=$(FOUT)
MODE=$(FMODE)

executable: $(FILEPREFIX).tab.c lex.yy.c $(MODE).c
	cc $(FILEPREFIX).tab.c lex.yy.c $(MODE).c -o $(OUTPUTFILE)

$(FILEPREFIX).tab.c $(FILEPREFIX).tab.h: $(FILEPREFIX).y
	bison -d $(FILEPREFIX).y

lex.yy.c: $(FILEPREFIX).lex
	flex $(FILEPREFIX).lex

clean:
	rm $(FILEPREFIX).tab.h $(FILEPREFIX).tab.c lex.yy.c $(OUTPUTFILE)
