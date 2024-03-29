%{
    #include <cstdio>
    #include <iostream>
    #include <string>
    #include <cstring>
    #include <iterator> 
    #include <map>
    
    using namespace std;

    // stuff from flex that bison needs to know about:
    extern int yylex();
    extern int yyparse();
    extern FILE *yyin;
    extern int line_num;
    void yyerror(const char *s);

    map<string, int> numVariables;
    map<string, string> stringVariables;
    map<string, string> varTypes;
    void assignType(string name, string type);
    void verifyType(string name, string type);
    void assignInt(string name, int value);
    void assignString(string name, string value);
    int getInt(string name);
    char* getString(string name);
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
    IDENT ASSIGN num_expr                                                       { assignType($1, "int"); assignInt($1, $3); }
    | IDENT ASSIGN str_expr                                                     { assignType($1, "string"); assignString($1, $3); }
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
    | FUNC_EXIT                                                                 { cout << "Exiting..." << endl; exit(-1); }
    ;
num_expr:
    NUM                                                                         { $$ = $1; }
    | IDENT                                                                     { $$ = getInt($1); verifyType($1, "int"); }
    | FUNC_READINT                                                              { cin >> $$;  }
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
    | IDENT                                                                     { $$ = getString($1); verifyType($1, "string"); }
    | FUNC_READSTR                                                              { cin >> $$; }
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
  cout << "1: ";
  yyparse();
  cout << "Validation succeeded." << endl;
}

void yyerror(const char *s) {
  cerr << "Validation failed on line " << line_num << "." << endl;
  exit(-1);
}

void assignInt(string name, int value) {
    numVariables.insert(pair<string, int>(name, value) ); 
    cout << "Assigned " << value << " to " << name << endl;
}

void assignString(string name, string value) {
    stringVariables.insert(pair<string, string>(name, value) ); 
    cout << "Assigned " << value << " to " << name << endl;
}

int getInt(string name) {
    if (numVariables.count(name) == 0) {
        numVariables.insert(pair<string, int>(name, 0) );
    }
    int value = numVariables.find(name)->second; 
    cout << "GetInt: Extracted " << value << " from " << name << endl;
    return value;
}

char* getString(string name) {
    if (stringVariables.count(name) == 0) {
        stringVariables.insert(pair<string, string>(name, "") );
    }
    string str = stringVariables.find(name)->second; 
    char * writable = new char[str.size() + 1];
    copy(str.begin(), str.end(), writable);
    writable[str.size()] = '\0';
    cout << "GetString: Extracted " << writable << " from " << name << endl;

    return writable;
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

void assignType(string name, string type) {
    varTypes.insert(pair<string, string>(name, type) ); 
    cout << "Assigned type " << type << " to " << name << endl;
}

void verifyType(string name, string type) {
    if (varTypes.count(name) == 0) {
        varTypes.insert(pair<string, string>(name, type) );
    }
    string value = varTypes.find(name)->second; 
    if (value != type) {
        cout << "Type mismatch for " << name << ". Declared as " << value << " now used as " << type  << endl;
    }
}