# 第二次作业: 按要求打印ASCII表

## 基本要求
输出ASCII表中的小写字母部分,要求每行13个字符
1. 用loop指令实现(注意双重循环中CX值的保存和恢复)
![alt text](readme_img/image-2.png)

2. 用条件跳转指令实现

![alt text](readme_img/image-1.png)

3. 用C语言实现后查看反汇编代码并加注释

* 生成可执行代码的命令:
```shell
gcc print_3.c -o print_3.exe
```

* 生成汇编代码的命令:
```shell
gcc -S -masm=intel print_3.c -o print_3.asm
```

![alt text](readme_img/image.png)
