%{
    #include <cstdio>
    #include <iostream>
    using namespace std;

    // stuff from flex that bison needs to know about:
    extern int yylex();
    extern int yyparse();
    extern FILE *yyin;
    extern int line_num;
    void yyerror(const char *s);
%}

%union {
    int number;
    char* text;
}

%token ASSIGN SEMICOLON L_BRACKET R_BRACKET COMMA 
%token NOT AND OR PLUS MINUS MULTIPLY DIVIDE MODULO
%token FUNC_READINT FUNC_READSTR FUNC_LENGTH FUNC_POS FUNC_CONC FUNC_SUBSTR FUNC_PRINT
%token FUNC_EXIT BEGIN_CLAUSE END_CLAUSE
%token BOOL_TRUE BOOL_FALSE
%token IF THEN ELSE
%token WHILE DO

%token <number> NUM
%token <text> IDENT
%token <text> STRING
%token <text> NUM_REL
%token <text> STR_REL

%%
program:
    program instr 
    | instr
    ;
instr:
    instr SEMICOLON simple_instr
    | simple_instr
    ;
assign_stat:
    IDENT ASSIGN num_expr
    | IDENT ASSIGN str_expr
    ;
if_stat:
    IF bool_expr THEN simple_instr
    | IF bool_expr THEN simple_instr ELSE simple_instr
    ;
while_stat:
    WHILE bool_expr DO simple_instr
    | DO simple_instr WHILE bool_expr
    ;
output_stat:
    FUNC_PRINT L_BRACKET num_expr R_BRACKET
    | FUNC_PRINT L_BRACKET str_expr R_BRACKET
    ;
simple_instr:
    assign_stat
    | if_stat
    | while_stat
    | BEGIN_CLAUSE instr END_CLAUSE
    | output_stat
    | FUNC_EXIT
    ;
num_op:
    PLUS | MINUS | MULTIPLY | DIVIDE | MODULO
    ;
bool_op:
    AND | OR
    ;
num_expr:
    NUM
    | IDENT
    | FUNC_READINT
    | num_expr num_op num_expr
    | L_BRACKET num_expr R_BRACKET
    | FUNC_LENGTH L_BRACKET str_expr R_BRACKET 
    | FUNC_POS L_BRACKET str_expr COMMA str_expr R_BRACKET
    ;
str_expr:
    STRING
    | IDENT
    | FUNC_READSTR
    | FUNC_CONC L_BRACKET str_expr COMMA str_expr R_BRACKET
    | FUNC_SUBSTR L_BRACKET str_expr COMMA num_expr COMMA num_expr R_BRACKET
    ;
bool_expr:
    BOOL_FALSE
    | BOOL_TRUE
    | L_BRACKET bool_expr R_BRACKET
    | NOT bool_expr
    | bool_expr bool_op bool_expr 
    | num_expr NUM_REL num_expr
    | str_expr STR_REL str_expr
    ;
%%

int main(int, char**) {
  // open a file handle to a particular file:
  FILE *myfile = fopen("code", "r");
  // make sure it is valid:
  if (!myfile) {
    cout << "Can't open file!" << endl;
    return -1;
  }
  yyin = myfile;
  cout << "Parsing line 1" << endl;
  yyparse();
  cout << "Validation succeeded." << endl;
}

void yyerror(const char *s) {
  cout << "Validation failed on line " << line_num << ". " << s << endl;
  exit(-1);
}