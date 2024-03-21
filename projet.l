%option noyywrap
%{
	#include <stdlib.h>
	#include <stdio.h>
	#include "y.tab.c"
%}

blanc         [ \t]+
chiffre       [0-9]
lettre        [a-z|A-Z]
entier        {chiffre}+
identifiant   {lettre}({lettre}|{chiffre})*

%%

"int"         {return(INT);}
{blanc}       {  /* On l'ignore */  }
{entier}      {yyval.num = atoi(yytext); printf("inlex %d\n", yyval.num); return(IMM_INT);}
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
{identifiant} {yyval.ident = strdup(yytext); return(IDENT);}
\"(\\\"|[^"])*\" {yyval.str = strdup(yytext); return(IMM_STR);}

. { yyerror("ident not known"); } 

%%
