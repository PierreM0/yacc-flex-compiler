LEX=flex
YACC=bison -d
CC=gcc

projet: lex.yy.c y.tab.c
	$(CC) -o projet lex.yy.c
lex.yy.c: projet.l
	$(LEX) projet.l
y.tab.c: projet.y
	$(YACC) projet.y
