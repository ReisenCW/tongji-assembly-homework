#include "stdlib.h"
#include "stdio.h"

void mul_table(int);

int main() {
    printf("The 9 mul 9 table:\n");
    for(int i = 9; i > 0; i--) {
        mul_table(i);
    }
    return 0;
}

void mul_table(int n) {
    for(int i = 1; i<=n; i++) {
        printf("%dx%d=%d  ", n, i, n*i);
    }
    printf("\n");
}