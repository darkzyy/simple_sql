%{
#include<cstdio>
#include<cassert>
#include"lex.yy.c"
#include<unordered_map>
#include<string>
#include<iostream>
#include<list>
#include<algorithm>

using namespace std;

extern int yyerror(char * msg);
extern void add_table(string *s);
extern void add_table2(string *s);
extern void check_table_sel();
extern void check_func(string *s);

unordered_map<string, int> selected_table;
unordered_map<string, int> from_table;

bool in_sel = false;
bool in_from = false;
bool in_where = false;
bool error_exists = false;

%}

%locations

%union {
struct {
    int error_exists;
    std::string *str;
}node ;
};

%token <node>INT
%token <node>FLOAT
%token <node>ID
%token <node>SEMI
%token <node>COMMA
%token <node>RELOP
%token <node>PLUS
%token <node>MINUS
%token <node>STAR
%token <node>DIV
%token <node>AND
%token <node>OR
%token <node>DOT
%token <node>NOT
%token <node>LP
%token <node>RP
%token <node>ERROR
%token <node>SELECT
%token <node>FROM
%token <node>WHERE
%token <node>STRING


%left    OR
%left    AND
%left    RELOP
%left    PLUS MINUS
%left    STAR DIV
%right   NOT
%left    DOT LP RP

%type <node> query query_body select_part from_part bool_exp
%type <node> select_obj column from_obj nickname
%type <node> exp select_objs mand

%%

query : query_body SEMI
      | query_body
      ;

query_body : mand {if (!error_exists) {cout << "OK\n";}}
           | mand WHERE {in_where = true;} bool_exp {
            in_where = false;
            if (!error_exists) {
                cout << "OK\n";
            }
           }
           ;

mand : SELECT select_part FROM {in_from = true;} from_part {in_from = false;
         check_table_sel();};

select_part : {in_sel = true;} select_objs {in_sel = false;}
            | STAR
            ;

select_objs : select_obj
            | select_obj COMMA select_objs
            ;

select_obj : column
           | column nickname
           | ID {check_func($1.str);} LP select_objs RP
           ;

from_part : from_obj
          | from_obj COMMA from_obj
          ;

from_obj : ID {add_table2($1.str);}
         | ID nickname {add_table2($2.str);}
         ;

bool_exp : bool_exp AND bool_exp
         | bool_exp OR bool_exp
         | exp RELOP exp
         | NOT bool_exp
         ;

exp : column PLUS column
    | column MINUS column
    | column STAR column
    | column DIV column
    | LP exp RP
    | MINUS exp
    | column
    | INT
    | FLOAT
    | STRING
    ;

column : ID {add_table($1.str);} DOT ID
       | ID
       ;

nickname : ID
         ;

%%

int yyerror(char * msg) {
    error_exists = true;
    printf("Error exists in SQL\n");
}

void check_table_sel() {
    for (auto it = selected_table.begin();
            it != selected_table.end(); it++) {
        if (from_table.find(it->first) == from_table.end()) {

/*
            for (auto x = from_table.begin();
                    x != from_table.end(); x++) {
                std::cout << x->first << endl;;
            }
            std::cout << it->first << endl;
*/
            Log("Unselected table in SELECT");
            yyerror(nullptr);
        }
    }
}

void check_table_where(string *s) {
    if (from_table.find(*s) == from_table.end()) {
        Log("Unselected table in WHERE");
        yyerror(nullptr);
    }
}

void add_table(string *s) {
    if (in_sel) {
        assert(!in_from);
        assert(!in_where);
        selected_table.insert({*s, 0});
    } else if (in_where){
        assert(in_where);
        check_table_where(s);
    }
}

void add_table2(string *s) {
    if (!in_from) {
        return;
    }
    assert(!in_where);
    from_table.insert({*s, 0});
}

list<string> supported_functions = {
    "count",
    "max",
    "min",
    "avg",
    "sum",
    "sqrt",
    "rand",
    "concat",
    "numeric",
    "string"
};

void check_func(string *s) {
    transform(s->begin(), s->end(), s->begin(), ::tolower);
    list<string>::iterator it = find(supported_functions.begin(),
            supported_functions.end(), *s);
    if (it == supported_functions.end()) {
        Log("Unsupported Function!");
        yyerror(nullptr);
    }
}
