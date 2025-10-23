# 第一次作业:helloworld

## 作业要求
1. 传统方式:源代码->汇编->链接(会用debug -u反汇编查看机器码和源代码之间的关系),提交源代码和exe文件
2. 另类方式:直接将代码和数据用debug -e写到内存中去执行,提交文档。

## 传统方式
编写完源代码后通过MASM汇编生成OBJ文件,然后通过LINK链接生成EXE可执行文件,最终执行生成的EXE文件,输出"Hello, World!"字符串.

![alt text](readme_img/image.png)

使用debug -u 反汇编查看机器码和源代码之间的关系:

![alt text](readme_img/image-1.png)

## 另类方式
debug所有指令：
| 命令 | 全称 / 形式 | 说明                                                             | 示例                  |
| ---- | ----------- | ---------------------------------------------------------------- | --------------------- |
| r    | registers   | 显示或修改寄存器（AX,BX,CX,DX,SP,BP,SI,DI,CS,DS,ES,SS,IP,FLAGS） | r AX BX               |
| u    | unassemble  | 反汇编内存或段中的指令                                           | u 100 12F             |
| t    | trace       | 单步执行一条指令（会进入调用）                                   | t                     |
| p    | proceed     | 单步执行并跳过调用（执行子过程后返回）                           | p                     |
| g    | go          | 运行到指定地址或直到断点                                         | g 100                 |
| e    | enter       | 向内存写入字节或字符串（用于写入代码/数据）                      | e 100 "Hello, World!" |
| d    | dump        | 以十六进制和 ASCII 显示内存内容                                  | d 100 11F             |
| s    | search      | 在内存中搜索字节或字符串                                         | s 100 200 "Hello"     |
| a    | assemble    | 从指定地址开始汇编输入机器指令                                   | a 100                 |

直接将代码和数据用debug -e写到内存中去执行,输出"Hello, World!"字符串.

![alt text](readme_img/image-2.png)

![alt text](readme_img/image-3.png)