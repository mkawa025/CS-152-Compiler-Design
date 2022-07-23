/* Majd Kawak */
/* Date 07/11/2022 */
/* Assignment: Project Phase 2 */
/* Class: CS152 */

%{
 #include <stdio.h>
 #include <stdlib.h>
 void yyerror(const char *msg);
 extern int currLine;
 extern int currPos;
 extern int numNumbers;
 extern int numOperators;
 extern int numParens;
 extern int numEquals;
 FILE * yyin;
%}

%union{
int num_val;
char* id_val;
}
%error-verbose
%start program_start
%token FUNCTION BEGIN_PARAMS END_PARAMS
BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY
ENUM OF IF THEN ENDIF ELSE FOR WHILE DO BEGINLOOP ENDLOOP
CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN L_PAREN R_PAREN
L_SQUARE_BRACKET R_SQUARE_BRACKET SEMICOLON COLON COMMA ASSIGN
%left   AND 
%left   OR
%left   LT LTE GT GTE EQ NEQ
%left   ADD SUB
%left   MULT DIV MOD
%right ASSIGN
%right NOT
%token <id_val> IDENT
%token <num_val> NUMBER

%%
program_start:	  functions { printf("prog_start -> functions\n"); }
		;	
	
functions:	  /*empty*/{printf("functions -> epsilon\n");}
		| function functions {printf("functions -> function functions\n");}
		;

function:	  FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY {printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");}
		;     


declarations:	  /*empty*/ {printf("declarations -> epsilon\n");}
		| declaration SEMICOLON declarations {printf("declarations -> declaration SEMICOLON declarations\n");}
		;

declaration:	  identifiers COLON INTEGER {printf("declaration -> identifiers COLON INTEGER\n");}
		| identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");}
		;

identifiers:	  ident {printf("identifiers -> ident\n");}
		| ident COMMA identifiers {printf("identifiers -> IDENT COMMA identifiers\n");}
		;

ident:		  IDENT {printf("ident -> IDENT %s\n", $1);}
		;

statements:	  /*empty*/ {printf("statements -> epsilon\n");}
		| statement SEMICOLON statements {printf("statements -> statement SEMICOLON statements\n");}
		;

statement:	  var ASSIGN expression { printf("statement -> var ASSIGN expression\n"); }
		| IF bool_exp THEN statements ENDIF { printf("statement -> IF bool_exp THEN statements ENDIF\n"); }
		| IF bool_exp THEN statements ELSE statements ENDIF { printf("statement -> IF bool_exp THEN statements ELSE statements ENDIF\n"); }
		| WHILE bool_exp BEGINLOOP statements ENDLOOP { printf("statement -> WHILE bool_exp BEGINLOOP statements ENDLOOP\n"); }
		| DO BEGINLOOP statements ENDLOOP WHILE bool_exp { printf("statement -> DO BEGINLOOP statement_loop ENDLOOP WHILE bool_exp\n"); }
		| FOR vars ASSIGN NUMBER SEMICOLON bool_exp SEMICOLON vars ASSIGN expression BEGINLOOP statements ENDLOOP {printf("FOR vars ASSIGN NUMBER SEMICOLON bool_exp SEMICOLON vars ASSIGN expression BEGINLOOP statements ENDLOOP\n");}
		| READ vars { printf("statement -> READ vars\n"); }
		| WRITE vars { printf("statement -> WRITE vars\n"); }
		| CONTINUE { printf("statement -> CONTINUE\n"); }
		| RETURN expression { printf("statement -> RETURN expression\n"); }
		;

bool_exp:	  relation_and_exp {printf("bool_exp -> relation_and_exp\n");}
		| relation_and_exp OR bool_exp {printf("bool_exp -> relation_and_exp OR bool_exp\n");}
		;

relation_and_exp:relation_exp {printf("relation_and_exp -> relation_exp\n");} 
		| relation_exp AND relation_and_exp {printf("relation_and_exp -> relation_exp AND relation_and_exp\n");}
		;

relation_exp:	  expression comp expression { printf("relation_exp -> expression comp expression\n"); }
		| NOT expression comp expression { printf("relation_exp -> NOT expression comp expression\n"); }
		| TRUE { printf("relation_exp -> TRUE\n"); }
		| NOT TRUE { printf("relation_exp -> NOT TRUE\n"); }
		| FALSE { printf("relation_exp -> FALSE\n"); }
		| NOT FALSE { printf("relation_exp -> NOT FALSE\n"); }
		| L_PAREN bool_exp R_PAREN { printf("relation_exp -> L_PAREN bool_expr R_PAREN\n"); }
		;

comp:		  EQ {printf("comp -> EQ\n");}
		| NEQ {printf("comp -> NEQ\n");}
		| LT {printf("comp -> LT\n");}
		| GT {printf("comp -> GT\n");}
		| LTE {printf("comp -> LTE\n");}
		| GTE {printf("comp -> GTE\n");}
		;

expressions:	  expression {printf("expressions -> expression\n");}	
		| expression COMMA expressions {printf("expressions -> expression COMMA expressions\n");}
		;

expression: 	  multiplicative_expression { printf("expression -> multiplicative_expression\n"); }
        	| multiplicative_expression ADD expression { printf("expression -> multiplicative_expression ADD expression\n"); }
        	| multiplicative_expression SUB expression { printf("expression -> multiplicative_expression SUB expression\n"); }
		;

multiplicative_expression:term {printf("multiplicative_expression -> term\n");}
		| term MULT multiplicative_expression {printf("multiplicative_expression -> term MULT multiplicative_expression\n");}
		| term DIV multiplicative_expression {printf("multiplicative_expression -> term DIV multiplicative_expression\n");}
		| term MOD multiplicative_expression {printf("multiplicative_expression -> term MOD multiplicative_expression\n");}
		;

term:		  var { printf("term -> var\n"); }
		| SUB var { printf("term -> SUB var\n"); }
		| NUMBER { printf("term -> NUMBER\n"); }
		| SUB NUMBER { printf("term -> SUB NUMBER\n"); }
		| L_PAREN expression R_PAREN { printf("term -> L_PAREN expression R_PAREN\n"); }
		| SUB L_PAREN expression R_PAREN { printf("term -> SUB L_PAREN expression R_PAREN\n"); }
		| ident L_PAREN R_PAREN { printf("term -> ident L_PAREN R_PAREN\n"); }
		| ident L_PAREN expressions R_PAREN { printf("term -> ident L_PAREN expressions R_PAREN\n"); }
		;

vars:		  var {printf("vars -> var\n");}
		| var COMMA vars {printf("vars -> var COMMA vars\n");}
		;
	
var:              ident {printf("var -> ident\n");}
                | ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("var -> ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");} 
                ;
%%

int main(int argc, char **argv) {
   if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         printf("syntax: %s filename\n", argv[0]);
      }
   }
   yyparse();
   return 0;
}

void yyerror(const char *msg) {
   printf("Error: Line %d, position %d: %s\n", currLine, currPos, msg);
}