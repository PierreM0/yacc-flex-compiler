#ifndef GENERATOR_H
#define GENERATOR_H

#include <stdio.h>
#include "tree.h"

static inline void generate_binop_code(Node* node) {
}

static inline void generate_node_code(Node* node) {
  switch (node->type) {
  case NODETYPE_BINOP:
    // generate_binop_code(node);
    break;
  case NODETYPE_UNARY:
    // generate_unary_code(node);
    break;
  case NODETYPE_IMM:
    // generate_imm_code(node);
    break;
  case NODETYPE_STMT:
    // generate_stmt_code(node);
    break;
  case NODETYPE_FUNCALL:
    // generate_funcall_code(node);
    break;
  case NODETYPE_VAR:
    // generate_var_code(node);
    break;
  case NODETYPE_WHILE:
    // generate_while_code(node);
    break;
  case NODETYPE_ASSIGN:
     // generate_assign_code(node);
    break;
  }
}

inline void generate_code(Node* start) {
	printf(
	"export function w $main() {\n"
	"@start\n"
	);
	
	generate_node_code(start);
  

	printf(
	"}\n"
	);
}


#endif // !GENERATOR_H
