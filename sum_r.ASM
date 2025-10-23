; 接收用户输入a, 计算1到a的和并输出, 结果存放在寄存器BX中
DATA SEGMENT
    PROMPT  DB 'please input a number a(1~100), we will output the sum of 1 to 100: $'       ; 输入提示信息
    IN_BUF  DB 4,0,4 DUP(0)       ; 输入缓冲区: 最大长度4(3位数字+回车)、实际长度、字符存储
    STR_BUF DB 5 DUP(0)           ; 结果字符串缓冲区(最多4位数字+终止符'$')
    CRLF    DB 0Dh,0Ah,'$'        ; 回车换行符(优化输出格式)
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
START:
    MOV AX, DATA                  ; 初始化数据段寄存器
    MOV DS, AX

    ; 打印提示信息，引导用户输入
    LEA DX, PROMPT                 ; LEA: load effective address, 加载提示信息地址到DX
    MOV AH, 09h                    ; DOS功能号09h: 输出字符串
    INT 21h

    ; 接收用户输入(使用DOS功能0Ah读取字符串)
    LEA DX, IN_BUF
    MOV AH, 0Ah
    INT 21h

    ; 将输入的ASCII字符串转换为数值a(结果存到AX)
    LEA SI, IN_BUF+2              ; SI指向输入的数字字符(跳过缓冲区前2字节)
    MOV CL, IN_BUF+1              ; CL存储实际输入的数字位数
    CALL STR_TO_NUM               ; 调用字符串转数值子程序

    ; 计算1到a的和(结果存到BX)
    MOV BX, 0                     ; 初始化和为0
    MOV CX, 1                     ; 初始化计数器i=1
LOOP_START:
    CMP CX, AX                    ; 比较i与a
    JG LOOP_END                   ; 若i > a, 退出循环
    ADD BX, CX                    ; 和 += i
    INC CX                        ; i++
    JMP LOOP_START
LOOP_END:

    ; 打印换行，优化输出格式
    LEA DX, CRLF
    MOV AH, 09h
    INT 21h

    ; 将和(BX)转换为ASCII字符串(存到STR_BUF)
    LEA DI, STR_BUF
    CALL NUM_TO_STR               ; 调用数值转字符串子程序

    ; 打印计算结果
    LEA DX, STR_BUF
    MOV AH, 09h
    INT 21h

    ; 程序退出
    MOV AH, 4Ch
    INT 21h

; 子程序：字符串转数值
; 输入：SI=字符串首地址，CL=字符串长度(数字位数)
; 输出：AX=转换后的数值
STR_TO_NUM PROC
    PUSH BX                       ; 保护寄存器
    PUSH CX
    PUSH DX
    PUSH SI

    MOV AX, 0                     ; 初始化结果为0
    MOV CH, 0                     ; CX=CL(循环次数)
NEXT_DIGIT:
    MOV BL, [SI]                  ; 取当前字符
    SUB BL, '0'                   ; 转换为数字(ASCII码减'0')
    MOV BH, 0                     ; BX=当前数字
    MOV DX, 10
    MUL DX                        ; AX = 原结果 * 10
    ADD AX, BX                    ; AX = 原结果*10 + 当前数字
    INC SI                        ; 指针移向下一个字符
    LOOP NEXT_DIGIT               ; 处理所有数字

    POP SI                        ; 恢复寄存器
    POP DX
    POP CX
    POP BX
    RET
STR_TO_NUM ENDP

; 子程序：数值转字符串
; 输入：BX=待转换的数值，DI=字符串缓冲区首地址
; 输出：缓冲区存储以'$'结尾的ASCII字符串
NUM_TO_STR PROC
    PUSH AX                       ; 保护寄存器
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV SI, 0                     ; 记录数字位数
    MOV AX, BX                    ; AX暂存待转换数值
    MOV BX, 10                    ; 除数为10(十进制)

    ; 特殊处理数值为0的情况
    CMP AX, 0
    JNE NOT_ZERO
    MOV BYTE PTR [DI], '0'        ; 直接存储'0'
    INC DI
    JMP END_CONV

NOT_ZERO:
    ; 循环取余，获取每一位数字(逆序存入栈中)
DIV_LOOP:
    MOV DX, 0                     ; DX清0(扩展AX为32位被除数)
    DIV BX                        ; AX=商，DX=余数
    ADD DL, '0'                   ; 余数转换为ASCII码
    PUSH DX                       ; 数字入栈(暂存逆序)
    INC SI                        ; 位数+1
    CMP AX, 0
    JNE DIV_LOOP                  ; 商不为0则继续

    ; 出栈恢复顺序(正序存入缓冲区)
POP_LOOP:
    POP DX
    MOV BYTE PTR [DI], DL         ; 存入缓冲区
    INC DI                        ; 指针后移
    DEC SI                        ; 位数-1
    JNZ POP_LOOP                  ; 未处理完则继续

END_CONV:
    MOV BYTE PTR [DI], '$'        ; 字符串结尾添加'$'(满足DOS打印要求)

    POP SI                        ; 恢复寄存器
    POP DX
    POP CX
    POP BX
    POP AX
    RET
NUM_TO_STR ENDP

CODE ENDS
END START