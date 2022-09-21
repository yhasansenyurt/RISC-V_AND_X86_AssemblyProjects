#include <stdio.h>

extern "C" int func(char *a);

int main(void)
{
  char text[]="Il ][ barbiere ][ di Siviglia"; // input value for the program. It is changable only here. (because when I use scanf to get input, program inside
                                               //assembly assumed that space between words is null character. So, I asked you about this in the lab, you said
                                               // you can use defined string as input.)

  printf("Input string         > %s \nConversion Results   >\n",text);
  printf("\nReturn Value         > %d\n", func(text)); //this function returns length of the string and prints out the needed letters. ([***])

  return 0;
}
