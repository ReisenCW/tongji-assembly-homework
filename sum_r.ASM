; 计算 1 到 100 的和, 结果存放在BX寄存器中
DATA SEGMENT
    STR_BUF DB 5 DUP(0)  ; 用于存储转换后的ASCII字符串(最多4位数字+终止符'$')
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
START:
    MOV AX, DATA  ; 初始化数据段寄存器
    MOV DS, AX

    MOV BX, 0         ; BX寄存器用于存储sum,初始化为0
    MOV CX, 1         ; CX寄存器用于存储i,初始化为1
LOOPSTART:
    ADD BX, CX          ; BX = BX + CX
    INC CX
    CMP CX, 100        ; 比较CX和100
    JLE LOOPSTART       ; jump less equal 如果CX <= 100,跳回 LOOPSTART 继续循环

    ; 打印最终结果
    ; 将数值 BX 转换为ASCII字符串(存到STR_BUF)
    LEA DI, STR_BUF   ; DI指向字符串缓冲区
    CALL NUM_TO_STR   ; 调用转换子程序

    ; 打印字符串(使用AH=09h,打印以'$'结尾的字符串)
    LEA DX, STR_BUF     ; DX指向要打印的字符串
    MOV AH, 09h
    INT 21h

    ; 程序退出
    MOV AH, 4Ch
    INT 21h

; 子程序:将16位数值(BX)转换为ASCII字符串(存到DI指向的缓冲区,以'$'结尾)
NUM_TO_STR PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV SI, 0         ; SI记录数字位数
    MOV AX, BX        ; AX暂存待转换的数值
    MOV BX, 10        ; BX=10(用于十进制取余)

    ; 特殊处理0的情况
    CMP AX, 0
    JNE NOT_ZERO
    ; 如果AX = 0,直接存储字符'0'
    MOV BYTE PTR [DI], '0'
    INC DI      ; 缓冲区指针后移
    JMP END_CONV

NOT_ZERO:
    ; 循环取余,获取每一位数字(逆序存到栈中)
DIV_LOOP:
    MOV DX, 0         ; DX清0(扩展AX为DX:AX)
    DIV BX            ; DX:AX / BX, 结果默认存放: AX=商,DX=余数
    ADD DL, '0'       ; 余数转换为ASCII码(DL=余数)
    PUSH DX           ; 数字入栈(暂存,逆序)
    INC SI            ; 位数+1
    CMP AX, 0         ; 商是否为0
    JNE DIV_LOOP      ; 若不为0,继续取位

    ; 出栈,恢复数字顺序(正序存到缓冲区)
POP_LOOP:
    POP DX            ; 从栈中取出数字(正序)
    MOV BYTE PTR [DI], DL      ; 存入缓冲区
    INC DI            ; 缓冲区指针后移
    DEC SI            ; 位数-1
    JNZ POP_LOOP      ; 未取完则继续

END_CONV:
    MOV BYTE PTR [DI], '$'  ; 字符串结尾添加'$'(满足AH=09h要求)

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
NUM_TO_STR ENDP         ; Procedure 结束

CODE ENDS
END START  ; 程序入口点为START