CODE SEGMENT
    ASSUME CS:CODE

START:
    MOV BL, 'a'         ; 起始字符:'a'(ASCII 61H)

    ; 外层循环:控制行数(共2行)
    MOV CX, 2           ; 外层循环次数=2
OUTER_LOOP:
    PUSH CX             ; 保存外层循环计数器(避免被内层循环覆盖)

    ; 内层循环:控制每行字符数(13个)
    MOV CX, 13          ; 内层循环次数=13
INNER_LOOP:
    ; 打印当前字符(DOS功能:AH=02H)
    MOV AH, 02H
    MOV DL, BL
    INT 21H

    MOV AH, 02H
    MOV DL, ' '         ; 打印空格
    INT 21H

    INC BL              ; 字符递增
    LOOP INNER_LOOP     ; 内层循环:13次后结束

    POP CX              ; 恢复外层循环计数器
CHECK_NEWLINE:
    ; 打印回车+换行
    MOV AH, 02H
    MOV DL, 0DH         ; 回车
    INT 21H

    MOV DL, 0AH         ; 换行
    INT 21H

    LOOP OUTER_LOOP     ; 外层循环:2次后结束

    ; 程序退出
    MOV AH, 4CH
    INT 21H

CODE ENDS
END START