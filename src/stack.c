#include<stdio.h> // printf
#include<math.h> // for nan
#include<stddef.h> // for NULL
#include"stack.h"


static unsigned short stack_pos = 0;
static double stack[STACK_SIZE];

/* push :function to write to stack */
double const *push(double val)
{
	if(stack_pos < STACK_SIZE) {
		stack[stack_pos++] = val;
		return &stack[stack_pos - 1];
	}
	stack_pos = 0;
	stack[stack_pos++] = val;

	return NULL;
}
/* Return value is a pointer to the stack value
 * if stack if full then the the return value is a Null pointer, and the pushed to the start of the stack.
 * effectively the data in the stack is lost
 */

/* pop: function to get value from the stack */
double pop(void)
{
	if (stack_pos > 0)
		return stack[--stack_pos];
	else {
		return nan("");
	}
}
/* Returns NaN if stack is empty */

// getval : fetches the value in stack at address, a number between 1-STACK_SIZE
double getval(unsigned short address)
{
	return (address > STACK_SIZE) ? stack[STACK_SIZE -1] : stack[((address < 1) ? 1 : address) - 1];
}
/* If address is greater then the stack value, then the topmost value is returned
 * IF address is lesser or equal to zero the the first value is returned
 */

// getpop : pop the value at the current stack position without modifying the stack position
double getpop()
{
	return (stack_pos > 0) ? stack[stack_pos - 1] : nan("");
}

// clear the stack
void stackclear(void)
{
	for(int i = 0; i < STACK_SIZE; i++)
		stack[i] = 0.0;
	stack_pos = 0;
}

void stackprint(void)
{
	for(int i = 0; i < STACK_SIZE; i++)
		printf("%10.5f    ", stack[i]);
	putchar('\n');
}
