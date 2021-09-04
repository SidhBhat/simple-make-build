#ifndef REVRSE_POLISH_CALC_H_INCLUDED
#define REVRSE_POLISH_CALC_H_INCLUDED

#include"stack.h"

#define OPLIST {"sin","cos","tan","sinh","cosh","tanh","ln","log","pow","sqrt","cbrt","ans","clear","exit",""}

// Compare strings and return the first character in str2 that does not match with str1. Return value of '\0' signals indntical strings.
const char my_strcomp(const char *str1, const char *str2);

// getop: function to recognise operators and numbers ,writing number to to string
int getop(char *const str);



#define MAXOP 100      /*max size of operator*/
#define NUMBER '0'     /*siganl that value is number */
#define OPERATOR '1'   /*signal for a operator */
#define VARIBLE '2'    /* signal that the value is a variible */

#endif // REVRSE_POLISH_CALC_H_INCLUDED
