	.file	"multi.c"                  ; 声明源文件名为multi.c
	.intel_syntax noprefix            ; 使用Intel语法,不使用前缀
	.text                             ; 代码段开始

	.section .rdata,"dr"              ; 只读数据段开始
.LC0:                                 ; 字符串常量标签
	.ascii "The 9 mul 9 table:\0"     ; 存储字符串The 9 mul 9 table:
	.text                             ; 回到代码段

	.globl	main                    ; 声明main函数为全局可见
	.def	main;	.scl	2;	.type	32;	.endef  ; main函数的符号信息
	.seh_proc	main                 ; SEH(结构化异常处理)开始标记(main函数)
main:
	push	rbp                     ; 保存rbp寄存器(栈基址指针)
	.seh_pushreg	rbp                ; 记录rbp寄存器入栈(用于异常处理)
	mov	rbp, rsp                 ; 设置rbp为当前栈顶(建立栈帧)
	.seh_setframe	rbp, 0             ; 标记rbp为栈帧基址
	sub	rsp, 48                  ; 栈上分配48字节空间(局部变量和临时数据)
	.seh_stackalloc	48                ; 记录栈分配大小(用于异常处理)
	.seh_endprologue                  ; 函数序言结束(异常处理准备完成)

	call	__main                  ; 调用初始化函数__main(编译器生成的初始化代码)

	lea	rax, .LC0[rip]           ; 将字符串.LC0的地址加载到rax(RIP相对寻址)
	mov	rcx, rax                 ; 将字符串地址传入rcx(printf类函数的第一个参数)
	call	puts                    ; 调用puts函数输出字符串

	mov	DWORD PTR -4[rbp], 9     ; 在栈上(rbp-4位置)存储整数9(外层循环变量i=9)
	jmp	.L2                      ; 跳转到.L2标签(外层循环条件判断)

.L3:                                 ; 外层循环体开始标签
	mov	eax, DWORD PTR -4[rbp]   ; 将外层循环变量i加载到eax
	mov	ecx, eax                 ; 将i作为参数传入ecx(mul_table函数的参数)
	call	mul_table                ; 调用mul_table函数(打印i的乘法表行)
	sub	DWORD PTR -4[rbp], 1     ; 外层循环变量i减1(i--)

.L2:                                 ; 外层循环条件判断标签
	cmp	DWORD PTR -4[rbp], 0     ; 比较i和0
	jg	.L3                      ; 如果i>0,跳回.L3继续循环

	mov	eax, 0                   ; 将返回值0存入eax(main函数返回0)
	add	rsp, 48                  ; 释放栈上分配的48字节空间
	pop	rbp                     ; 恢复rbp寄存器
	ret                             ; 函数返回
	.seh_endproc                     ; SEH结束标记(main函数)

	.section .rdata,"dr"              ; 只读数据段开始
.LC1:                                 ; 格式字符串标签
	.ascii "%dx%d=%d  \0"             ; 存储格式化字符串
	.text                             ; 回到代码段

	.globl	mul_table               ; 声明mul_table函数为全局可见
	.def	mul_table;	.scl	2;	.type	32;	.endef  ; mul_table函数的符号信息
	.seh_proc	mul_table            ; SEH开始标记(mul_table函数)
mul_table:
	push	rbp                     ; 保存rbp寄存器
	.seh_pushreg	rbp                ; 记录rbp寄存器入栈(用于异常处理)
	mov	rbp, rsp                 ; 设置rbp为当前栈顶(建立栈帧)
	.seh_setframe	rbp, 0             ; 标记rbp为栈帧基址
	sub	rsp, 48                  ; 栈上分配48字节空间
	.seh_stackalloc	48                ; 记录栈分配大小(用于异常处理)
	.seh_endprologue                  ; 函数序言结束

	mov	DWORD PTR 16[rbp], ecx    ; 将参数(外层循环变量i)存入栈上(rbp+16位置)
	mov	DWORD PTR -4[rbp], 1     ; 在栈上(rbp-4位置)存储整数1(内层循环变量j=1)
	jmp	.L6                      ; 跳转到.L6标签(内层循环条件判断)

.L7:                                 ; 内层循环体开始标签
	mov	eax, DWORD PTR 16[rbp]   ; 将i加载到eax
	imul	eax, DWORD PTR -4[rbp]   ; 计算i×j(结果存入eax)
	mov	ecx, eax                 ; 将乘积存入ecx(作为printf的第三个参数)

	mov	edx, DWORD PTR -4[rbp]   ; 将j加载到edx(作为printf的第二个参数)
	mov	eax, DWORD PTR 16[rbp]   ; 将i加载到eax(作为printf的第一个参数)

	mov	r9d, ecx                 ; printf第四个参数：乘积(%d)
	mov	r8d, edx                 ; printf第三个参数：j(%d)
	mov	edx, eax                 ; printf第二个参数：i(%d)
	lea	rax, .LC1[rip]           ; 加载格式字符串地址到rax
	mov	rcx, rax                 ; printf第一个参数：格式字符串
	call	printf                   ; 调用printf打印"i×j=乘积  "

	add	DWORD PTR -4[rbp], 1     ; 内层循环变量j加1(j++)

.L6:                                 ; 内层循环条件判断标签
	mov	eax, DWORD PTR -4[rbp]   ; 将j加载到eax
	cmp	eax, DWORD PTR 16[rbp]   ; 比较j和i
	jle	.L7                      ; 如果j<=i,跳回.L7继续循环

	mov	ecx, 10                  ; 将ASCII码10(换行符'\n')存入ecx
	call	putchar                  ; 调用putchar打印换行符(结束当前行)

	nop                             ; 空操作(对齐指令)
	add	rsp, 48                  ; 释放栈上分配的48字节空间
	pop	rbp                     ; 恢复rbp寄存器
	ret                             ; 函数返回
	.seh_endproc                     ; SEH结束标记(mul_table函数)

	.def	__main;	.scl	2;	.type	32;	.endef  ; __main函数的符号信息
	.ident	"GCC: (MinGW-W64 x86_64-ucrt-posix-seh, built by Brecht Sanders, r3) 14.2.0"  ; 编译器标识
	.def	puts;	.scl	2;	.type	32;	.endef   ; puts函数的符号信息
	.def	printf;	.scl	2;	.type	32;	.endef  ; printf函数的符号信息
	.def	putchar;	.scl	2;	.type	32;	.endef ; putchar函数的符号信息