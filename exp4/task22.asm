.386
code segment use16
assume cs:code,ss:stack
start:  mov ax,0
        mov ds,ax;0->ds
        ;通过td观察之前的程序，记录下原中断程序的入口地址
        mov ax,01e0h
        mov bx,0f100h
        ;将16号中断的位置改回原来的中断程序入口
        cli
        mov word ptr ds:[16h*4],ax
        mov ds:[16h*4+2],bx
        sti
        mov ah,4ch;返回dos
        int 21h
code ends
stack segment use16 stack
db 200 dup(0)
stack ends
end start
