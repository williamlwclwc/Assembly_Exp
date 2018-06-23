;part2编写者：倪向敏 同组：刘文长
EXTRN  GA1:BYTE,GB1:BYTE
PUBLIC AVEPRO,PRORAN,PRINT,SEAR


WRITE   MACRO A
        LEA   DX, A
        MOV   AH, 9
        INT   21H
        ENDM
SCANF   MACRO B
        LEA   DX, B
        MOV   AH, 10
        INT   21H
        ENDM
GETCHAR MACRO
        MOV  AH,1
        INT  21H
        ENDM

.386
STACK   SEGMENT USE16 STACK
        DB 200 DUP(0)
STACK   ENDS
DATA    SEGMENT USE16 PARA PUBLIC 'D1'
RANK    DW   ?
COUNT   DW   ?
COUNT2  DW   ?
N       EQU  5
BUF     DB   12 DUP(?)
BUF10   DB   'Product      Profit      Rank$'
BUF11   DB   '   $'
BUF12   DB   'Press any key to continue!$'
CRLF    DB   0DH,0AH,'$'
DATA    ENDS
CODE    SEGMENT USE16 PARA PUBLIC 'CODE'
ASSUME  CS:CODE, DS:DATA, SS:STACK
START:  MOV AX, DATA
        MOV DS, AX

        AVEPRO  PROC NEAR
                PUSH SI ;现场保护
                PUSH EAX
                PUSH BX
                PUSH CX
                PUSH DX
                PUSH DI

                MOV SI, OFFSET GA1
                MOV COUNT, 0
                XUNHUAN:
                MOV  AX, [SI][12] ;销售价
                MOV  BX, [SI][16] ;已售数量
                MOV  CX, [SI][10] ;进货价
                MOV  DX, [SI][14] ;进货总数

                IMUL AX, BX ;销售价*已售数量
                IMUL CX, DX ;进货价*进货总数
                CWDE
                IMUL EAX, 100 ;（销售价*已售数量）*100
                MOV  EDX, EAX
                SAR  EDX, 16
                IDIV CX ;（销售价*已售数量)*100/（进货价*进货总数）
                SUB  AX, 100
                MOV  [SI][18], AX


                MOV DX, 0
                MOV DI, OFFSET GB1
                NEXT3:
                MOV BX, -1
                LOPA5:
                INC BX
                CMP [DI][BX], BYTE PTR 0
                JE  FLAG41
                MOV AL, [DI][BX]
                CMP AL, [SI][BX]
                JE  LOPA5
                FLAG41:
                CMP  [DI][BX], BYTE PTR 0;搜到最后一个字符退出
                JNE  NEXT4
                CMP  [SI][BX], BYTE PTR 0;判断输入的字符串是数据段中所定义字符串的子集
                JNE  NEXT4
                JMP  FLAG6

                NEXT4:;该商品不是要查找的商品
                INC DX
                CMP DX,N
                JE  FLAG6
                ADD DI, 20
                JMP NEXT3

                FLAG6:
                MOV AX, [DI][12] ;销售价
                MOV BX, [DI][16] ;已售数量
                MOV CX, [DI][10] ;进货价
                MOV DX, [DI][14] ;进货总数

                IMUL AX, BX ;销售价*已售数量
                IMUL CX, DX ;进货价*进货总数
                CWDE
                IMUL EAX, 100 ;（销售价*已售数量）*100
                MOV  EDX, EAX
                SAR  EDX, 16
                IDIV CX ;（销售价*已售数量）*100/（进货价*进货总数）
                SUB  AX,100
                MOV  [DI][18], AX

                ADD  AX, [SI][18]
                SAR  AX, 1

                MOV  [SI][18],AX;求出该商品的平均利润率并保存到SHOP1的利润率字段中

                INC COUNT
                CMP COUNT,N
                JE  NEXT5
                ADD SI, 20
                JMP XUNHUAN

                NEXT5:
                POP DI ;现场恢复
                POP DX
                POP CX
                POP BX
                POP EAX
                POP SI
                RET
        AVEPRO  ENDP


        PRORAN  PROC  NEAR
                PUSH  EDX ;现场保护
                PUSH  EBX
                PUSH  EDI
                PUSH  ECX
                PUSH  EBP
                PUSH  ESI

                MOV EDX, 1
                MOV EAX, OFFSET GA1
                MOV COUNT, N

        LOPA6:
                MOV RANK, 1
                MOV ECX, OFFSET GA1
                MOV COUNT2, N
                MOVSX ESI,WORD PTR [EAX+18]
                LOPA7:
                MOVSX EBP,WORD PTR[ECX+18]
                CMP ESI, EBP
                JGE  LAST
                INC RANK

                LAST: ;当次内层遍历结束，判断继续遍历还是退出
                DEC COUNT2
                JE  ENDLP7
                ADD ECX, 20
                JMP LOPA7

                ENDLP7: ;内层遍历结束
                PUSH ESI
                MOV  ESI, EAX
                CALL SEAR
                POP  ESI
                MOV  BP, RANK
                MOV [EDI+18], BP

                DEC COUNT
                JE  ENDLESS
                ADD EAX, 20
                JMP LOPA6

        ENDLESS:
                POP   ESI  ;现场恢复
                POP   EBP
                POP   ECX
                POP   EDI
                POP   EBX
                POP   EDX
                RET
        PRORAN  ENDP


        PRINT PROC  NEAR
              PUSH  EDX ;现场保护
              PUSH  EBX
              PUSH  EDI
              PUSH  ECX
              PUSH  EBP
              PUSH  ESI

              WRITE BUF10
              WRITE CRLF
              MOV BP, 1  ;用EBP存放当前要输出的排名的商品名次
        LPA:  MOV COUNT2, N
              MOV ESI, OFFSET GA1
              LPB:
              CALL SEAR
              CMP [EDI+18], BP
              JE  SHUCHU
              JMP LASTB
              SHUCHU:
              CALL PSTR ;输出商品名称
              WRITE BUF11
              CMP [ESI+18], WORD PTR 0
              JL KONG
              MOV  DL, 20H
              MOV  AH, 2
              INT  21H
              KONG:
              MOV AX, [ESI+18]  ;输出商品平均利润
              MOV  DX, 16
              CALL F2T10
              MOV  DL, 25H
              MOV  AH, 2
              INT  21H
              WRITE BUF11
              WRITE BUF11
              WRITE BUF11
              MOV AX,BP ;输出排名
              MOV DX, 16
              CALL F2T10
              WRITE CRLF

        LASTB:
              DEC COUNT2
              JE  LPBEND
              ADD ESI, 20
              JMP LPB

        LPBEND:
              INC BP
              CMP BP, N
              JA  LPAEND
              JMP LPA

        LPAEND:
              POP   ESI  ;现场恢复
              POP   EBP
              POP   ECX
              POP   EDI
              POP   EBX
              POP   EDX
              WRITE BUF12
              GETCHAR
              RET
        PRINT ENDP









        F2T10 PROC  NEAR
              PUSH  EBX  ;现场保护
              PUSH  SI
              LEA   SI, BUF
              CMP   DX, 32           ;判断是对EAX还是对AX中的数进行操作
              JE    B                ;若对EAX中的数进行操作转B
              MOVSX EAX, AX          ;对AX扩展为32位
        B:    OR    EAX, EAX
              JNS   PLUS
              NEG   EAX                 ;如果EAX<0，添上负号，SI的内容增1
              MOV   BYTE PTR [SI],'-'
              INC   SI
        PLUS: MOV   EBX, 10
              CALL  RADIX              ;调用RADIX子程序将EAX转换为十进制

              MOV   BYTE PTR [SI],'$' ;显示转换后的十进制数
              WRITE BUF
              POP   SI    ;恢复现场
              POP   EBX
              RET
        F2T10 ENDP


        RADIX  PROC   NEAR
               PUSH   CX   ;现场保护
               PUSH   EDX
               XOR    CX, CX  ;计数器清零
        LOP1:  XOR    EDX, EDX
               DIV    EBX
               PUSH   DX
               INC    CX
               OR     EAX, EAX
               JNZ    LOP1
        LOP2:  POP    AX
               CMP    AL, 10
               JB     L1
               ADD    AL, 7
        L1:    ADD    AL, 30H
               MOV    [SI], AL
               INC    SI ;将指针指向下一个单元
               LOOP   LOP2
               POP    EDX ;现场恢复
               POP    CX
               RET
        RADIX  ENDP

        PSTR   PROC  NEAR;输出字符串
               PUSH  AX ;现场保护
               PUSH  DX
               PUSH  ESI
               MOV   COUNT,0
        LO1:   CMP   COUNT,10
               JE    ENDL1
               MOV   DL, [ESI]
               MOV   AH,2
               INT   21H
               INC   ESI
               INC   COUNT
               JMP   LO1

        ENDL1: POP   ESI;现场恢复
               POP   DX
               POP   AX
               RET
        PSTR   ENDP

        SEAR    PROC ;寻找商品,商品在网店1的地址存入ESI,输出的结果在EDI中
                PUSH EDX
                PUSH EBX
                PUSH EAX
                MOV EDX, 0
                MOV EDI, OFFSET GB1
                NXT3:
                MOV EBX, -1
                LA5:
                INC EBX
                CMP [EDI][EBX], BYTE PTR 0
                JE  F41
                MOV AL, [DI][BX]
                CMP AL, [SI][BX]
                JE  LA5
                F41:
                CMP  [EDI][EBX], BYTE PTR 0;搜到最后一个字符退出
                JNE  NXT4
                CMP  [ESI][EBX],  BYTE PTR 0;判断输入的字符串是数据段中所定义字符串的子集
                JNE  NXT4
                JMP  F6

                NXT4:;该商品不是要查找的商品
                INC EDX
                CMP EDX,N
                JE  F6
                ADD EDI, 20
                JMP NXT3

                F6:
                POP  EAX
                POP  EBX
                POP  EDX
                RET
        SEAR    ENDP
CODE ENDS
        END START
