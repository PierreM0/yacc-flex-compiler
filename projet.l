%option noyywrap
%{
	#include <stdlib.h>
	#include <stdio.h>
#include "tree.h"
#include "generator.h"
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
{entier}      {yylval.num = atol(yytext); return(IMM_INT);}
[\n\r]   {yylineno += 1;}
"="           {return(EQUAL);}
":="          {return(ASSIGN);}
";"           {return(SEMICOLON);}
","           {return(COMMA);}
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

. {
    char* str = malloc(64);
    sprintf(str, "ident not known: `%d`", strdup(yytext)[0]);
    yyerror(str);
 }

%%
