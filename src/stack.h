#ifndef STACK_H_INCLUDED
#define STACK_H_INCLUDED

#include<limits.h>

#define STACK_SIZE 5

#if STACK_SIZE > USHRT_MAX
# error "Stack size cannot be greater then maximum of unsigned int"
#endif
/* push :function to write to stack */
double const *push(double val);
/* Return value is a pointer to the stack value
 * if stack if full then the the return value is a Null pointer, and the pushed to the start of the stack.
 * effectively the data in the stack is lost
 */

/* pop: function to get value from the stack */
double pop(void);
/* Returns NaN if stack is empty */

// getval : fetches the value in stack at address, a number between 1-STACK_SIZE
double getval(unsigned short address);
/* If address is greater then the stack value, then the topmost value is returned
 * IF address is lesser or equal to zero the the first value is returned
 */

// getpop : pop the value at the current stack position without modifying the stack position
double getpop(void);

// clear the stack
void stackclear(void);

//print the stack
void stackprint(void);


#endif // STACK_H_INCLUDED
