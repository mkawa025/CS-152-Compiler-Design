/* Majd Kawak */
/* Date 07/20/2022 */
/* Assignment: Project Phase 3 */
/* Class: CS152 */

%{
	#define YY_NO_UNPUT
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	#include<map>
	#include<set>
	int tempCount = 0;
	int labelCount = 0;
	extern char* yytext;
	extern int currPos;
	std::map<std::string, std::string> varTemp;
	std::map<std::string, int> arrSize;
	bool mainFunc = false;
	std::set<std::string> funcs;
	std::set<std::string> reserved {"FUNCTION", "BEGIN_PARAMS", "END_PARAMS", "BEGIN_LOCALS", "END_LOCALS", "BEGIN_BODY", "END_BODY", "INTEGER",
    "ARRAY", "ENUM", "OF", "IF", "THEN", "ENDIF", "ELSE", "WHILE", "DO", "BEGINLOOP", "ENDLOOP", "CONTINUE", "READ", "WRITE", "AND", "OR", 
    "NOT", "TRUE", "FALSE", "RETURN",  "L_PAREN", "R_PAREN", "L_SQUARE_BRACKET", "R_SQUARE_BRACKET", "SEMICOLON", "COLON", "COMMA", 
	"ASSIGN", "LT", "GT", "LTE", "GTE", "EQ", "NEQ", "ADD", "SUB", "MULT", "DIV", "MOD",
	"functions" "function" "declarations" "declaration" "identifiers" "ident" "statements" "statement" "bool_exp" "relation_and_exp" 
	"relation_exp" "comp" "expressions" "expression" "multiplicative_expression" "term" "vars" "var"};
	void yyerror(const char *msg);
	int yylex();
	std::string new_temp();
	std::string new_label();
%}

%union{
int num;
char* ident;
struct S {
	char* code;
}
statement;
struct E {
	char* place;
	char* code;
	bool arr;
}expression;
}

%start program_start
%type <expression> function FuncIdent declarations declaration identifiers ident statements statement bool_exp
relation_and_exp relation_exp comp expressions expression multiplicative_expression term vars var
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
%token <ident> IDENT
%token <num> NUMBER

%%
program_start:	  %empty
			{
				if (!mainFunc){
					printf ("No main function declared!\n");
				}
			}
			| function program_start	{

			}	
		;

function:	  FUNCTION FuncIdent SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY 
				{
					std::string temp = "func ";
					temp.append($2.place);
					temp.append(\"\n");
					std::string s =$2.place;
					if(s=="main"){
						mainFunc = true;
					}
					temp.append($5.code);
					std::string decs = $5.code;
					int decNum = 0;
					while (decs.find(".")!=std::string::npos){
						int pos = decs.find(".");
						decs.replace(pos, 1, "=");
						std::string part = ", $" + std::to_string(decNum) + "\n";
						decNum++;
						dec.replace(dec.find("\n", pos), 1, part);
					}
					remp.append(decs);
					temp.append($8.code);
					std::string statements = $11.code;
					if(statements.find("continue")!=std::string::npos){
						printf("ERROR: Continue outside loop in function %s\n", $2.place);
					}
					temp.append(statements);
					temp.append("endfunc\n\n");
					print(temp.c_str());
				}
		;     


declarations:	  /*empty*/ 
			{
				$$.place = strdup("");
				$$.code = strdup("");
			}
		| declaration SEMICOLON declarations 
			{
				std::string temp;
				temp.append($1.code);
				temp.append($3.code);
				$$.code = strdup(temp.c_str()); //Pass it on higher grammer to process
				$$.place = strdup(""); //Name of
			}
		;

declaration:	  
		identifiers COLON INTEGER 
		{
			int right = 0;
            int left = 0;
            std::string temp;
            std::string replace($1.place);
            bool ex = false;
            while(!ex) {
                right = replace.find(":", left);
                temp.append(". ");
                if (right == string::npos) {
                    std::string ident = replace.substr(left, right);
                    temp.append(ident);
                    ex = true;
                } else {
                    std::string ident = replace.substr(left, right-left);
                    temp.append(ident);
                    left = right + 1;
                }
                temp.append("\n");
            }
            $$.code = strdup(temp.c_str());
            $$.place = strdup("");
		}
		| identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER 
			{
				std::string temp;
				temp.append(".[] ");
				temp.append($1.place);
				temp.append(", ");
				temp.append($5.code);
				temp.append("\n");
				$$.code = strdup(temp.c_str());
				$$.place = strdup("");
			}
		;

