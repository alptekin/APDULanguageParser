%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <stdbool.h>
    #include <map>

    using namespace std;

    int line_num = 1;
    map<string, int> token_index;
    int indexOf = 0;

    #define ELEMENT 1
    #define ATTRIBUTE 2
    #define STRING 3
    #define BOOL 4
%}
%option noyywrap

WORD [a-zA-Z0-9_.-]
QUOTED_STRING \"[^\"]*\"|'[^']*'

%%

{QUOTED_STRING} {
    if (token_index.count(yytext) == 0) {
        token_index[yytext] = indexOf;
        indexOf++;
    }

    return STRING;
}

"true"|"false" {
    if (token_index.count(yytext) == 0) {
        token_index[yytext] = indexOf;
        indexOf++;
    }

    return BOOL;
}

{WORD} {
    if (token_index.count(yytext) == 0) {
        token_index[yytext] = indexOf;
        indexOf++;
    }

    // Check if token is an attribute or element
    if (yytext[0] == '-') {
        return ATTRIBUTE;
    } else {
        return ELEMENT;
    }
}

[\t]+ {
    /* skip whitespace */
}

%%

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s filename\n", argv[0]);
        return 1;
    }

    FILE *file = fopen(argv[1], "r");
    if (!file) {
        fprintf(stderr, "Error: unable to open file %s\n", argv[1]);
        return 1;
    }

    yyin = file;

    int token;
    while ((token = yylex())) {
        printf("Token %d: %s\n", token, yytext);
    }

    fclose(file);
    return 0;
}