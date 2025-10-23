#include "stdlib.h"
#include "stdio.h"

int main() {
    // 打印ASCII表中的小写字母部分
    int i = 0;
    for (char c = 'a'; c <= 'z'; c++) {
        putchar(c);
        if(i == 12) {
            putchar('\n');
            i = 0;
        } else {
            putchar(' ');
            i++;
        }
    }
}