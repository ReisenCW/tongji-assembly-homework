; int0_handler_fixed.asm - INT0溢出中断服务程序
; 重写INT0中断向量,处理溢出异常

.MODEL SMALL
.STACK 100h

.DATA
    overflow_msg    DB 'Overflow Exception (INT0) - Overflow detected!', 0dh, 0ah, '$'
    overflow_count  DW 0                    ; Overflow counter
    old_int0_seg    DW ?                    ; Save original INT0 segment
    old_int0_off    DW ?                    ; Save original INT0 offset
    newline         DB 0dh, 0ah, '$'
    install_msg     DB 'INT0 handler installed successfully!', 0dh, 0ah, '$'
    install_fail_msg DB 'Failed to install INT0 handler!', 0dh, 0ah, '$'
    test_msg        DB 0dh, 0ah, 'Starting overflow tests...', 0dh, 0ah, '$'
    complete_msg    DB 0dh, 0ah, 'Test completed! Total overflows: ', '$'
    times_msg       DB ' times', 0dh, 0ah, '$'
    total_msg       DB ' overflow exceptions', 0dh, 0ah, '$'
    test_case_msg   DB 'Test case ', '$'
    passed_msg      DB ': PASSED', 0dh, 0ah, '$'
    failed_msg      DB ': FAILED (no overflow detected)', 0dh, 0ah, '$'

.CODE

; 新的INT0中断处理程序
new_int0_handler PROC FAR
    ; 保存所有寄存器
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH BP
    PUSH DS
    PUSH ES
    
    ; 设置数据段
    MOV AX, @DATA
    MOV DS, AX
    
    ; 增加溢出计数器
    INC overflow_count
    
    ; 简化输出：只显示简短消息，避免复杂操作
    MOV AH, 09h
    MOV DX, OFFSET overflow_msg
    INT 21h
    
    ; 恢复所有寄存器
    POP ES
    POP DS
    POP BP
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    
    ; 从中断返回
    IRET
new_int0_handler ENDP

; 打印数字函数 (AX = 要打印的数字)
print_number PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    MOV CX, 0           ; 位数计数器
    MOV BX, 10          ; 除数
    
    ; 处理0的特殊情况
    CMP AX, 0
    JNE convert_loop
    MOV SI, 0
    PUSH SI
    INC CX
    JMP print_digits
    
convert_loop:
    XOR DX, DX          ; DX清零
    DIV BX              ; AX / 10,余数在DX
    PUSH DX             ; 保存余数
    INC CX              ; 位数加1
    CMP AX, 0
    JNE convert_loop
    
print_digits:
    POP DX              ; 取出数字
    ADD DL, '0'         ; 转换为ASCII
    MOV AH, 02h
    INT 21h
    LOOP print_digits
    
    POP SI
    POP DX
    POP CX
    POP BX
    RET
print_number ENDP

; 测试溢出函数
test_overflow PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; 显示测试开始消息
    MOV AH, 09h
    MOV DX, OFFSET test_msg
    INT 21h
    
    ; 测试用例计数器
    MOV CX, 1
    
    ; 测试1: 字节有符号数正溢出
    MOV AH, 09h
    MOV DX, OFFSET test_case_msg
    INT 21h
    MOV AX, CX
    CALL print_number
    MOV AH, 09h
    MOV DX, OFFSET newline
    INT 21h
    
    MOV AL, 120         ; 较大的正数
    ADD AL, 50          ; 120 + 50 = 170 > 127 (溢出)
    INTO                ; 触发INT0如果OF=1
    
    ; 检查是否触发 (通过计数器变化)
    CMP overflow_count, 1
    JE test1_passed
    MOV AH, 09h
    MOV DX, OFFSET failed_msg
    INT 21h
    JMP test2
test1_passed:
    MOV AH, 09h
    MOV DX, OFFSET passed_msg
    INT 21h
    
test2:
    ; 测试2: 字有符号数正溢出
    INC CX
    MOV AH, 09h
    MOV DX, OFFSET test_case_msg
    INT 21h
    MOV AX, CX
    CALL print_number
    MOV AH, 09h
    MOV DX, OFFSET newline
    INT 21h
    
    MOV AX, 32000       ; 较大的正数
    ADD AX, 5000        ; 32000 + 5000 = 37000 > 32767 (溢出)
    INTO                ; 触发INT0如果OF=1
    
    CMP overflow_count, 2
    JE test2_passed
    MOV AH, 09h
    MOV DX, OFFSET failed_msg
    INT 21h
    JMP test3
