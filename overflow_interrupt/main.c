#include "stdio.h"
#include "stdlib.h"

// 用户态的溢出处理, Overflow Interrupt Service Routine
void OverflowISR() {
	puts("Error: 有符号数运算溢出！程序终止。");
}

// 无符号数溢出处理
void UnsignedOverflowISR() {
	puts("Error: 无符号数运算溢出！程序终止。");
}

// 溢出提示字符串
char OverflowMsg[] = "Error: 有符号数运算溢出！程序终止。\n";

// 测试函数：使用内联汇编检测溢出，避免 JO/JNO 逻辑
void TestOverflow() {
	// 测试1: 有符号数加法，无溢出
	{
		int a = 100;
		int b = 200;
		int c = 0;
		int overflow = 0;

		printf("\n测试1: 有符号数 %d + %d = ?\n", a, b);

		__asm {
			mov eax, a
			add eax, b
			mov c, eax
			seto overflow
		}

		if (overflow) {
			OverflowISR();
		}
		else {
			printf("运算完成，结果：%d\n", c);
		}
	}

	// 测试2: 有符号数加法，有溢出
	{
		int a = INT_MAX;
		int b = 1;
		int c = 0;
		int overflow = 0;

		printf("\n测试2: 有符号数 %d + %d = ?\n", a, b);

		__asm {
			mov eax, a
			add eax, b
			mov c, eax
			seto overflow
		}

		if (overflow) {
			OverflowISR();
		}
		else {
			printf("运算完成，结果：%d\n", c);
		}
	}

	// 测试3: 无符号数加法，无溢出
	{
		unsigned int a = 100U;
		unsigned int b = 200U;
		unsigned int c = 0;
		int carry = 0;

		printf("\n测试3: 无符号数 %u + %u = ?\n", a, b);

		__asm {
			mov eax, a
			add eax, b
			mov c, eax
			setc carry
		}

		if (carry) {
			UnsignedOverflowISR();
		}
		else {
			printf("运算完成，结果：%u\n", c);
		}
	}

	// 测试4: 无符号数加法，有溢出
	{
		unsigned int a = UINT_MAX;
		unsigned int b = 1U;
		unsigned int c = 0;
		int carry = 0;

		printf("\n测试4: 无符号数 %u + %u = ?\n", a, b);

		__asm {
			mov eax, a
			add eax, b
			mov c, eax
			setc carry
		}

		if (carry) {
			UnsignedOverflowISR();
		}
		else {
			printf("运算完成，结果：%u\n", c);
		}
	}
}

int main() {
	TestOverflow();
	return 0;
}