FuncIdent: IDENT
			{
				if (funcs.find ($1) != funcs. end ()){
					printf("function name %s already declared. \n", $1);
				}
				else
				{
					funcs. insert($1);
				}
				$$.place = strdup($1);
				$$.code = strdup("");
			}
			;
identifiers:	  ident 
					{	
						$$.place = strdup($1.place);
						$$.code = strdup("");
					}
		| ident COMMA identifiers 
			{
				std::string temp;
				temp.append ($1.place);
				temp.append ("|");
				temp.append ($3.place);
				$$.place =strdup(temp.c_str());
				$$.code = strdup("");
			}
		;

ident:		  IDENT 
				{
					$$.place = strdup($1);
    				$$.code = strdup("");
				}
		;

statements:	  statement SEMICOLON
				{
					$$.code = strdup($1.code);
				}
		| statement SEMICOLON statements 
			{
				std::string temp;
				temp.append($1.code);
				temp.append($3.code);
				$$.code = strdup(temp.c_str());
			}
		;

statement:	  var ASSIGN expression 
				{ 
					std::string temp;
					temp.append($1.code);
					temp.append($3.code);

					if($1.arr){
						temp.append("[]= ");
					}else if($3.arr){
						temp.append("= ");
					}else{
						temp.append("= ");
					}
					temp.append($1.place);
					temp.append(", ");
					temp.append($3.place);
					temp.append("\n");
					$$.code = strdup(temp.c_str());
				}
		| IF bool_exp THEN statements ENDIF 
				{ 
					std::string dst = new_temp();
					std::string temp;
					temp.append($2.code); 
					temp.append("?:= ");
					temp.append(dst); 
					temp.append(", ");
					temp.append($2.place) 
					temp.append("\n");
					temp += ":= " + dst + "\n";
					temp += ": " << dst << "\n";
					temp.append($4.code);
					temp += ": " << dst << "\n";
					$$.code = strdup(temp.c_str());
				}
		| IF bool_exp THEN statements ELSE statements ENDIF 
			{ 
				std::string dst = new_temp();
				std::string temp;
				temp.append($2.code); 
				temp.append("?:= ");
				temp.append(dst); 
				temp.append(", ");
				temp.append($2.place) 
				temp.append("\n");
				temp += ":= " + dst + "\n";
				temp += ": " << dst << "\n";
				temp.append($4.code);
				temp += ": " << dst << "\n";
				$$.code = strdup(temp.c_str());
			}
		| WHILE bool_exp BEGINLOOP statements ENDLOOP 
			{ 
				
				std::string temp;
				std::string beginWhile = new_temp();
				std::string beginLoop = new_temp();
				std::string endLoop = new_temp();
				std::string statement = $4.code;
				std::string jump;
				jump.append(":= ");
				jump.append(beginWhile);
				while (statement.find("continue") != std::string::npos) {
					statement.replace(statement.find("continue"), 8, jump);
				}
				temp.append(": ");
				temp.append(beginWhile);
				temp.append("\n");
				temp.append($2.code);
				temp.append("?:= ");
				temp.append(beginLoop);
				temp.append(", ");
				temp.append($2.place);
				temp.append("\n");
				temp.append(":= ");
				temp.append(endLoop);
				temp.append("\n");
				temp.append(": ");
				temp.append(beginLoop);
				temp.append("\n");
				temp.append(statement);
				temp.append(":= ");
				temp.append(beginWhile);
				temp.append("\n");
				temp.append(": ");
				temp.append(endLoop);
				temp.append("\n");
				$$.code = strdup(temp.c_str());
			}
		| DO BEGINLOOP statements ENDLOOP WHILE bool_exp 
			{ 
				std::string temp;
				std::string beginLoop = newLabel();
				std::string beginWhile = newLabel();
				// replace continue
				std::string statement = $3.code;
				std::string jump;
				jump.append(":= ");
				jump.append(beginWhile);
				while (statement.find("continue") != std::string::npos) {
					statement.replace(statement.find("continue"), 8, jump);
				}
				temp.append(": ");
				temp.append(beginLoop);
				temp.append("\n");
				temp.append(statement);
				temp.append(": ");
				temp.append(beginWhile);
				temp.append("\n");
				temp.append($6.code);
				temp.append("?:= ");
				temp.append(beginLoop);
				temp.append(", ");
				temp.append($6.place);
				temp.append("\n");
				$$.code = strdup(temp.c_str());
			}
		| FOR vars ASSIGN NUMBER SEMICOLON bool_exp SEMICOLON vars ASSIGN expression BEGINLOOP statements ENDLOOP 
			{
				std::string temp;
				std::string count = newTemp();
				std::string check = newTemp();
				std::string begin = newLabel();
				std::string beginLoop = newLabel();
				std::string increment = newLabel();
				std::string endLoop = newLabel();
				std::string statement = $6.code;
				std::string jump;
				jump.append(":= ");
				jump.append(increment);
				while (statement.find("continue") != std::string::npos) {
					statement.replace(statement.find("continue"), 8, jump);
				}
				// Checks for second ident
				if (variables.find(std::string($4.place)) == variables.end()) {
					char temp[128];
					snprintf(temp, 128, "Use of undeclared variable %s", $4.place);
					yyerror(temp);
				}
				// Check if second ident is scalar
				else if (variables.find(std::string($4.place))->second == 0) {
					char temp[128];
					snprintf(temp, 128, "Use of scalar variable %s in foreach", $4.place);
					yyerror(temp);
				}
				// checks for LocalIdent happen in LocalIdent (redeclaration test)

				// Initalize first ident and check
				temp.append(". ");
				temp.append($2.place);
				temp.append("\n");
				temp.append(". ");
				temp.append(check);
				temp.append("\n");
				temp.append(". ");
				temp.append(count);
				temp.append("\n");
				temp.append("= ");
				temp.append(count);
				temp.append(", 0");
				temp.append("\n");
				// Check if count is less than size of array
				temp.append(": ");
				temp.append(begin);
				temp.append("\n");
				temp.append("< ");
				temp.append(check);
				temp.append(", ");
				temp.append(count);
				temp.append(", ");
				temp.append(std::to_string(variables.find(std::string($4.place))->second));
				temp.append("\n");
				// Jump to begin loop if check is true
				temp.append("?:= ");
				temp.append(beginLoop);
				temp.append(", ");
				temp.append(check);
				temp.append("\n");
				// Jump to end loop if check is false
				temp.append(":= ");
				temp.append(endLoop);
				temp.append("\n");
				// Begin loop
				temp.append(": ");
				temp.append(beginLoop);
				temp.append("\n");
				// Set first ident to value of second ident
				temp.append("=[] ");
				temp.append($2.place);
				temp.append(", ");
				temp.append($4.place);
				temp.append(", ");
				temp.append(count);
				temp.append("\n");
				// Execute code
				temp.append(statement);
				// Increment
				temp.append(": ");
				temp.append(increment);
				temp.append("\n");
				temp.append("+ ");
				temp.append(count);
				temp.append(", ");
				temp.append(count);
				temp.append(", 1\n");
				// Jump to check
				temp.append(":= ");
				temp.append(begin);
				temp.append("\n");
				// label endLoop
				temp.append(": ");
				temp.append(endLoop);
				temp.append("\n");
				
				$$.code = strdup(temp.c_str());
			}
		| READ vars 
			{ 
				std::string temp;
				temp.append($2.code);
				temp.append(".");
				size_t pos = temp.find("|", 0);
				while(pos != std::string::npos){
					temp.replace(pos, 1, "<");
					pos = temp.find("|", pos);
				}
				$$.code = strdup(temp.c_str());
			}
		| WRITE vars 
			{
				std::string temp;
				temp.append($2.code);
				temp.append(".");
				size_t pos = temp.find("|", 0);
				while(pos != std::string::npos){
					temp.replace(pos, 1, ">");
					pos = temp.find("|", pos);
				}
				$$.code = strdup(temp.c_str());
			}
		| CONTINUE 
			{ 
				$$.code = strup("continue\n");
			}
		| RETURN expression 
			{ 
				std::string temp;
				temp.append($2.code);
				temp.append("ret ");
				temp.append($2.place);
				temp.append("\n");
				$$.code = strdup(temp.c_str());
			}
		;

