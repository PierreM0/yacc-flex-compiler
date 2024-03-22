#ifndef GENERATOR_H
#define GENERATOR_H

#include <stdio.h>
#include "tree.h"

int stack_size = 0;
int loop_num = 0;

void generate_node_code(Node* node);

void generate_binop_code(Node* node) {
  generate_node_code(node->data.binary_op.left);
  generate_node_code(node->data.binary_op.right);

  switch (node->data.binary_op.type) {
  case NODETYPE_EQUAL:
    printf("%%r%d =w eq %%r%d, %%r%d\n",
	   stack_size-1, stack_size, stack_size-1);
    stack_size -= 1;
    break;
  case NODETYPE_ADD:
    printf("%%r%d =w add %%r%d, %%r%d\n",
	   stack_size-1, stack_size, stack_size-1);
    stack_size -= 1;
    break;
  }
}

void generate_unary_code(Node* node) {
  generate_node_code(node->data.unary.child);
  switch (node->data.unary.type) {
  case NODETYPE_NOT:
    printf("%%r%d =w neg %%r%d\n", stack_size, stack_size);
    break;
  }
}

void generate_imm_code(Node* node) {
  switch (node->data.imm.type) {
  case NODETYPE_IMM_INT:
    printf("%%r%d =w add 0, %ld\n", stack_size+1, (long)node->data.imm.value);
    stack_size += 1;
    break;
  }
}

void generate_stmt_code(Node* node) {
  generate_node_code(node->data.statement.stmt1);
  generate_node_code(node->data.statement.stmt2);
}

void generate_funcall_code(Node* node) {
  generate_node_code(node->data.funcall.arg);
  printf("%%r%d =w call $%s(w %%r%d)\n", 
	 stack_size,
         node->data.funcall.name,
	 stack_size
	 );
}

void generate_var_code(Node* node) {
  printf("%%r%d =w call %%%s)\n",
	 stack_size + 1, node->data.var.name);
}

void generate_while_code(Node* node) {
  loop_num += 1;
  printf("@loop%d\n", loop_num);

  generate_node_code(node->data.while_.condition);

  printf("jnz %%r%d, @loopstart%d, @end%d\n", stack_size, loop_num, loop_num);
  stack_size -= 1;
  printf("@loopstart%d\n", loop_num);

  generate_node_code(node->data.while_.body);

  printf("@end%d\n", loop_num);
}

void generate_assign_code(Node* node) {
  generate_node_code(node->data.assign.expr);
  printf("%%%s =w %%r%d\n", node->data.assign.name, stack_size);
}

void generate_node_code(Node* node) {
  switch (node->type) {
  case NODETYPE_BINOP:
    generate_binop_code(node);
    break;
  case NODETYPE_UNARY:
    generate_unary_code(node);
    break;
  case NODETYPE_IMM:
    generate_imm_code(node);
    break;
  case NODETYPE_STMT:
    generate_stmt_code(node);
    break;
  case NODETYPE_FUNCALL:
    generate_funcall_code(node);
    break;
  case NODETYPE_VAR:
    generate_var_code(node);
    break;
  case NODETYPE_WHILE:
    generate_while_code(node);
    break;
  case NODETYPE_ASSIGN:
    generate_assign_code(node);
    break;
  }
}

void generate_code(Node* start) {
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
