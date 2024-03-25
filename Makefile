LEX=flex
YACC=bison -d
CC=gcc
QBE=qbe

compile: projet
	./projet file.src output.qbir
	$(QBE) output.qbir > output.s
	$(CC) output.s

projet: lex.yy.c y.tab.c
	$(CC) -o projet lex.yy.c -ggdb
lex.yy.c: projet.l
	$(LEX) projet.l
y.tab.c: projet.y
	$(YACC) projet.y
clean:
	rm projet.*.c & rm projet.*.h & rm projet & rm out* & rm a.out