bool_exp:	  relation_and_exp 
				{
					$$.code = strdup($1.code);
					$$.place = strdup($1.place);
				}
		| relation_and_exp OR bool_exp 
			{
					std::string temp;
					std::string dst = new_temp();
					temp.append($1.code);
					temp.append($3.code);
					temp += ". " + dst + "\n";
					temp += "|| " + dst + ",";
					temp.append($1.place);
					temp.append(", ");
					temp.append($3.place);
					temp.append("\n");
					$$.code = strdup(temp.c_str());
					$$.place = strdup(dst.c_str());	
			}
		;

relation_and_exp:
		relation_exp 
			{
				$$.code = strdup($1.code);
				$$.place = strdup($1.place);
			} 
		| relation_exp AND relation_and_exp 
			{
				std::string dst = new_temp();
				std::string temp;
				temp.append($1.code);
				temp.append($3.code);
				temp += ". " + dst + "\n";
				temp += "&& " + dst + ",";
				temp.append($1.place);
				temp.append(", ");
				temp.append($3.place);
				temp.append("\n");
				$$.code = strdup(temp.c_str());
				$$.place = strdup(dst.c_str());
			}
		;

relation_exp:	  
		expression comp expression 
			{ 
				std::string dst = new_temp();
				std::string temp;
				temp.append($1.code);
				temp.append($3.code);
				temp += ". " + dst + "\n" + $2.place + dst + ", " + $1.place + ", " + $3.place + "\n";
				$$.code = strdup(temp.c_str());
				$$.place = strdup(dst.c_str());
			}
		| NOT expression comp expression 
			{ 
				std::string dst = new_temp();
				std::string temp;
				temp.append($2.code);
				temp += ". " + dst + "\n";
				temp += "! " + dst + "," 
				temp.append($2.place);
				temp.append("\n");
				$$.code = strdup(temp.c_str());
				$$.place = strdup(dst.c_str());
				
			}
		| TRUE 
			{ 
				std::string temp;
				temp.append("1");
				$$.code = strdup("");
				$$.place = strdup(temp.c_str());
			}
		| NOT TRUE 
			{ 
				std::string temp;
				temp.append("0");
				$$.code = strdup("");
				$$.place = strdup(temp.c_str());
			}
		| FALSE 
			{ 
				std::string temp;
				temp.append("0");
				$$.code = strdup("");
				$$.place = strdup(temp.c_str());
			}
		| NOT FALSE 
			{ 	
				std::string temp;
				temp.append("1");
				$$.code = strdup("");
				$$.place = strdup(temp.c_str());
			}
		| L_PAREN bool_exp R_PAREN 
			{ 
				$$.code = strdup($2.code);
				$$.place = strdup($2.place);
			}
		;

