%{
    #include <cstdio>
    #include <iostream>
    #include <string>
    #include <cstring>
    #include <map>
    
    using namespace std;

    // stuff from flex that bison needs to know about:
    extern int yylex();
    extern int yyparse();
    extern FILE *yyin;
    extern int line_num;
    void yyerror(const char *s);



    map<char*, int> numVariables;
    map<char*, char*> stringVariables;
    void assignString(char* name, char* value);
    void assignInt(char* name, int value);
    int getInt(char* name);
    char* getString(char* name);

    int getLength(string name);
    char* concat(string v1, string v2);
%}

%union {
    int number;
    char* text;
    bool boolean;
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

%type<number> num_expr
%type<text> str_expr
%type<boolean> bool_expr

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
    IDENT ASSIGN num_expr { assignInt($1, $3); }
    | IDENT ASSIGN str_expr { assignString($1, $3); }
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
    FUNC_PRINT L_BRACKET num_expr R_BRACKET                                     { cout << "print " << $3 << endl; }
    | FUNC_PRINT L_BRACKET str_expr R_BRACKET                                   { cout << "print " << $3 << endl; }
    ;
simple_instr:
    assign_stat
    | if_stat
    | while_stat
    | BEGIN_CLAUSE instr END_CLAUSE
    | output_stat
    | FUNC_EXIT
    ;
num_expr:
    NUM                                                                         { $$ = $1; }
    | IDENT
    | FUNC_READINT
    | num_expr PLUS num_expr                                                    { $$ = $1 + $3; }
    | num_expr MINUS num_expr                                                   { $$ = $1 - $3; }
    | num_expr MULTIPLY num_expr                                                { $$ = $1 * $3; }
    | num_expr DIVIDE num_expr                                                  { $$ = $1 / $3; }
    | num_expr MODULO num_expr                                                  { $$ = $1 % $3; }
    | L_BRACKET num_expr R_BRACKET                                              { $$ = $2; }
    | FUNC_LENGTH L_BRACKET str_expr R_BRACKET                                  { $$ = getLength($3); }
    | FUNC_POS L_BRACKET str_expr COMMA str_expr R_BRACKET  
    ;
str_expr:
    STRING                                                                      { $$ = $1; }
    | IDENT 
    | FUNC_READSTR
    | FUNC_CONC L_BRACKET str_expr COMMA str_expr R_BRACKET                     { $$ = concat($3, $5); }
    | FUNC_SUBSTR L_BRACKET str_expr COMMA num_expr COMMA num_expr R_BRACKET
    ;
bool_expr:
    BOOL_FALSE                                                                  { $$ = false; }
    | BOOL_TRUE                                                                 { $$ = true; }
    | L_BRACKET bool_expr R_BRACKET                                             { $$ = $2; }
    | NOT bool_expr                                                             { $$ = !$2; }
    | bool_expr AND bool_expr                                                   { $$ = $1 && $3; }
    | bool_expr OR bool_expr                                                    { $$ = $1 || $3; }
    | num_expr NUM_REL num_expr
    | str_expr STR_REL str_expr
    ;
%%

int main(int argc, char** argv) {
  // open a file handle to a particular file:
  FILE *myfile = fopen(argv[1], "r");
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
  cerr << "Validation failed on line " << line_num << "." << endl;
  exit(-1);
}

void assignString(char* name, char* value) {
    stringVariables.insert(pair<char*, char*>(name, value) ); 
    cout << "Assigned " << value << " to " << name << endl;
}

void assignInt(char* name, int value) {
    numVariables.insert(pair<char*, int>(name, value) ); 
    cout << "Assigned " << value << " to " << name << endl;
}

int getInt(char* name) {
    int value = numVariables.find(name)->second; 
    cout << "Extracted " << value << " from " << name << endl;
}

char* getString(char* name) {
    char* value = stringVariables.find(name)->second; 
    cout << "Extracted " << value << " from " << name << endl;
}

int getLength(string input) {
    int value = input.length() - 2; // the quotes
    cout << "Length of " << input << " = " << value << endl;
    return value;
}

char* concat(string v1, string v2) {
    string str = v1 + v2;
    char * writable = new char[str.size() + 1];
    copy(str.begin(), str.end(), writable);
    writable[str.size()] = '\0';

    cout << "Concat " << v1 << v2 << " = " << writable << endl;
    return writable;
}