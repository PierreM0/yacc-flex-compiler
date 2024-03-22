%{
#include "tree.h"
#include "generator.h"
struct node;
typedef struct node Node;

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>


Node* start;
int yylex();
void yyerror(char* msg);
/*TODO: en faire un tableau dynamique*/
%}

%union {
  long num;
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
     start = $1;
     printf("input -> body: %p\n",start); 
     }

body:
    body body 
    {
      $$ = new_statement($1, $2);
     printf("body -> body: %p\n", $$);
    }
    | if_control_flow
    {
      $$ = $1;
     printf("body -> if: %p\n", $$);
    }
    | while_control_flow
    {
      $$ = $1;
     printf("body -> while: %p\n", $$);
    }
    | statement SEMICOLON
    {
      $$ = $1;
     printf("body -> statemement ; : %p\n", $$);
    }


statement:
     assign_stmt_decl
     {
       $$ = $1;
       printf("stmt -> assign: %p\n", $$);
     }
     | assign_stmt
     {
       $$ = $1;
       printf("stmt -> assign: %p\n", $$);
     }
     | expr
     {
       $$ = $1;
       printf("stmt -> expr: %p\n", $$);
     }

    /*todo: everyting must be an expr: also block etc.*/

if_control_flow:
	       IF expr DO body END
	       {
	       //assert("Not implemented");
       printf("if-> if do end: %p\n", $$);
	       }
	       | IF expr DO body ELSE body END
	       {
	       //assert("Not implemented");
       printf("if-> if do else end: %p\n", $$);
	       }

while_control_flow:
		  WHILE expr DO body END
		  {
		      $$ = new_while($2, $4);
       printf("while -> while do end: %p\n", $$);
		  }

assign_stmt_decl: 
		     type IDENT ASSIGN expr
		     {
		        $$ = new_declaration($2, $1, $4);
       printf("assign-> type ident <- expr: %p\n", $$);
		     }
	
assign_stmt: 
	   IDENT ASSIGN expr
	   {
	      $$ = new_assign($1, $3);
       printf("assign-> ident <- expr: %p\n", $$);
	   }

funcall:
       IDENT OPEN_PAREN expr CLOSE_PAREN
       {
         $$ = new_funcall($1, $3);
       printf("funcall -> ident ( expr ): %p\n", $$);
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
       printf("expr -> not expr: %p\n", $$);
	}
	| expr EQUAL expr
	{
	  $$ = new_binop($1, NODETYPE_EQUAL, $3);
       printf("expr -> expr = expr: %p\n", $$);
	}
	| expr ADD expr
	{
	  $$ = new_binop($1, NODETYPE_ADD, $3);
       printf("expr -> expr + expr: %p\n", $$);
	}
        | OPEN_PAREN expr CLOSE_PAREN
	{
	  $$ = $2;
       printf("expr -> (expr ): %p\n", $$);
	}
        | funcall 
	{
	  $$ = $1;
       printf("expr -> funcall: %p\n", $$);
	}
        | IMM_INT 
	  {
	  $$ = new_imm((void*) $1, NODETYPE_IMM_INT);
       printf("expr -> imm int: %p\n", $$);
	  }
        | IMM_STR
	  {
	  //assert(0, "Not implemented");
	  }
	| IDENT
	{
	  $$ = new_var($1);
       printf("expr -> ident: %p\n", $$);
	}

%%

void yyerror(char* msg) {
	printf("ERROR:%d: %s.\n", yylineno, msg);
}

int main(int argc, char* argv[]) {
	#if 0
	if (argc != 2) {
	  fprintf(stderr, "USAGE: ./projet <source file>\n");
	  exit(1);
	}
	FILE * fp = fopen(argv[1], "r");
	#else
	FILE * fp = fopen("./file.src", "r");
	#endif
	if (fp == NULL) {
	  fprintf(stderr, "ERROR: can't open src file.\n");
	}
	yyin = fp;
	yyparse();
	printf("start: %p", start);

	generate_code(start);
	return 69;
}
