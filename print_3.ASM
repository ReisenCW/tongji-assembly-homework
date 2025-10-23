	.file	"printASCII_3.c"
	.intel_syntax noprefix
	.text
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	push	rbp
	.seh_pushreg	rbp
	mov	rbp, rsp
	.seh_setframe	rbp, 0
	sub	rsp, 48
	.seh_stackalloc	48
	.seh_endprologue
	call	__main
	mov	DWORD PTR -4[rbp], 0
	mov	BYTE PTR -5[rbp], 97
	jmp	.L2
.L5:
	movsx	eax, BYTE PTR -5[rbp]
	mov	ecx, eax
	call	putchar
	cmp	DWORD PTR -4[rbp], 12
	jne	.L3
	mov	ecx, 10
	call	putchar
	mov	DWORD PTR -4[rbp], 0
	jmp	.L4
.L3:
	mov	ecx, 32
	call	putchar
	add	DWORD PTR -4[rbp], 1
.L4:
	movzx	eax, BYTE PTR -5[rbp]
	add	eax, 1
	mov	BYTE PTR -5[rbp], al
.L2:
	cmp	BYTE PTR -5[rbp], 122
	jle	.L5
	mov	eax, 0
	add	rsp, 48
	pop	rbp
	ret
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (MinGW-W64 x86_64-ucrt-posix-seh, built by Brecht Sanders, r3) 14.2.0"
	.def	putchar;	.scl	2;	.type	32;	.endef
