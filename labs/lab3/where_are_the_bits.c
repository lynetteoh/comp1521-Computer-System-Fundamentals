// where_are_the_bits.c ... determine bit-field order
// COMP1521 Lab 03 Exercise
// Written by ...

#include <stdio.h>
#include <stdlib.h>

struct _bit_fields {
   unsigned int a : 4,
                b : 8,
                c : 20;
};

union bit_field{
	struct _bit_fields bits;
	unsigned int num;
};

int main(void)
{
   struct _bit_fields x;
   printf("%u\n",sizeof(x));

    union bit_field y;
    y.bits.c = 1;
    y.bits.b = 0;
    y.bits.a = 0;
    printf("%u\n",y.num);

    y.bits.a = 1;
    y.bits.b = 0;
    y.bits.c = 0;
    printf("%u\n",y.num);


   return 0;
}
