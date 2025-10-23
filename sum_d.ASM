; 计算1到100的和，结果存放在数据段的变量中
DATA SEGMENT
    STR_BUF DB 5 DUP(0)    ; 字符串缓冲区
    SUM_DATA DW 0          ; 数据段变量，用于存储和（16位，初始为0）
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
START:
    MOV AX, DATA        ; 初始化DS
    MOV DS, AX

    ; 结果存储在数据段的SUM_DATA变量中
    MOV WORD PTR [SUM_DATA], 0  ; 初始化和为0（数据段操作）
    MOV CX, 1                   ; 循环变量i=1

LOOPSTART:
    ; 数据段操作：sum（SUM_DATA） += i（CX）
    MOV AX, [SUM_DATA]   ; 从数据段读取当前和到AX
    ADD AX, CX           ; AX = sum + i
    MOV [SUM_DATA], AX   ; 将结果写回数据段变量
    INC CX               ; i++
    CMP CX, 100
    JLE LOOPSTART

    ; 打印数据段中存储的结果（SUM_DATA=5050）
    MOV BX, [SUM_DATA]   ; 将数据段变量的值读到BX，供转换子程序使用
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