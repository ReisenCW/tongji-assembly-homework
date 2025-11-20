DATA SEGMENT
    ; 单个乘法项格式："a×b=c  "（6字符） + '$'，共7字节
    BUFFER DB 7 DUP(?)
    ; 换行符（CR+LF）
    CRLF DB 0DH, 0AH, '$'
DATA ENDS

CODE SEGMENT
    ASSUME DS:DATA, CS:CODE

START:
    MOV AX, DATA        
    MOV DS, AX

    ; 外层循环：被乘数从1到9
    MOV AX, 1           ; AX = 当前被乘数（初始为1）
PRINT_ALL_LOOP:
    CALL PRINT_ROW      ; 打印当前被乘数对应的行
    INC AX              ; 被乘数+1
    CMP AX, 10          ; 是否到10（遍历完9）
    JL PRINT_ALL_LOOP   ; 未遍历完则继续

    ; 程序结束返回DOS
    MOV AH, 4CH
    INT 21H


; 功能：打印一行乘法表（参数：AX=被乘数）
PRINT_ROW PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI             ; 新增临时寄存器，避免冲突

    MOV BX, AX          ; BX = 被乘数
    MOV CX, 1           ; 内层循环：乘数从1开始

PRINT_ROW_LOOP:
    ; 1. 计算乘积：被乘数(BX) * 乘数(CX) = 结果
    MOV AX, BX
    MUL CX              ; AX = BX*CX
    MOV DX, AX          ; 用DX暂存乘积，避免被后续指令覆盖

    ; 2. 格式化BUFFER为 "a×b=c  $"
    MOV SI, OFFSET BUFFER
    ; 填充被乘数（第0位）
    MOV AL, BL
    ADD AL, '0'
    MOV [SI], AL
    ; 填充x（第1位）
    MOV [SI+1], BYTE PTR 'x'
    ; 填充乘数（第2位）
    MOV AL, CL
    ADD AL, '0'
    MOV [SI+2], AL
    ; 填充=（第3位）
    MOV [SI+3], BYTE PTR '='
    ; 拆分结果的十位和个位
    MOV AX, DX          ; 取出暂存的乘积
    MOV DX, 0
    MOV DI, 10
    DIV DI              ; AX=十位，DX=个位
    ; 填充十位（第4位，不足则填空格）
    CMP AX, 0
    JE FILL_SPACE
    ADD AL, '0'
    JMP FILL_TEN
FILL_SPACE:
    MOV AL, ' '
FILL_TEN:
    MOV [SI+4], AL
    ; 填充个位（第5位）
    ADD DL, '0'
    MOV [SI+5], DL
    ; 结束符（第6位）
    MOV [SI+6], BYTE PTR '$'

    ; 3. 输出当前乘法项
    MOV DX, OFFSET BUFFER
    MOV AH, 09H
    INT 21H
    ; 输出项之间的分隔空格
    MOV DL, ' '
    MOV AH, 02H
    INT 21H

    ; 4. 内层循环控制：乘数 ≤ 被乘数（修正语法错误）
    INC CX
    MOV DI, BX          ; 把被乘数BX赋值给临时寄存器DI
    INC DI              ; DI = BX+1
    CMP CX, DI          ; 比较CX（当前乘数）和DI（BX+1）
    JL PRINT_ROW_LOOP   ; 乘数 < BX+1 则继续（即乘数 ≤ 被乘数）

    ; 5. 当前行结束，换行
    MOV DX, OFFSET CRLF
    MOV AH, 09H
    INT 21H

    ; 恢复寄存器
    POP DI              ; 弹出临时寄存器
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_ROW ENDP

CODE ENDS
END START