#include<stdio.h>
#include<stdlib.h> // for atof
#include<math.h> // for mathematical functions
#include<sys/ioctl.h> // for ioctl ,TIOCGWINSZ
#include<unistd.h> // for STDOUT_FILENO
#include"revrse_polish_calc.h"

#define MAX_STR MAXOP
#define STATE_FAIL 1
#define STATE_SUCCESS 0
#define STATE_RESET STATE_SUCCESS

static short popflg = STATE_RESET;
struct winsize w;

double popw(void)
{
	double val = pop();

	if((isnan(val) ? 1 : (popflg = STATE_SUCCESS, 0)) && popflg == STATE_SUCCESS) {
		printf("\x1b[31mError \x1b[0m: an empty stack event detected, please supply sufficient arguments\n");
		popflg = STATE_FAIL;
	}
	return val;
}

int main(void)
{
	double oprd, ans, vars[26], *varptr = NULL;
	char str[MAX_STR];
	short cycle = 0;
	int type;

	for(int i = 0; i < 26 ; i++)
		vars[i] = 0.0;

	ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);

	if(w.ws_col < 18) {
		printf("\x1b[31mERROR \x1b[0m: termianl too small, minimum required width: 18");
		return 1;
	}

	putchar('#');
	for (int i = 0; i < w.ws_col - 2; i++)
		putchar('-');
	printf("#\nReverse Polish Calculator\n#");
	for (int i = 0; i < w.ws_col - 2; i++)
		putchar('-');
	puts("#");


	while((type = getop(str)) != EOF) {
		(cycle > 0) ? cycle++ : 0;
		switch(type) {
			case NUMBER:
				push(atof(str));
				break;
			case OPERATOR:
				if(my_strcomp(str,"sin") == '\0') {
					push(sin(popw()));
					break;
				}
				else if(my_strcomp(str,"cos") == '\0') {
					push(cos(popw()));
					break;
				}
				else if(my_strcomp(str,"tan") == '\0') {
					push(tan(popw()));
					break;
				}
				else if(my_strcomp(str,"sinh") == '\0') {
					push(sinh(popw()));
					break;
				}
				else if(my_strcomp(str,"cosh") == '\0') {
					push(cosh(popw()));
					break;
				}
				else if(my_strcomp(str,"tanh") == '\0') {
					push(tanh(popw()));
					break;
				}
				else if(my_strcomp(str,"pow") == '\0') {
					oprd = popw();
					push(pow(popw(), oprd));
					break;
				}
				else if(my_strcomp(str,"ln") == '\0') {
					push(log(popw()));
					break;
				}
				else if(my_strcomp(str,"log") == '\0') {
					push(log10(popw()));
					break;
				}
				else if(my_strcomp(str,"sqrt") == '\0') {
					push(sqrt(popw()));
					break;
				}
				else if(my_strcomp(str,"cbrt") == '\0') {
					push(cbrt(popw()));
					break;
				}
				else if(my_strcomp(str,"ans") == '\0') {
					push(ans);
					break;
				}
				else if(my_strcomp(str,"clear") == '\0') {
					stackclear();
					break;
				}
				else if(my_strcomp(str,"exit") == '\0') {
					return 0;
					break;
				}
				else {
					printf("\x1b[31mError \x1b[0m: unknown command \"%s\"\n", str);
					pop();
					push(nan(""));
					break;
				}
			case VARIBLE:
				{
					int tmp = str[0] - 'a';
					varptr = &vars[tmp];
					cycle = 1;
					push(vars[tmp]);
				}
				break;
			case '+':
				push(popw() + popw());
				break;
			case '*':
				push(popw() * popw());
				break;
			case '-':
				oprd = popw();
				push(popw() - oprd);
				break;
			case '/':
				oprd = popw();
				if(oprd == 0.0) {
					printf("\x1b[31mError \x1b[0m: Division by zero\n");
					push(INFINITY);
				}
				else
					push(popw() / oprd);
				break;
			case '%':
				oprd = popw();
				if(oprd == 0.0)
					printf("\x1b[31mError \x1b[0m: Division by zero\n");
				push(fmod(popw(), oprd));
				break;
			case '^':
				oprd = popw();
				push(pow(pop(), oprd));
				break;
			case '?':
				push(getpop());
				break;
			case '=':
				oprd = popw();
				popw();
				if(varptr != NULL && cycle > 2)
					push(*varptr = oprd);
				else {
					printf("\x1b[31mError \x1b[0m: Assignment to non-varible\n");
					push(oprd);
				}
				cycle = 0;
				break;
			case '\n':
				printf("ans =\t%10.8g\n", ans = pop());

				popflg = STATE_RESET;
				varptr = NULL;
				stackprint();
				stackclear();
				ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
				for (int i = 0; i < w.ws_col; i++)
					putchar('-');
				putchar('\n');
				break;
			default:
				printf("\x1b[31mError \x1b[0m: unknown command \"%s\"\n", str);
				pop();
				push(nan(""));
				break;
		}
	}

	return 0;
}
