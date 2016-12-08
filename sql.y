%{
}%

%token SELECT
%token SEMI

%%

query : query_body SEMI;
      | query_body;

query_body : SELECT select_part FROM from_part WHERE bool_exp;
      | SELECT select_part FROM from_part;

select_part : select_obj;
            | select_obj COMMA select_part;

select_obj : column;
           | column nickname;

from_part : from_obj;
          | from_obj COMMA from_obj;

from_obj : table;
         | table COMMA nickname;

bool_exp : bool_exp AND bool_exp;
         | bool_exp OR bool_exp;
         | exp RELOP exp;
         | NOT bool_exp;

exp : column PLUS column;
    | column MINUS column;
    | column STAR column;
    | column DIV column;
    | LP exp RP;
    | MINUS exp;
    | column;
    | INT;
    | FLOAT;



column : ID DOT ID;
       | ID;

nickname : ID;

%%