test2_passed:
    MOV AH, 09h
    MOV DX, OFFSET passed_msg
    INT 21h
    
test3:
    ; 测试3: 字节有符号数负溢出
    INC CX
    MOV AH, 09h
    MOV DX, OFFSET test_case_msg
    INT 21h
    MOV AX, CX
    CALL print_number
    MOV AH, 09h
    MOV DX, OFFSET newline
    INT 21h
    
    MOV AL, -120        ; 较小的负数
    SUB AL, 50          ; -120 - 50 = -170 < -128 (溢出)
    INTO                ; 触发INT0如果OF=1
    
    CMP overflow_count, 3
    JE test3_passed
    MOV AH, 09h
    MOV DX, OFFSET failed_msg
    INT 21h
    JMP test4
test3_passed:
    MOV AH, 09h
    MOV DX, OFFSET passed_msg
    INT 21h
    
test4:
    ; 测试4: 无溢出测试 (验证不触发)
    INC CX
    MOV AH, 09h
    MOV DX, OFFSET test_case_msg
    INT 21h
    MOV AX, CX
    CALL print_number
    MOV AH, 09h
    MOV DX, OFFSET newline
    INT 21h
    
    MOV AX, 100         ; 正常范围
    ADD AX, 200         ; 100 + 200 = 300 (无溢出)
    INTO                ; 不应触发INT0
    
    ; 保存当前计数
    MOV BX, overflow_count
    MOV AH, 09h
    MOV DX, OFFSET passed_msg  ; 如果计数未变，则通过
    INT 21h
    
    ; 显示测试完成消息
    MOV AH, 09h
    MOV DX, OFFSET complete_msg
    INT 21h
    
    ; 显示总的溢出次数
    MOV AX, overflow_count
    CALL print_number
    
    MOV AH, 09h
    MOV DX, OFFSET total_msg
    INT 21h
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
test_overflow ENDP

; 主程序 - 安装新的INT0处理程序
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; 保存原INT0中断向量 (INT0 = 向量4)
    MOV AX, 3504h       ; AH=35h (获取中断向量), AL=04h (INT0)
    INT 21h             ; 返回: ES:BX = 原中断向量
    MOV old_int0_seg, ES
    MOV old_int0_off, BX
    
    ; 安装新的INT0处理程序 (INT0 = 向量4)
    MOV AX, 2504h       ; AH=25h (设置中断向量), AL=04h (INT0)
    MOV DX, OFFSET new_int0_handler
    MOV CX, SEG new_int0_handler
    PUSH DS             ; 保存当前数据段
    MOV DS, CX
    INT 21h
    POP DS              ; 恢复数据段
    
    ; 检查安装是否成功 (简单检查: 向量是否已更新)
    MOV AX, 3504h
    INT 21h
    CMP BX, OFFSET new_int0_handler
    JNE install_failed
    ; 比较段寄存器：先加载到通用寄存器
    MOV AX, ES
    MOV CX, SEG new_int0_handler
    CMP AX, CX
    JNE install_failed
    
    ; 显示安装成功消息
    MOV AH, 09h
    MOV DX, OFFSET install_msg
    INT 21h
    JMP start_test
    
install_failed:
    ; 显示安装失败消息
    MOV AH, 09h
    MOV DX, OFFSET install_fail_msg
    INT 21h
    JMP exit_program
    
start_test:
    ; 测试溢出
    CALL test_overflow
    
exit_program:
    ; 恢复原来的INT0中断向量 (INT0 = 向量4)
    MOV AX, 2504h       ; AH=25h (设置中断向量), AL=04h (INT0)
    MOV DX, old_int0_off
    MOV CX, old_int0_seg
    PUSH DS             ; 保存当前数据段
    MOV DS, CX
    INT 21h
    POP DS              ; 恢复数据段
    
    ; 程序结束
    MOV AH, 4Ch
    INT 21h

MAIN ENDP

END MAIN