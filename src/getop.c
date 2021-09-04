#include<stdio.h> // for EOF
#include<ctype.h> // for isdigits , islower
#include"getch.h"
#include"revrse_polish_calc.h"

static const char *operators[] = OPLIST;

// getop: function to recognise operators and numbers ,writing number to to string
int getop(char *const str)
{
	int i = 0, ch;

	while((str[0] = ch = getch()) == ' ' || ch == '\t')
		;
	str[1] = '\0';
	if(!isdigit(ch) && ch != '.' && ch != '-') {
		if(ch != '\n' && ch != EOF) {
			int chr; // this ch has no relation to the one above.
			while((str[++i] = chr = getch()) != ' ' && chr != '\t' && chr != '\n' && chr != EOF)
				;
			ungetch(str[i]);
			str[i] = '\0';
			if(str[1] != '\0') {
				for(int j = 0; operators[j][0] != '\0'; j++)
					if(my_strcomp(operators[j], str) == '\0')
						return OPERATOR;
			}
			else if(islower(ch))
				return VARIBLE;
		}
		return ch;
	}
	if(ch == '-')
		if(!isdigit(str[++i] = ch = getch()) && ch != '.') {
			ungetch(ch);
			str[i] = '\0';
			return '-';
		}
	if(isdigit(ch))
		while(isdigit(str[++i] = ch = getch()))
			;
	if(ch == '.')
		while(isdigit(str[++i] = ch = getch()))
			;
	if(ch == 'e' || ch == 'E') {
		if(isdigit(str[++i] = ch = getch()) || ch == '-')
			while(isdigit(str[++i] = ch = getch()))
			;
	}
	str[i] = '\0';
	if(ch != EOF)
		ungetch(ch);
	return NUMBER;
}

// Compare strings and return the first character in str2 that does not match with str1. Return value of '\0' signals indntical strings.
const char my_strcomp(const char *str1, const char *str2)
{
	int i;

	for(i = 0; str1[i] != '\0'; i++)
		if(str1[i] != str2[i])
			break;
	return str2[i];
}
