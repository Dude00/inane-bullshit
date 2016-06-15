%{
#define YYSTYPE double
#include "calc.tab.h"
#include <stdlib.h>
#include <stdbool.h> 

extern int yylex(void);
extern int yyparse(void);
static const bool DEBUG = false;

void lex_parsestr(const char *s)
{
        yy_scan_string(s);
		if(DEBUG)
		 printf("current buffer is %s\n",YY_CURRENT_BUFFER);
        yyparse();
		if(DEBUG)
		 printf("post parse\n");
		yy_delete_buffer(YY_CURRENT_BUFFER);
}


%}
%option noyywrap

white [ \t]+
digit [0-9]
integer {digit}+
exponent [eE][+-]?{integer}
real {integer}("."{integer}){exponent}?


%%

{white} { }
{real} { yylval=atof(yytext); 
 return REAL;
}
{integer} {yylval=atof(yytext);
 return INTEGER;
 }

"+" return PLUS;
"-" return MINUS;
"*" return TIMES;
"/" return DIVIDE;
"^" return POWER;
"(" return LEFT;
")" return RIGHT;
"\r\n" return END;
"\r" return END;
"\n" return END;
"\0" return END;
"%" return MODULO;
"d" return DICE;
"D" return DICE;
"e" return EXPLODE;
"E" return EXPLODE;
"f" return FATE;
"F" return FATE;
"a" return ABILITY;
"A" return ABILITY;
"p" return PROFICIENCY;
"P" return PROFICIENCY;
"c" return CHALLENGE;
"C" return CHALLENGE;
"b" return BOOST;
"B" return BOOST;
"s" return SETBACK;
"S" return SETBACK;
