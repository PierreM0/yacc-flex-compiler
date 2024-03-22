#ifndef TREE_C
#define TREE_C
#include <stdlib.h>

typedef enum {
// base types
	NODETYPE_BINOP,
	NODETYPE_UNARY,
	NODETYPE_IMM,
	NODETYPE_STMT,
	NODETYPE_FUNCALL,
	NODETYPE_VAR,
	NODETYPE_WHILE,
	NODETYPE_ASSIGN,
} NodeType;

typedef enum {
	NODETYPE_EQUAL,
	NODETYPE_ADD,
} BinOpNodeType;

typedef enum {
	NODETYPE_IMM_INT,
} ImmNodeType;

typedef enum {
	NODETYPE_NOT,
} UnaryNodeType;


struct node;

typedef union {
	struct {
		struct node *left;		
		struct node *right;		
		BinOpNodeType type;
	} binary_op;
	struct {
		char *name;
		struct node *arg;
	} funcall; /* arité = 1 */
	struct {
		struct node *condition;
		struct node *body;
	} while_;
	struct {
		struct node* stmt1;
		struct node* stmt2;
	} statement;
	struct {
		char* name;
		struct node* expr;
	} assign;
	struct {
		struct node* child;
		UnaryNodeType type;
	} unary;
	struct {
		void* value;
		ImmNodeType type;
	} imm; 
	struct {
		char* name;
	} var;
} AssociatedData;

typedef struct node {
	NodeType type;
	AssociatedData data;
} Node;

/// n1 must be executed before n2
Node* new_statement(Node *n1, Node* n2) {
	Node* n = (Node*) malloc(sizeof(Node));
	n->type = NODETYPE_STMT;
	n->data.statement.stmt1 = n1;
	n->data.statement.stmt2 = n2;
	return n;
}

Node* new_while(Node* condition, Node* body) {
	Node* n = (Node*) malloc(sizeof(Node));
	n->type = NODETYPE_WHILE;
	n->data.while_.condition = condition;
	n->data.while_.body = body;
	return n; 
}

Node* new_assign(char* name, Node* expr) { 
	Node* n = (Node*) malloc(sizeof(Node));
	n->type = NODETYPE_ASSIGN;
	n->data.assign.name = name;
	n->data.assign.expr = expr;
	return n; 
}

// TODO:
Node* new_declaration(char* name, Node* type, Node* expr) { 
	return new_assign(name, type);
}

Node* new_funcall(char* name, Node* arg) { 
	Node* n = (Node*) malloc(sizeof(Node));
	n->type = NODETYPE_FUNCALL;
	n->data.funcall.name = name;
	n->data.funcall.arg = arg;
	return n; 
}

Node* new_unaryop(UnaryNodeType type, Node* child) { 
	Node* n = (Node*) malloc(sizeof(Node));
	n->type = NODETYPE_UNARY;
	n->data.unary.type = type;
	n->data.unary.child = child;
	return n; 
}

Node* new_binop(Node* left, BinOpNodeType type, Node* right) {
	Node* n = (Node*) malloc(sizeof(Node));
	n->type = NODETYPE_BINOP;
	n->data.binary_op.type = type;
	n->data.binary_op.left = left;
	n->data.binary_op.right = right;
	return n; 
}

Node* new_var(char* name) {
	Node* n = (Node*) malloc(sizeof(Node));
	n->type = NODETYPE_VAR;
	n->data.var.name = name;
	return n;
}

Node* new_imm(void* data, ImmNodeType type) {
	Node* n = (Node*) malloc(sizeof(Node));
	n->type = NODETYPE_IMM;
	n->data.imm.type = type;
	n->data.imm.value = data;
	return n;
}



#endif /* ifndef TREE_C */
