%{
#include <cstring>
#include <cstdio>
#include "syntax.tab.h"
#include "debug.h"

%}

%option caseless

digit	[0-9]
digit_0	[1-9]
alpha_	[a-zA-Z_]

%START COMMENTS
%START STR
%%


 /*comments
  */
<INITIAL>"/*"	{BEGIN COMMENTS;}
<COMMENTS>"*/"	{BEGIN INITIAL;}
<COMMENTS>(.|\n)		{;}
<COMMENTS><<EOF>>	{
	BEGIN INITIAL;
	printf("Error: Comments met EOF\n");
}

<INITIAL>"'" {BEGIN STR;}
<STR>"'" {
    BEGIN INITIAL;
    Log("STRING");
    return STRING;
}
<STR>(.|\n)		{;}
<STR><<EOF>>	{
	BEGIN INITIAL;
	printf("Error: String met EOF\n");
}

 /*spaces
 */
<INITIAL>[\ \t\b\f\r]	{;}
<INITIAL>\n		{;}

 /*relops
 */
<INITIAL>">="|"<="|"="|"!="|">"|"<" {
	char* str = strdup(yytext);
	yylval.error_exists = false;
    Log("RELOP");
	return RELOP;
}
<INITIAL>";" {
	yylval.error_exists = false;
    Log("SEMI");
	return SEMI;
}
<INITIAL>"," {
	yylval.error_exists = false;
    Log("COMMA");
	return COMMA;
}
<INITIAL>"+" {
	yylval.error_exists = false;
    Log("PLUS");
	return PLUS;
}
<INITIAL>"-" {
	yylval.error_exists = false;
    Log("MINUS");
	return MINUS;
}
<INITIAL>"*" {
	yylval.error_exists = false;
    Log("STAR");
	return STAR;
}
<INITIAL>"/" {
	yylval.error_exists = false;
    Log("DIV");
	return DIV;
}
<INITIAL>"." {
	yylval.error_exists = false;
    Log("DOT");
	return DOT;
}
<INITIAL>"!" {
	yylval.error_exists = false;
    Log("NOT");
	return NOT;
}
<INITIAL>"(" {
	yylval.error_exists = false;
    Log("LP");
	return LP;
}
<INITIAL>")" {
	yylval.error_exists = false;
    Log("RP");
	return RP;
}

 /*build-in types
 */
<INITIAL>{digit}*"."{digit}*[Ee][+-]?{digit}+ {
	yylval.error_exists = true;
    printf("Error: Scientific notation (unsupported) \'%s\'\n", yytext);
    Log("FLOAT");
    return FLOAT;
}
<INITIAL>{digit}+"."{digit}+ {
	yylval.error_exists = false;
    Log("FLOAT");
    return FLOAT;
}
<INITIAL>{digit}{10}{digit}+ {
	yylval.error_exists = true;
    printf("Error: Too large number \'%s\'\n", yytext);
    Log("INT");
    return INT;
}
<INITIAL>{digit_0}{digit}{0,9}|"0" {
	if(atoll(yytext)>0xffffffff){
        yylval.error_exists = true;
        printf("Error: Too large number \'%s\'\n", yytext);
        Log("INT");
        return INT;
	}
	else{
        yylval.error_exists = false;
        Log("INT");
		return INT;
	}
}
<INITIAL>"0x"[0-9a-f]{1,8}|"0X"[0-9A-F]{1,8} {//hex
    yylval.error_exists = true;
    printf("Error: hex (unsupported) \'%s\'\n", yytext);
    Log("INT");
    return INT;
}
<INITIAL>"0"[0-7]{1,16} { //oct
    yylval.error_exists = true;
    printf("Error: oct (unsupported) \'%s\'\n", yytext);
    Log("INT");
    return INT;
}

<INITIAL>"select" {
    yylval.error_exists = false;
    Log("SELECT");
    return SELECT;
}

<INITIAL>"from" {
    yylval.error_exists = false;
    Log("FROM");
    return FROM;
}

<INITIAL>"where" {
    yylval.error_exists = false;
    Log("WHERE");
    return WHERE;
}

<INITIAL>"AND" {
    yylval.error_exists = false;
    Log("AND");
    return AND;
}

<INITIAL>"OR" {
    yylval.error_exists = false;
    Log("OR");
    return OR;
}

<INITIAL>{alpha_}({alpha_}|{digit})* {
    yylval.error_exists = false;
    Log("ID");
	return ID;
}
<INITIAL>. {
    yylval.error_exists = true;
    printf("Error: Mysterious characters \'%s\'\n", yytext);
}

%%
