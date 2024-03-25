#ifndef GENERATOR_H
#define GENERATOR_H

#include <stdio.h>
#include "tree.h"

int stack_size = 0;
int loop_num = 0;

void generate_node_code(FILE* outfile, Node* node);

void generate_binop_code(FILE* outfile, Node* node) {
  generate_node_code(outfile, node->data.binary_op.left);
  generate_node_code(outfile, node->data.binary_op.right);

  switch (node->data.binary_op.type) {
  case NODETYPE_EQUAL:
    fprintf(outfile, "%%r%d =w ceqw %%r%d, %%r%d\n",
	   stack_size-1, stack_size, stack_size-1);
    stack_size -= 1;
    break;
  case NODETYPE_ADD:
    fprintf(outfile, "%%r%d =w add %%r%d, %%r%d\n",
	   stack_size-1, stack_size, stack_size-1);
    stack_size -= 1;
    break;
  }
}

void generate_unary_code(FILE* outfile, Node* node) {
  generate_node_code(outfile, node->data.unary.child);
  switch (node->data.unary.type) {
  case NODETYPE_NOT:
    fprintf(outfile, "%%r%d =w neg %%r%d\n", stack_size, stack_size);
    break;
  }
}

void generate_imm_code(FILE* outfile, Node* node) {
  switch (node->data.imm.type) {
  case NODETYPE_IMM_INT:
    fprintf(outfile, "%%r%d =w add 0, %ld\n", stack_size+1, (long)node->data.imm.value);
    stack_size += 1;
    break;
  }
}

void generate_stmt_code(FILE* outfile, Node* node) {
  generate_node_code(outfile, node->data.statement.stmt1);
  generate_node_code(outfile, node->data.statement.stmt2);
}

int generate_funcall_in_paren_code(FILE* outfile, Node* node) {
    int linked_list_size = 0;
    Node *p_node = node;
    while (p_node != NULL) {
        generate_node_code(outfile, p_node->data.funcall_in_paren.expr);
        p_node = p_node->data.funcall_in_paren.maybe_expr;
        linked_list_size += 1;
    }
    return linked_list_size -1;
}

void generate_funcall_code(FILE* outfile, Node* node) {
    int linked_list_size = generate_funcall_in_paren_code(outfile, node->data.funcall.arg);

    fprintf(outfile, "%%r%d =w call $%s(",
            stack_size-linked_list_size,
            node->data.funcall.name
    );
    for (int i = linked_list_size; i > 0; --i) {
        fprintf(outfile, "w %%r%d,", stack_size -i);
    }
    fprintf(outfile, "w %%r%d)\n", stack_size);

    stack_size -= linked_list_size;

}

void generate_var_code(FILE* outfile, Node* node) {

  fprintf(outfile, "%%r%d =w add 0, %%%s\n",
	 stack_size + 1, node->data.var.name);
  stack_size += 1;
}

void generate_while_code(FILE* outfile, Node* node) {
  loop_num += 1;
  fprintf(outfile, "@loop%d\n", loop_num);

  generate_node_code(outfile, node->data.while_.condition);

  fprintf(outfile, "jnz %%r%d, @end%d, @loopstart%d\n", stack_size, loop_num, loop_num);
  stack_size -= 1;
  fprintf(outfile, "@loopstart%d\n", loop_num);

  generate_node_code(outfile, node->data.while_.body);

  fprintf(outfile, "jmp @loop%d\n", loop_num);
  fprintf(outfile, "@end%d\n", loop_num);
}

void generate_if_code(FILE* outfile, Node* node) {
    loop_num += 1;
    fprintf(outfile, "@if%d\n", loop_num);

    generate_node_code(outfile, node->data.if_.condition);

    fprintf(outfile, "jnz %%r%d, @ifstart%d, @end%d\n", stack_size, loop_num, loop_num);
    stack_size -= 1;
    fprintf(outfile, "@ifstart%d\n", loop_num);
    generate_node_code(outfile, node->data.if_.body);
    fprintf(outfile, "@end%d\n", loop_num);
}

void generate_if_else_code(FILE* outfile, Node* node) {
    loop_num += 1;
    fprintf(outfile, "@if%d\n", loop_num);

    generate_node_code(outfile, node->data.if_else.condition);

    fprintf(outfile, "jnz %%r%d, @ifstart%d, @else%d\n", stack_size, loop_num, loop_num);
    stack_size -= 1;
    fprintf(outfile, "@ifstart%d\n", loop_num);
    generate_node_code(outfile, node->data.if_else.body_true);
    fprintf(outfile, "@else%d\n", loop_num);
    generate_node_code(outfile, node->data.if_else.body_else);
}

void generate_assign_code(FILE* outfile, Node* node) {
  generate_node_code(outfile, node->data.assign.expr);
  fprintf(outfile, "%%%s =w add 0, %%r%d\n", node->data.assign.name, stack_size);
  stack_size -= 1;
}

void generate_node_code(FILE* outfile, Node* node) {
  switch (node->type) {
  case NODETYPE_BINOP:
    generate_binop_code(outfile, node);
    break;
  case NODETYPE_UNARY:
    generate_unary_code(outfile, node);
    break;
  case NODETYPE_IMM:
    generate_imm_code(outfile,node);
    break;
  case NODETYPE_STMT:
    generate_stmt_code(outfile, node);
    break;
  case NODETYPE_FUNCALL:
    generate_funcall_code(outfile, node);
    break;
  case NODETYPE_FUNCALL_IN_PAREN:
    generate_funcall_in_paren_code(outfile, node);
    break;
  case NODETYPE_VAR:
    generate_var_code(outfile, node);
    break;
  case NODETYPE_WHILE:
    generate_while_code(outfile, node);
    break;
  case NODETYPE_IF:
    generate_if_code(outfile, node);
    break;
  case NODETYPE_IF_ELSE:
    generate_if_else_code(outfile, node);
    break;
  case NODETYPE_ASSIGN:
    generate_assign_code(outfile, node);
    break;
  }
}

void generate_code(FILE* outfile, Node* start) {
	fprintf(outfile,
	"export function w $main() {\n"
	"@start\n"
	);
	
	generate_node_code(outfile, start);

	fprintf(outfile,
    "ret\n"
	"}\n"
	);
}


#endif // !GENERATOR_H
