DATA SEGMENT
    ; 待校验的9×9乘法表数据
    TABLE  DB 7,2,3,4,5,6,7,8,9             ; x=1
          DB 2,4,7,8,10,12,14,16,18          ; x=2
          DB 3,6,9,12,15,18,21,24,27          ; x=3
          DB 4,8,12,16,7,24,28,32,36          ; x=4
          DB 5,10,15,20,25,30,35,40,45        ; x=5
          DB 6,12,18,24,30,7,42,48,54         ; x=6
          DB 7,14,21,28,35,42,49,56,63        ; x=7
          DB 8,16,24,32,40,48,56,7,72         ; x=8
          DB 9,18,27,36,45,54,63,72,81        ; x=9
    
    ; 输出格式：避免覆盖原字符串，改用固定格式+独立数字输出
    HEADER DB 'x  y       ',0DH,0AH,'$'       ; 表头, 0DH 0AH换行, $ 结束符
    CRLF DB 0DH,0AH,'$'                       ; 换行符 (CR+LF)
    ERR_STR DB 'error$'                       ; 错误提示字符串
    ; 单个数字输出的临时缓冲区
    NUM_BUF DB 2 DUP(?)                       ; 存1位数字的ASCII（+结束符）
DATA ENDS

CODE SEGMENT
    ASSUME DS:DATA, CS:CODE

START:
    MOV AX, DATA
    MOV DS, AX          ; 初始化数据段

    ; 输出表头
    MOV DX, OFFSET HEADER
    MOV AH, 09H
    INT 21H

    ; 外层循环：被乘数x（1~9）
    MOV CX, 9           ; 9行
    MOV SI, 0           ; TABLE偏移量
    MOV BX, 1           ; x=被乘数
CHECK_OUTER:
    ; 内层循环：乘数y（1~9）
    PUSH CX
    MOV CX, 9           ; 9列
    MOV DI, 1           ; y=乘数
CHECK_INNER:
    ; 1. 计算正确结果：x*y
    MOV AX, BX
    MUL DI              ; AX = x*y
    MOV DX, AX          ; DX=正确结果

    ; 2. 取TABLE中的数据
    MOV AL, TABLE[SI]
    CBW                 ; AL转AX
    CMP AX, DX
    JE SKIP_ERROR       ; 正确则跳过

    ; 3. 输出错误行：x → 空格 → y → 空格 → error
    ; 输出x
    MOV AX, BX
    CALL PRINT_NUM
    ; 输出空格
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    ; 输出y
    MOV AX, DI
    CALL PRINT_NUM
    ; 输出空格+error
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    MOV DX, OFFSET ERR_STR
    MOV AH, 09H
    INT 21H
    ; 换行
    MOV DX, OFFSET CRLF
    MOV AH, 09H
    INT 21H

SKIP_ERROR:
    INC SI
    INC DI
    LOOP CHECK_INNER

    POP CX
    INC BX
    LOOP CHECK_OUTER

    ; 结束程序
    MOV AH, 4CH
    INT 21H


; 功能：输出1位数字（AX=数字，1~9）
PRINT_NUM PROC
    PUSH AX
    PUSH SI

    MOV SI, OFFSET NUM_BUF
    ADD AL, '0'         ; 数字转ASCII
    MOV [SI], AL
    MOV BYTE PTR [SI+1], '$' ; 加结束符

    ; 输出数字
    MOV DX, OFFSET NUM_BUF
    MOV AH, 09H
    INT 21H

    POP SI
    POP AX
    RET
PRINT_NUM ENDP

CODE ENDS
END START