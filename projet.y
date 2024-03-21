%{
struct node;
typedef struct node Node;

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include "tree.h"


int yylex();
void yyerror(char* msg);
/*TODO: en faire un tableau dynamique*/
%}

%union {
  int num;
  char* str;
  char* ident;
  struct node* node;
};
%start input 

%right ASSIGN
%left EQUAL ADD
%nonassoc OPEN_PAREN CLOSE_PAREN NOT
%nonassoc INT SEMICOLON END ELSE DO 
%left IF WHILE 
%nonassoc <num> IMM_INT
%nonassoc <str> IMM_STR 
%nonassoc <ident> IDENT

%type <node> input body expr funcall assign_stmt assign_stmt_decl statement
%type <node> while_control_flow if_control_flow type

%%
input:
     body
     {
     $$ = $1;
     }

body:
    body body 
    {
      $$ = new_statement($1, $2);
    }
    | if_control_flow
    {
      $$ = $1;
    }
    | while_control_flow
    {
      $$ = $1;
    }
    | statement SEMICOLON
    {
      $$ = $1;
    }


statement:
     assign_stmt_decl
     {
       $$ = $1;
     }
     | assign_stmt
     {
       $$ = $1;
     }
     | expr
     {
       $$ = $1;
     }

    /*todo: everyting must be an expr: also block etc.*/

if_control_flow:
	       IF expr DO body END
	       {
	       //assert("Not implemented");
	       }
	       | IF expr DO body ELSE body END
	       {
	       //assert("Not implemented");
	       }

while_control_flow:
		  WHILE expr DO body END
		  {
		      $$ = new_while($2, $4);
		  }

assign_stmt_decl: 
		     type IDENT ASSIGN expr
		     {
		        $$ = new_declaration($2, $1, $4);
		     }
	
assign_stmt: 
	   IDENT ASSIGN expr
	   {
	      $$ = new_assign($1, $3);
	   }

funcall:
       IDENT OPEN_PAREN expr CLOSE_PAREN
       {
         $$ = new_funcall($1, $3);
       }

type:
    INT 	  
    {
	  //assert(0, "Not implemented");
    }

expr:
      NOT expr
	{
	  $$ = new_unaryop(NODETYPE_NOT, $2);
	}
	| expr EQUAL expr
	{
	  $$ = new_binop($1, NODETYPE_EQUAL, $3);
	}
	| expr ADD expr
	{
	  $$ = new_binop($1, NODETYPE_ADD, $3);
	}
        | OPEN_PAREN expr CLOSE_PAREN
	{
	  $$ = $2;
	}
        | funcall 
	{
	  $$ = $1;
	}
        | IMM_INT 
	  {
	  $$ = new_imm((void*) $1, NODETYPE_IMM_INT);
	  }
        | IMM_STR
	  {
	  //assert(0, "Not implemented");
	  }
	| IDENT
	{
	  $$ = new_var($1);
	}

%%

void yyerror(char* msg) {
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
	Node* start = yyparse();

	generate_code(start);
	return 69;
}
