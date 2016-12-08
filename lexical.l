%{
  #include "string.h"
  #include "stdio.h"
  #include "stdlib.h"
  #include "syntax.tab.h"

#define true 1
#define false 0
%}

digit	[0-9]
digit_0	[1-9]
alpha_	[a-zA-Z_]

%START COMMENTS
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

 /*spaces
 */
<INITIAL>[\ \t\b\f\r]	{;}
<INITIAL>\n		{;}

 /*relops
 */
<INITIAL>">="|"<="|"="|"!="|">"|"<" {
	char* str = strdup(yytext);
	yylval.error_exists = false;
	return RELOP;
}
<INITIAL>";" {
	yylval.error_exists = false;
	return SEMI;
}
<INITIAL>"," {
	yylval.error_exists = false;
	return COMMA;
}
<INITIAL>"+" {
	yylval.error_exists = false;
	return PLUS;
}
<INITIAL>"-" {
	yylval.error_exists = false;
	return MINUS;
}
<INITIAL>"*" {
	yylval.error_exists = false;
	return STAR;
}
<INITIAL>"/" {
	yylval.error_exists = false;
	return DIV;
}
<INITIAL>"." {
	yylval.error_exists = false;
	return DOT;
}
<INITIAL>"!" {
	yylval.error_exists = false;
	return NOT;
}
<INITIAL>"(" {
	yylval.error_exists = false;
	return LP;
}
<INITIAL>")" {
	yylval.error_exists = false;
	return RP;
}

 /*build-in types
 */
<INITIAL>{digit}*"."{digit}*[Ee][+-]?{digit}+ {
	yylval.error_exists = true;
    printf("Error: Scientific notation (unsupported) \'%s\'\n", yytext);
    return FLOAT;
}
<INITIAL>{digit}+"."{digit}+ {
	yylval.error_exists = false;
    return FLOAT;
}
<INITIAL>{digit}{10}{digit}+ {
	yylval.error_exists = true;
    printf("Error: Too large number \'%s\'\n", yytext);
    return INT;
}
<INITIAL>{digit_0}{digit}{0,9}|"0" {
	if(atoll(yytext)>0xffffffff){
        yylval.error_exists = true;
        printf("Error: Too large number \'%s\'\n", yytext);
        return INT;
	}
	else{
        yylval.error_exists = false;
		return INT;
	}
}
<INITIAL>"0x"[0-9a-f]{1,8}|"0X"[0-9A-F]{1,8} {//hex
    yylval.error_exists = true;
    printf("Error: hex (unsupported) \'%s\'\n", yytext);
    return INT;
}
<INITIAL>"0"[0-7]{1,16} { //oct
    yylval.error_exists = true;
    printf("Error: oct (unsupported) \'%s\'\n", yytext);
    return INT;
}

<INITIAL>{alpha_}({alpha_}|{digit})* {
    yylval.error_exists = false;
	return ID;
}
<INITIAL>. {
    yylval.error_exists = true;
    printf("Error: Mysterious characters \'%s\'\n", yytext);
}

%%