comp:	EQ 
		{
            $$.code = strdup("");
            $$.name = strdup("== ");
        }
        |NEQ {
            $$.code = strdup("");
            $$.name = strdup("!= ");
        }
        |LT {
            $$.code = strdup("");
            $$.name = strdup("< ");
        }
        |GT {
            $$.code = strdup("");
            $$.name = strdup("> ");
        }
        |LTE {
            $$.code = strdup("");
            $$.name = strdup("<= ");
        }
        |GTE {
            $$.code = strdup("");
            $$.name = strdup(">= ");
        }
		;

expressions:	  expression 
					{
						std::string temp;
						temp.append($1.code);
						temp.append("param ");
						temp.append($1.place);
						temp.append("\n");
						$$.code = strdup(temp.c_str());
						$$.place = strdup("");
					}	
					| expression COMMA expressions 
					{
						std::string temp;
						temp.append($1.code);
						temp.append("param ");
						temp.append($1.place);
						temp.append($3.code);
						$$.code = strdup(temp.c_str());
						$$.place = strdup("");
					}
		;

expression: 	  multiplicative_expression 
					{ 
						$$.code = strdup($1.code);
						$$.place = strdup($1.place);
					}
        	| multiplicative_expression ADD expression 
			{
				std::string temp;
				std::string dst = new_temp();
				temp.append($1.code);
				temp.append($3.code);
				temp += ". " + dst + "\n";
				temp += "+ " + dst + ", ";
				temp.append($1.code);
				temp += ", ";
				temp.append($3.place);
				temp += "\n";
				$$.code = strdup(temp.c_str());
				$$.place = strdup(dst.c_str());
			}
        	| multiplicative_expression SUB expression 
			{
				std::string temp;
				std::string dst = new_temp();
				temp.append($1.code);
				temp.append($3.code);
				temp += ". " + dst + "\n";
				temp += "- " + dst + ", ";
				temp.append($1.code);
				temp += ", ";
				temp.append($3.place);
				temp += "\n";
				$$.code = strdup(temp.c_str());
				$$.place = strdup(dst.c_str());}
		;

