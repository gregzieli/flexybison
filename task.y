%{
  #include <cstdio>
  #include <iostream>
  using namespace std;

  // stuff from flex that bison needs to know about:
  extern int yylex();
  extern int yyparse();
  extern FILE *yyin;
 
  void yyerror(const char *s);
%}

%union {
  int ival;
  char *sval;
}

// define the constant-string tokens:
%token ASSIGN SEMICOLON L_BRACKET R_BRACKET COMMA 
%token NOT AND OR PLUS MINUS MULTIPLY DIVIDE MODULO
%token FUNC_READINT FUNC_READSTR FUNC_LENGTH FUNC_POS FUNC_CONC FUNC_SUBSTR //FUNC_PRINT
//%token BEGIN END EXIT 
%token BOOL_TRUE BOOL_FALSE
//%token IF THEN ELSE TRUE FALSE
//%token WHILE DO

// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token <ival> NUM
%token <sval> IDENT
%token <sval> STRING
%token <sval> NUM_REL
%token <sval> STR_REL

%%
program:
    program instr
    | instr
    ;
instr:
    instr SEMICOLON simple_instr
    | simple_instr
    ;
simple_instr:
    simple_instr assign_stat
    | assign_stat
    ;
assign_stat:
    IDENT ASSIGN num_expr {
        cout << " assigned to int variable " << $1 << endl; free($1);
    }
    | IDENT ASSIGN str_expr { 
        cout << " assigned to string variable " << $1 << endl; free($1);
    }
    ;
num_op:
    PLUS | MINUS | MULTIPLY | DIVIDE | MODULO
    ;
bool_op:
    AND | OR
    ;
num_expr:
    NUM { cout << $1; }
    | IDENT
    | FUNC_READINT { cout << "user input"; }
    | num_expr num_op num_expr
    | L_BRACKET num_expr R_BRACKET
    | FUNC_LENGTH L_BRACKET str_expr R_BRACKET 
    | FUNC_POS L_BRACKET str_expr COMMA str_expr R_BRACKET
    ;
str_expr:
    STRING {cout << $1; free($1); }
    | IDENT
    | FUNC_READSTR
    | FUNC_CONC L_BRACKET str_expr COMMA str_expr R_BRACKET
    | FUNC_SUBSTR L_BRACKET str_expr COMMA num_expr COMMA num_expr R_BRACKET
    ;
bool_expr:
    BOOL_FALSE { cout << "false"; }
    | BOOL_TRUE { cout << "true"; }
    | L_BRACKET bool_expr R_BRACKET
    | NOT bool_expr
    | bool_expr bool_op bool_expr
    | num_expr NUM_REL num_expr
    | str_expr STR_REL str_expr
    ;
%%

int main(int, char**) {
  // open a file handle to a particular file:
  FILE *myfile = fopen("in.snazzle", "r");
  // make sure it is valid:
  if (!myfile) {
    cout << "I can't open a.snazzle.file!" << endl;
    return -1;
  }
  // Set flex to read from it instead of defaulting to STDIN:
  yyin = myfile;
  // Parse through the input:
  yyparse();
}

void yyerror(const char *s) {
  cout << "Parse error. Message: " << s << endl;
  // might as well halt now:
  exit(-1);
}