/* Majd Kawak */
/* Date 07/11/2022 */
/* Assignment: Project Phase 2 */
/* Class: CS152 */

%{
	#include "y.tab.h"
	int currLine = 1;
	int currPos = 1;
%}

DIGITS [0-9]
IDENT [a-zA-Z]([a-zA-Z0-9_]*[a-zA-Z0-9])?

%%

"(" 	{currPos += yyleng; return L_PAREN;}
")" 	{currPos += yyleng; return R_PAREN;}
"[" 	{currPos += yyleng; return L_SQUARE_BRACKET;}
"]" 	{currPos += yyleng; return R_SQUARE_BRACKET;}
"*" 	{currPos += yyleng; return MULT;}
"/" 	{currPos += yyleng; return DIV;}
"%" 	{currPos += yyleng; return MOD;}
"+" 	{currPos += yyleng; return ADD;}
"-" 	{currPos += yyleng; return SUB;}
"<" 	{currPos += yyleng; return LT;}
"<=" 	{currPos += yyleng; return LTE;}
">" 	{currPos += yyleng; return GT;}
">=" 	{currPos += yyleng; return GTE;}
"==" 	{currPos += yyleng; return EQ;}
"<>" 	{currPos += yyleng; return NEQ;}
";" 	{currPos += yyleng; return SEMICOLON;}
":" 	{currPos += yyleng; return COLON;}
"," 	{currPos += yyleng; return COMMA;}
":=" 	{currPos += yyleng; return ASSIGN;}

"function"			{currPos += yyleng; return FUNCTION;}
"beginparams"		{currPos += yyleng; return BEGIN_PARAMS;}
"endparams" 		{currPos += yyleng; return END_PARAMS;}
"beginlocals" 		{currPos += yyleng; return BEGIN_LOCALS;}
"endlocals" 		{currPos += yyleng; return END_LOCALS;}
"beginbody" 		{currPos += yyleng; return BEGIN_BODY;}
"endbody" 			{currPos += yyleng; return END_BODY;}
"integer" 			{currPos += yyleng; return INTEGER;}
"array" 			{currPos += yyleng; return ARRAY;}
"enum"          	{currPos += yyleng; return ENUM;}
"of" 				{currPos += yyleng; return OF;}
"if" 				{currPos += yyleng; return IF;}
"then" 				{currPos += yyleng; return THEN;}
"endif"				{currPos += yyleng; return ENDIF;}
"else"				{currPos += yyleng; return ELSE;}
"for"				{currPos += yyleng; return FOR;}
"while"				{currPos += yyleng; return WHILE;}
"do"				{currPos += yyleng; return DO;}
"beginloop"			{currPos += yyleng; return BEGINLOOP;}
"endloop"			{currPos += yyleng; return ENDLOOP;}
"continue"			{currPos += yyleng; return CONTINUE;}
"read"				{currPos += yyleng; return READ;}
"write"				{currPos += yyleng; return WRITE;}
"and"				{currPos += yyleng; return AND;}
"or"				{currPos += yyleng; return OR;}
"not"				{currPos += yyleng; return NOT;}
"true"				{currPos += yyleng; return TRUE;}
"false"				{currPos += yyleng; return FALSE;}
"return"			{currPos += yyleng; return RETURN;}

{IDENT}	{yylval.id_val = strdup(yytext); currPos += yyleng; return IDENT;}

{DIGITS}{DIGITS}*	{yylval.num_val = atoi(yytext); currPos += yyleng; return NUMBER;}
(\.{DIGITS}+)|({DIGITS}+(\.{DIGITS}*)?([eE][+-}?[0-9]+)?) {yylval.num_val = atoi(yytext); currPos += yyleng; return NUMBER;}

[0-9_]{IDENT} {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", currPos, currLine, yytext); exit(0);}
{IDENT}[_] {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", currPos, currLine, yytext); exit(0);}



##.*		{/* Ignores Comments */ currLine++; currPos = 1;}
[" "]		{/* Ignores White Spaces */ currPos += yyleng;}
[ \t]		{/* Ignores Tabs */ currPos += yyleng;}
[\n]		{/* Ignores New Lines */currLine++; currPos = 1;}

. {printf("Error at line %d. column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}

%%