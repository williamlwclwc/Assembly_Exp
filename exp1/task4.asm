.386
STACK SEGMENT USE16 STACK
      DB 200 DUP(0)
STACK ENDS
DATA  SEGMENT USE16
XUEHAO DB 10 DUP(0)
DATA  ENDS
CODE  SEGMENT USE16
      ASSUME CS:CODE,DS:DATA,SS:STACK
START: MOV AX,DATA ;初始化数据段
       MOV DS,AX  ;初始化代码段
       MOV AH,34H
       MOV XUEHAO,AH ;直接寻址
       MOV AH,33H
       MOV SI,1
       MOV XUEHAO[SI],AH ;变址寻址
       MOV AH,34H
       MOV SI,OFFSET XUEHAO
       ADD SI,2
       MOV [SI],AH ;寄存器间接寻址
       MOV AH,35H
       MOV BX,2
       MOV SI,1
       MOV XUEHAO[BX][SI],AH ;基址加变址
       MOV AH,4CH  ;返回DOS
       INT 21H
CODE   ENDS
       END START
