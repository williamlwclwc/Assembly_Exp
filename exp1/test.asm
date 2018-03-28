;----------------------------
STACK	SEGMENT STACK
	DB	200 DUP(0)
STACK	ENDS
;----------------------------
DATA	SEGMENT
DATA	ENDS
;------------------------------
CODE SEGMENT
     ASSUME CS:CODE,DS:DATA,SS:STACK
BEGIN:	MOV AH,00110011B
	      ADD AH,01011010B
				MOV AH,-0101001B
				ADD AH,-1011101B
        MOV AH,01100101B
				ADD AH,-1011101B
;-----------------------------
CODE	ENDS
	END BEGIN
