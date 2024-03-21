%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int yylex();
/* The extra parameter is also given to yyerror */
%}

%union {int num;}
%start input 

%token INT IDENT SEMICOLON END IF WHILE ELSE DO ASSIGN IMM_STR
%left EQUAL ADD IMM_STR OPEN_PAREN CLOSE_PAREN NOT
%left <num> IMM_INT

%%
input:
     input ligne
     | /* vide */
     {
	printf("input\n");
     };


ligne:
     assign_expr_with_decl
     | assign_expr 
     | if_control_flow
     | while_control_flow
     | funcall
     {
	printf("ligne\n");
     }

if_control_flow:
	       IF expr DO input END
	       | IF expr DO input ELSE input END
	       {
	         printf("if\n");
	       }

while_control_flow:
		  WHILE expr DO input END
		  {
		    printf("while\n");
		  }

assign_expr_with_decl: 
		     type IDENT ASSIGN expr SEMICOLON
		     {
		       printf("assign with decl\n");
		     }
	
assign_expr: 
	   IDENT ASSIGN expr SEMICOLON
	   {
	     printf("assign no decl\n");
	   }

funcall:
       IDENT OPEN_PAREN IDENT CLOSE_PAREN SEMICOLON
       {
         printf("funcall\n");
       }

type:
    INT 

expr:
      NOT expr
	| expr EQUAL expr
	| expr ADD expr
        | OPEN_PAREN expr CLOSE_PAREN
        | IMM_INT 
	  {
	    printf("dans expr: %d", $1.num);
	  }
        | IMM_STR
	| IDENT
%%

void yyerror(const char* msg) {
	printf("ERROR:%d: %s.\n", yylineno, msg);
}

int main(int argc, char* argv[]) {
	if (argc != 2) {
	  fprintf(stderr, "USAGE: ./projet <source file>\n");
	  exit(1);
	}
	FILE * fp = fopen(argv[1], "r");
	if (fp == NULL) {
	  fprintf(stderr, "ERROR: can't open src file.\n");
	}

	yyin = fp;
	yyparse();
	return 69;
}
