; 计算1到100的和，结果存放在栈中
DATA SEGMENT
    STR_BUF DB 5 DUP(0)  ; 字符串缓冲区
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
START:
    MOV AX, DATA        ; 初始化DS
    MOV DS, AX

    ; 结果存储在栈中：先压入初始值0作为sum的起点
    MOV AX, 0
    PUSH AX             ; 栈顶初始为0（sum=0）
    MOV CX, 1           ; 循环变量i=1

LOOPSTART:
    ; 栈操作：sum（栈顶） += i（CX）
    POP AX              ; 从栈中弹出当前sum到AX
    ADD AX, CX          ; AX = sum + i
    PUSH AX             ; 将新的sum压回栈中（栈顶更新为新sum）
    INC CX              ; i++
    CMP CX, 100
    JLE LOOPSTART

    ; 打印栈中存储的结果（栈顶=5050）
    POP BX              ; 将栈顶的结果弹出到BX，供转换子程序使用
    LEA DI, STR_BUF
    CALL NUM_TO_STR

    LEA DX, STR_BUF
    MOV AH, 09h
    INT 21h

    ; 程序退出
    MOV AH, 4Ch
    INT 21h


; 子程序：同版本1（将BX中的数值转为字符串）
NUM_TO_STR PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV SI, 0
    MOV AX, BX
    MOV BX, 10

    CMP AX, 0
    JNE NOT_ZERO
    MOV BYTE PTR [DI], '0'
    INC DI
    JMP END_CONV

NOT_ZERO:
DIV_LOOP:
    MOV DX, 0
    DIV BX
    ADD DL, '0'
    PUSH DX
    INC SI
    CMP AX, 0
    JNE DIV_LOOP

POP_LOOP:
    POP DX
    MOV BYTE PTR [DI], DL
    INC DI
    DEC SI
    JNZ POP_LOOP

END_CONV:
    MOV BYTE PTR [DI], '$'

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
NUM_TO_STR ENDP

CODE ENDS
END START