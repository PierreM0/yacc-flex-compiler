%option noyywrap
%{
	#include <stdlib.h>
	#include <stdio.h>
	#include "projet.tab.h"
	#include "projet.tab.c"
%}


blanc         [ \t]+
chiffre       [0-9]
lettre        [a-z|A-Z]
entier        {chiffre}+
identifiant   {lettre}({lettre}|{chiffre})*

%%

"int"         {return(INT);}
{blanc}       {  /* On l'ignore */  }
{entier}      {yylval.num = atoi(yytext); return(IMM_INT);}
"\n"          {yylineno += 1;}
"="           {return(EQUAL);}
":="          {return(ASSIGN);}
";"           {return(SEMICOLON);}
"while"       {return(WHILE);}
"if"          {return(IF);}
"else"        {return(ELSE);}
"do"          {return(DO);}
"end"         {return(END);}
"not"         {return(NOT);}
"+"           {return(ADD);}
"("           {return(OPEN_PAREN);}
")"           {return(CLOSE_PAREN);}
{identifiant} {yylval.ident = strdup(yytext); return(IDENT);}
\"(\\\"|[^"])*\" {yylval.str = strdup(yytext); return(IMM_STR);}

. { yyerror("ident not known"); } 

%%
