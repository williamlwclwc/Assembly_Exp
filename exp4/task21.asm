.386
code segment use16
assume cs:code,ss:stack
pre16h dw ?,?
;new16h为扩充的新功能
new16h: cmp ah,00h
        jz s1
        cmp ah,10h
        jz s1
        jmp dword ptr cs:pre16h
s1:     pushf;使用第一种接管扩充功能的方法
        call dword ptr cs:pre16h
        cmp al,'a';大于a继续与z比较，否则退出
        jae cmp2
        jmp quit
cmp2:   cmp al,'z';小于z继续，否则退出
        jbe next
        jmp quit
next:   sub al,32;小写转大写
quit:   iret
        ;jmp dword ptr cs:pre16h;不能使用第二种方法，因为要先调用原中断再执行新功能
start:  mov ax,0
        mov ds,ax;0->ds
        ;保留老的中断处理程序入口地址
        mov ax,ds:[16h*4]
        mov cs:pre16h,ax;保存偏移地址
        mov ax,ds:[16h*4+2]
        mov cs:pre16h+2,ax;保存段值
        ;设置新的中断处理入口
        cli
        mov word ptr ds:[16h*4],offset new16h
        mov ds:[16h*4+2],cs
        sti
        ;不允许被打断
        mov dx,offset start+15;计算中断处理程序占的字节数
        shr dx,4
        add dx,10h;n=start地址，(n+15)/10h+10h
        mov al,0;这里开始为驻存在内存的dos31号调用
        mov ah,31h
        int 21h
code ends
stack segment use16 stack
db 200 dup(0)
stack ends
end start
