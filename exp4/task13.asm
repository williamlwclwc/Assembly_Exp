.386
code segment use16
assume cs:code
start:  mov ax,0
        mov ds,ax
        ;01h
        mov bx,word ptr ds:[4h]
        mov cx,word ptr ds:[6h]
        ;10h
        mov bx,word ptr ds:[40h]
        mov cx,word ptr ds:[42h]
        mov ah,4ch
        int 21h
code ends
end start
