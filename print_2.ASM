; 使用条件跳转指令

CODE SEGMENT
    ASSUME CS:CODE

START:
    MOV BH, 'a'         ; 起始字符：'a'
    MOV CX, 26          ; 总循环次数：26个字母(a~z)
    MOV BL, 0           ; 每行计数器：记录当前行已打印的字符数(0~12)

PRINT_LOOP:
    ; 打印当前字符(调用DOS功能：AH=02H,DL=字符ASCII码)
    MOV AH, 02H
    MOV DL, BH
    INT 21H

    ; 打印空格
    MOV AH, 02H
    MOV DL, ' '
    INT 21H

    INC BL              ; 每行计数器+1
    CMP BL, 13          ; 判断是否已打印13个字符
    JNE NEXT_CHAR       ; jump not equal 若不足13个,跳转到NEXT_CHAR,直接处理下一个字符

    ; 若已打印13个字符,输出换行
    MOV AH, 02H
    MOV DL, 0DH         ; 回车符(CR)
    INT 21H

    MOV AH, 02H
    MOV DL, 0AH         ; 换行符(LF)
    INT 21H

    MOV BL, 0           ; 重置每行计数器

NEXT_CHAR:
    INC BH              ; 下一个字符(如a→b)
    LOOP PRINT_LOOP     ; CX-1,若CX≠0则重复循环

    ; 程序结束,返回DOS
    MOV AH, 4CH
    INT 21H

CODE ENDS
END START