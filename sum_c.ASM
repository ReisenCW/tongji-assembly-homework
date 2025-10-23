.file	"sum_c.c"                   ; 指明源文件为sum_c.c
	.intel_syntax noprefix
	.text
	.section .rdata,"dr"
.LC0:
	; ASCII码表示的字符串:"%d\n\0"(\12是换行符ASCII码)
	.ascii "%d\12\0"
	.text                            ; 回到代码段
	.globl	main                     ; 声明main为全局符号(可被外部引用)
	.def	main;	.scl	2;	.type	32;	.endef  ; 定义main函数的属性
	.seh_proc	main                 ; 开始main函数的结构化异常处理描述
main:
	push	rbp                     ; 保存rbp寄存器(栈帧基址)到栈中
	.seh_pushreg	rbp                ; SEH记录:rbp寄存器被压栈
	mov	rbp, rsp                  ; 设置当前栈顶rsp为新的栈帧基址rbp
	.seh_setframe	rbp, 0             ; SEH记录:栈帧基址为rbp,偏移0
	sub	rsp, 48                   ; 在栈上分配48字节空间(用于局部变量和临时数据)
	.seh_stackalloc	48                ; SEH记录:分配了48字节栈空间
	.seh_endprologue                 ; 结束函数序言(栈帧和SEH初始化完成)
	call	__main                   ; 调用MinGW的初始化函数(负责C库初始化)
	mov	DWORD PTR -4[rbp], 0       ; 局部变量sum(rbp-4)初始化为0(sum = 0)
	mov	DWORD PTR -8[rbp], 1       ; 局部变量i(rbp-8)初始化为1(i = 1)
	jmp	.L2                        ; 跳转到.L2标签(循环条件判断)
.L3:                                 ; 循环体标签
	mov	eax, DWORD PTR -8[rbp]     ; 将i的值(rbp-8)读取到eax寄存器
	add	DWORD PTR -4[rbp], eax     ; sum += i(将eax中的i加到sum(rbp-4)中)
	add	DWORD PTR -8[rbp], 1       ; i += 1(i自增1)
.L2:                                 ; 循环条件判断标签
	cmp	DWORD PTR -8[rbp], 100     ; 比较i(rbp-8)和100(判断i <= 100？)
	jle	.L3                        ; 如果i <= 100,跳回.L3继续循环
	; 循环结束,准备打印结果
	mov	eax, DWORD PTR -4[rbp]     ; 将sum的值(rbp-4)读取到eax
	mov	edx, eax                   ; 将sum的值从eax传递到edx(printf的第二个参数)
	lea	rax, .LC0[rip]             ; 通过RIP相对寻址获取格式字符串.LC0的地址,存入rax
	mov	rcx, rax                   ; 将格式字符串地址从rax传递到rcx(printf的第一个参数,x86_64 Windows调用约定)
	call	printf                    ; 调用printf函数,打印sum的值
	mov	eax, 0                     ; 设置main函数返回值为0(return 0)
	add	rsp, 48                    ; 释放栈上分配的48字节空间(恢复栈顶)
	pop	rbp                        ; 从栈中恢复rbp寄存器(还原调用者栈帧)
	ret                             ; 函数返回
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef  ; 定义__main函数的属性
	.ident	"GCC: (MinGW-W64 x86_64-ucrt-posix-seh, built by Brecht Sanders, r3) 14.2.0"  ; 编译器标识信息
	.def	printf;	.scl	2;	.type	32;	.endef  ; 定义printf函数的属性