%{
#include<cstdio>
#include"lex.yy.c"

extern int yyerror(char * msg);

%}

%locations

%union {
int error_exists;
};

%token <error_exists>INT
%token <error_exists>FLOAT
%token <error_exists>ID
%token <error_exists>SEMI
%token <error_exists>COMMA
%token <error_exists>RELOP
%token <error_exists>PLUS
%token <error_exists>MINUS
%token <error_exists>STAR
%token <error_exists>DIV
%token <error_exists>AND
%token <error_exists>OR
%token <error_exists>DOT
%token <error_exists>NOT
%token <error_exists>LP
%token <error_exists>RP
%token <error_exists>ERROR
%token <error_exists>SELECT
%token <error_exists>FROM
%token <error_exists>WHERE
%token <error_exists>STRING


%left    OR
%left    AND
%left    RELOP
%left    PLUS MINUS
%left    STAR DIV
%right   NOT
%left    DOT LP RP

%type <error_exists> query query_body select_part from_part bool_exp
%type <error_exists> select_obj column from_obj nickname
%type <error_exists> exp select_objs

%%

query : query_body SEMI
      | query_body
      ;

query_body : SELECT select_part FROM from_part WHERE bool_exp
      | SELECT select_part FROM from_part
      ;

select_part : select_objs
            | STAR
            ;

select_objs : select_obj
            | select_obj COMMA select_part
            ;

select_obj : column
           | column nickname
           ;

from_part : from_obj
          | from_obj COMMA from_obj
          ;

from_obj : ID
         | ID nickname
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

column : ID DOT ID
       | ID
       ;

nickname : ID
         ;

%%

int yyerror(char * msg) {
    printf("Error exists in SQL\n");
}
