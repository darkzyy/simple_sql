%{
#include<cstdio>
#include<cassert>
#include"lex.yy.c"
#include<unordered_map>
#include<string>
#include<iostream>

using namespace std;

extern int yyerror(char * msg);
extern void add_table(string *s);
extern void add_table2(string *s);
extern bool check_table_sel();

unordered_map<string, int> selected_table;
unordered_map<string, int> from_table;

bool in_sel = false;
bool in_from = false;
bool in_where = false;

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

query_body : mand
           | mand WHERE {in_where = true;} bool_exp {in_where = false;}
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
    printf("Error exists in SQL\n");
}

bool check_table_sel() {
    for (auto it = selected_table.begin();
            it != selected_table.end(); it++) {
        if (from_table.find(it->first) == from_table.end()) {

            for (auto x = from_table.begin();
                    x != from_table.end(); x++) {
                std::cout << x->first << endl;;
            }
            std::cout << it->first << endl;
            Log("Unselected table in SELECT");
            yyerror(nullptr);
        }
    }
}

bool check_table_where(string *s) {
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
