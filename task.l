%{
  #include <cstdio>
  #include <iostream>
  #include "task.tab.h"
  using namespace std;
  int line_num = 1;
%}
%option noyywrap
%%
[ \t]                         ;
:=                            return ASSIGN;
;                             return SEMICOLON;
"("                           return L_BRACKET;
")"                           return R_BRACKET;
","                           return COMMA;
"+"                           return PLUS;
"-"                           return MINUS;
"*"                           return MULTIPLY;
"/"                           return DIVIDE;
"%"                           return MODULO;
not                           return NOT;
and                           return AND;
or                            return OR;
true                          return BOOL_TRUE;
false                         return BOOL_FALSE;
readint                       return FUNC_READINT;
readstr                       return FUNC_READSTR;
length                        return FUNC_LENGTH;
position                      return FUNC_POS;
concatenate                   return FUNC_CONC;
substring                     return FUNC_SUBSTR;
if                            return IF;
then                          return THEN;
else                          return ELSE;
while                         return WHILE;
do                            return DO;
exit                          return FUNC_EXIT;
-?[0-9]+                      { yylval.ival = atoi(yytext); return NUM; }
\"[a-zA-Z0-9 ,\.]+\"          { yylval.sval = strdup(yytext); return STRING; }
[a-zA-Z][a-zA-Z0-9_]*         { yylval.sval = strdup(yytext); return IDENT; }
(=|<|<=|>|>=|<>)?             { yylval.sval = strdup(yytext); return NUM_REL; }
(==|!=)?                      { yylval.sval = strdup(yytext); return STR_REL; }
\n                            { ++line_num; cout << "Parsing line " << line_num << endl; }
%%