multiplicative_expression:
		term 
		{
			$$.code = strdup($1.code);
			$$.place = strdup($1.place); 
		}
		| term MULT multiplicative_expression 
			{
				std::string temp;
				std::string dst = new_temp();
				temp.append($1.code);
				temp.append($3.code);
				temp.append(". ");
				temp.append(dst);
				temp.append("\n");
				temp += "* " + dst + ", ";
				temp.append($1.place);
				temp += ", ";
				temp.append($3.place);
				temp += "\n";
				$$.code = strdup(temp.c_str());
				$$.place = strdup(dst.c_str());
			}
		| term DIV multiplicative_expression 
			{	std::string temp;
				std::string dst = new_temp();
				temp.append($1.code);
				temp.append($3.code);
				temp.append(". ");
				temp.append(dst);
				temp.append("\n");
				temp += "/ " + dst + ", ";
				temp.append($1.place);
				temp += ", ";
				temp.append($3.place);
				temp += "\n";
				$$.code = strdup(temp.c_str());
				$$.place = strdup(dst.c_str());
				}
		| term MOD multiplicative_expression 
				{
					std::string temp;
					std::string dst = new_temp();
					temp.append($1.code);
					temp.append($3.code);
					temp.append(". ");
					temp.append(dst);
					temp.append("\n");
					temp += "% " + dst + ", ";
					temp.append($1.place);
					temp += ", ";
					temp.append($3.place);
					temp += "\n";
					$$.code = strdup(temp.c_str());
					$$.place = strdup(dst.c_str());
				}
		;

term:	var 
			{ 	
				std::string dst = new_temp();
				std::string temp;
				temp.append($1.code);
				if($1.arr){
					temp.append($1.code);
					temp.append(". ");
					temp.append(dst);
					temp.append("\n");
					temp+= "=[] " + dst + ", ";
					temp.append($1.place);
					temp.append("\n");
				}
				else{
					temp.append(". ");
					temp.append(dst);
					temp.append("\n");
					temp+= "=[] " + dst + ", ";
					temp.append($1.place);
					temp.append("\n");
					temp.append($1.code);
				}
				if (varTemp.find(ident) != varTemp.end()){
					varTemp[$1.place] = dst;
				}
				$$.code = strdup(temp.c_str());
				$$.place = strdup(dst.c_str()); 
			}
		| SUB var 
			{ 
				std::string dst = new_temp();
				std::string temp;
				if($2.arr){
					temp.append($2.code);
					temp.append(". ");
					temp.append(dst);
					temp.append("\n");
					temp+= "=[] " + dst + ", ";
					temp.append($2.place);
					temp.append("\n");
				}
				else{
					temp.append(". ");
					temp.append(dst);
					temp.append("\n");
					temp+= "= " + dst + ", ";
					temp.append($2.place);
					temp.append("\n");
					temp.append($2.code);
				}
				if (varTemp.find($2.code) != varTemp.end()){
					varTemp[$2.place] = dst;
				}
				temp += "* " + dst + ", " + dst + ", -1\n";
				$$.code = strdup(temp.c_str());
				$$.place = strdup(dst.c_str());
			}
		| NUMBER {
				std::string dst = new_temp();
				std::string temp;
				temp.append(".");
				temp.append(dst);
				temp.append("\n");
				temp+= "= " + dst + ", " + std::to_string($1) + "\n";
				$$.code = strdup(temp.c_str());
				$$.place = strdup(dst.c_str());
				}
		| SUB NUMBER 
			{ 
				std::string dst = new_temp();
				std::string temp;
				temp.append(". ");
				temp.append(dst);
				temp.append("\n");
				temp += "= " + dst + ", -" + std::to_string($2) + "\n";
				$$.code = strdup(temp.c_str());
				$$.place = strdup(dst.c_str());
			}
		| L_PAREN expression R_PAREN 
			{ 
				$$.code = strdup($2.code);
				$$.place = strdup($2.place);
			}
		| SUB L_PAREN expression R_PAREN 
			{ 
				std::string temp;
				temp.append($3.code);
				temp.append("* ");
				temp.append($3.place);
				temp.append(", ");
				temp.append($3.place);
				temp.append(", -1\n");
				$$.code = strdup(temp.c_str());
				$$.place = strdup($3.place);
			}
		| ident L_PAREN expressions R_PAREN 
				{
					std::string temp;
					std::string func = $1.place;
					if(func.find(ident) == func.end()){
						printf("Calling undeclared function %s.\n"func.c_str());
					}
					std::string dst = new_temp();
					temp.append($3.code);
					temp+= ". " + dst + "\ncall ";
					temp.append($1.code);
					temp+= ", " + dst + "\n";
					$$.code = strdup(temp.c_str());
					$$.place = strdup(dst.c_str());
				}
				;

