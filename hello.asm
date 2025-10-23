mySEG SEGMENT              ; 定义一个段，名称为mySEG
    MSG DB "Hello, World!$" ; 要显示的字符串，以$结尾（DOS要求）
mySEG ENDS

ASSUME CS:mySEG           ; 告诉汇编器CS段寄存器使用mySEG

mySEG SEGMENT
my:                       ; 程序入口标签
    MOV AX, mySEG         ; 将段地址加载到AX       *AX = mySEG
    MOV DS, AX            ; 设置数据段寄存器DS指向mySEG     *DS = *AX

    LEA DX, MSG           ; 将MSG的偏移地址加载到DX       LOAD指令     DX = &MSG
    MOV AH, 09H           ; DOS功能号09H：显示字符串
    INT 21H               ; 调用DOS中断，显示字符串

    MOV AX, 4C00H         ; DOS功能号4CH：程序返回，AL=返回码0
    INT 21H               ; 调用DOS中断，返回操作系统

mySEG ENDS
END my                    ; 程序入口为my