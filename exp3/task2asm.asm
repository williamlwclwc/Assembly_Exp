.386
.model small,c
ASSUME DS:_DATA
.data
RANK    DW   ?
COUNT   DW   ?
COUNT2  DW   ?
G1      DD   ?
G2      DD   ?
N       EQU  5
.stack 100
.code
public avepro
public proran

;功能模块函数
avepro  PROC GA1:dword,GB1:dword
        PUSH ESI ;现场保护
        PUSH EAX
        PUSH EBX
        PUSH ECX
        PUSH EDX
        PUSH EDI

        MOV ESI, GA1
        MOV COUNT, 0
        XUNHUAN:
        MOV  AX, [ESI][12] ;销售价
        MOV  BX, [ESI][16] ;已售数量
        MOV  CX, [ESI][10] ;进货价
        MOV  DX, [ESI][14] ;进货总数

        IMUL AX, BX ;销售价*已售数量
        IMUL CX, DX ;进货价*进货总数
        CWDE
        IMUL EAX, 100 ;（销售价*已售数量）*100
        MOV  EDX, EAX
        SAR  EDX, 16
        IDIV CX ;（销售价*已售数量)*100/（进货价*进货总数）
        SUB  AX, 100
        MOV  [ESI][18], AX

        MOV DX, 0
        MOV EDI, GB1
        NEXT3:
        MOV EBX, -1
        LOPA5:
        INC EBX
        CMP [EDI][EBX], BYTE PTR 0
        JE  FLAG41
        MOV AL, [EDI][EBX]
        CMP AL, [ESI][EBX]
        JE  LOPA5
        FLAG41:
        CMP  [EDI][EBX], BYTE PTR 0;搜到最后一个字符退出
        JNE  NEXT4
        CMP  [ESI][EBX], BYTE PTR 0;判断输入的字符串是数据段中所定义字符串的子集
        JNE  NEXT4
        JMP  FLAG6

        NEXT4:;该商品不是要查找的商品
        INC DX
        CMP DX,N
        JE  FLAG6
        ADD DI, 20
        JMP NEXT3

        FLAG6:
        MOV AX, [EDI][12] ;销售价
        MOV BX, [EDI][16] ;已售数量
        MOV CX, [EDI][10] ;进货价
        MOV DX, [EDI][14] ;进货总数

        IMUL AX, BX ;销售价*已售数量
        IMUL CX, DX ;进货价*进货总数
        CWDE
        IMUL EAX, 100 ;（销售价*已售数量）*100
        MOV  EDX, EAX
        SAR  EDX, 16
        IDIV CX ;（销售价*已售数量）*100/（进货价*进货总数）
        SUB  AX,100
        MOV  [EDI][18], AX

        ADD  AX, [ESI][18]
        SAR  AX, 1

        MOV  [ESI][18],AX;求出该商品的平均利润率并保存到SHOP1的利润率字段中

        INC COUNT
        CMP COUNT,N
        JE  NEXT5
        ADD ESI, 20
        JMP XUNHUAN

        NEXT5:
        POP EDI ;现场恢复
        POP EDX
        POP ECX
        POP EBX
        POP EAX
        POP ESI
        RET
avepro  ENDP

proran  PROC  GA1:dword,GB1:dword
        PUSH  EDX ;现场保护
        PUSH  EBX
        PUSH  EDI
        PUSH  ECX
        PUSH  EBP
        PUSH  ESI

        MOV EDX, 1
        MOV EAX, GA1
        MOV G1,EAX
        MOV EDI, GB1
        MOV G2,EDI
        MOV COUNT, N

LOPA6:
        MOV RANK, 1
        MOV ECX, G1
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
        MOV  EDI, G2
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
proran  ENDP

SEAR    PROC ;寻找商品,商品在网店1的地址存入ESI,输出的结果在EDI中
        PUSH EDX
        PUSH EBX
        PUSH EAX
        MOV EDX, 0
        NXT3:
        MOV EBX, -1
        LA5:
        INC EBX
        CMP [EDI][EBX], BYTE PTR 0
        JE  F41
        MOV AL, [EDI][EBX]
        CMP AL, [ESI][EBX]
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
end