vars:	var
			{
				std::string dst = new_temp();
				std::string temp;
				temp.append($1.code);
				if($1.arr){
					temp.append($1.code);
					temp.append(". ");
					temp.append(dst);
					temp.append("\n");
					temp+= "=[] " + dst + ", ";
					temp.append($1.place);
					temp.append("\n");
				}
				else{
					temp.append(". ");
					temp.append(dst);
					temp.append("\n");
					temp+= "=[] " + dst + ", ";
					temp.append($1.place);
					temp.append("\n");
					temp.append($1.code);
				}
				if (varTemp.find(ident) != varTemp.end()){
					varTemp[$1.place] = dst;
				}
				$$.code = strdup(temp.c_str());
				$$.place = strdup(dst.c_str());
			}	
			| var COMMA vars
				{
					std::string temp;
    				temp.append($1.code);
					f($1.arr){
						temp.append(".[]}| ");
					}
					else{
						temp.append(".[]]| ");
					}
					std::string code;
					temp.append($1.code);
					temp.append("\n");
					temp.append($3.code);
					$$.code = strdup(temp.c_str());
					$$.place = strdup("");
				}
		;
	
var: ident 
   {
      std::string temp;
      std::string ident = $1.place;
      if(func.find(ident) == func.end() && varTemp.find(ident) == varTemp.end()){
         printf("Identifier %s not yet declared.\n",idnt.c_str());
      }
      else if (arrSize[ident] > 1) {
         printf("Index was not provided for array identifier %s.\n", idnt.c_str());
      }
	  $$.code = strdup("");
      $$.place = strdup(idnt.c_str());
      $$.arr = false;

   }
   | ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET 
   {
      std::string temp;
      std::string ident = $1.place;
      if(func.find(ident) == func.end() && varTemp.find(ident) == varTemp.end()){
         printf("Identifier %s not yet declared.\n",idnt.c_str());
      }
      else if (arrSize[ident] == 1) {
         printf("Index was provided for non-array identifier %s.\n", idnt.c_str());
      }
      temp.append($1.place);
      temp.append(", ");
      temp.append($3.place);
      $$.code = strdup($3.code);
      $$.place = strdup(temp.c_str());
      $$.arr = true;
   }
;
%%


int yyparse();
int main(int argc, char **argv) 
{
   if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         printf("syntax: %s filename\n", argv[0]);
      }
   }
   yyparse();
   return 0;
}

void yyerror(const char *msg) 
{
   extern int yylineno;
   extern char* yytext;
   printf("%s on line %d at char %d at symbol \"%s\"\n", s, yylineno, d, yytext);
   exit(1);

}

std::string new_temp(){
	std::string t = "t" + std::to_string(tempCount);
	tempCount++;
	return t;
}

std::string new_label(){
	std::string l = "l" + std::to_string(labelCount);
	labelCount++;
	return l;
}