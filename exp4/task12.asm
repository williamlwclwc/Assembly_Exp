.386
code segment use16
assume cs:code
start:  mov ax,0
        mov ds,ax
        mov ah,35h
        mov al,1h
        int 21h
        mov al,10h
        int 21h
        mov ah,4ch
        int 21h
code ends
end start
