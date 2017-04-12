%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <ctype.h>
    #include <string.h>
	#include <ctype.h>
	
    int yyerror(char *);
    int yylex(void);
    int yylineno;
    extern FILE * yyin;
    extern FILE *fopen(const char *filename, const char *mode);
    char * concat(const char *strings[], int length);
%}

%union {
	char * string;
}

%token OPEN_PAR CLOSE_PAR OPEN_CURL CLOSE_CURL SEMI_COLON VOID
%token <string> FUNC
%token <string> VAR

%type <string> block;
%type <string> function;
%type <string> type;
%start program

%%
program : function {printf("#include <stdio.h>; \n%s",$1);}
function : type FUNC OPEN_PAR CLOSE_PAR block {
											const char * array[] = {$1, " ", $2,"()\n",$5};
											$$ = concat(array, 5);
										 }
block : OPEN_CURL VAR CLOSE_CURL {
									const char * array[] = {"{\n", $2, "\n}\n"};
									$$ = concat(array, 3);
								 }
type : VOID {$$ = "void";}
%%

char * concat(const char *strings[], int length)
{
	//Get the amount of space needed for the final string and malloc
	int spaceNeeded = 1;
	for(int i = 0; i < length; i++){
		spaceNeeded += strlen(strings[i]);
	}
	
	//Concatenate all strings together into result
	char* result =  malloc(spaceNeeded);
	strcpy(result, strings[0]);
	for(int i = 1; i < length; i++)
	{
		strcat(result, strings[i]);
	}
	
	return result;
}

int yyerror(char *s){
    fprintf(stderr , "%s line %i \n", s, yylineno);
    exit(0);
}

int main(int argc ,char *argv[]){
    yyin = fopen(argv[1], "r");
    
    yyparse();
    
    fclose(yyin);
    return 0;
}
