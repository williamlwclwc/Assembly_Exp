.386
data segment use16
cm db 4
hour db ?
data ends
stack segment use16 stack
db 200 dup(0)
stack ends
code segment use16
assume cs:code,ds:data,ss:stack
start:  mov ax,data
        mov ds,ax
        mov al,cm;cm保存cmos指令数
        out 70h,al;设定将要访问的信息是偏移值cm的信息
        jmp $+2;延时，保证端口操作的可靠性
        in al,71h;读取时信息，以压缩bcd码保存
        mov ah,al;将2位压缩bcd码转为未压缩的bcd码
        and al,0fh
        shr ah,4
        add ax,3030h;转换为对应的ASCII码
        xchg ah,al;高位放在前显示
        mov word ptr hour,ax;将访问结果放到hour中
        ;在末尾添加$使用dos9号调用输出十进制时间
        mov bx,offset hour
        add bx,2
        mov ax,'$'
        mov [bx],ax
        lea dx,hour
        mov ah,9h
        int 21h
        ;输出一个逗号，后面输出16进制的时间信息
        mov dl,','
        mov ah,2h
        int 21h
        call print16;调用输出16进制信息的子函数
        mov ah,4ch;返回dos
        int 21h
print16 proc
    call read     ;读入十进制数，结果在BX
    call f10t16   ;进行转换并输出
print16 endp
read proc
      mov bx,0
      mov si,offset hour;获取时间字符串的第一个字符地址
loopn:mov ah,0
      mov al, byte ptr[si];将当前si指向的字符读入al
      cmp ax,'$';遇到$结束读取字符串
      jz exit
      sub ax,'0';把字符转换为数字，比如'8'转换为数字8，保存在ax
      xchg bx,ax;交换ax，bx，新输入的再bx，之前的在ax
      mov cx,10
      mul cx;把之前输入的数乘以10，结果在ax.
      add bx,ax;加上新输入的，放在bx中
      inc si
      jmp loopn  ;结果在BX，继续循环
exit: ret
read endp
f10t16 proc
mov cx,4;把BX中的值按高到低先后，以4个二进制位为一个16进制数，搭配成ASCII码输出
loopc:
    rol bx,4   ;BX循环左移4个bit, 也就是把最高位的16进制数放到BL的末尾
    mov al,bl
    and al,0fh   ;把4位数放到AL
    add al,30h   ;转换为ASCII
    cmp al,'9'
    jbe print    ;字符为'9'之下，直接显示
    add al,07H   ;'9'之上的，转换为'A'-'F'
print:
    mov dl,al
    mov ah,2h
    int 21h
    dec cx
    jnz loopc
    ret
f10t16 endp
code ends
end start
