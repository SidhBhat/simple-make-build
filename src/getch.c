#include<stdio.h>
#include"getch.h"

static int buf = 0;

/* get characters from buffer or stdin if buffer is empty */
int getch(void)
{
	if(buf) {
		if(buf == EOF)
			return buf;
		int tmp = buf;
		return buf = 0,tmp;
	}
	else
		return getchar();

}

/* put characters into buffer */
int ungetch(int ch)
{
	if(buf == 0)
		return buf = ch;
	return buf;
}

// clearerrgetch : clear fail state if getch
void clearerrgetch(void)
{
	buf = 0;
}
