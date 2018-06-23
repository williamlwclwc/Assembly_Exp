.386
STACK SEGMENT USE16 STACK
      DB 200 DUP(0)
STACK ENDS
DATA SEGMENT USE16
;对用户名密码进行简单加密
  BNAME  DB  'LIU',10 DUP(0)  ;老板姓名（必须是自己名字的拼音）
  BPASS  DB  ('3'-29H)*3 ,('4'-29H)*3, ('5'-29H)*3,9 DUP(0)    ;密码
  N      EQU  3
  S1     DB  'SHOP1',0           ;网店名称，用0结束
  GA1    DB  'PEN', 7 DUP(0)  ; 商品名称
         DW   35 XOR '^',56,70,25,?  ;进货价，销售价，进货总数，已售数量,利润率
  GA2    DB  'BOOK', 6 DUP(0) ; 商品名称
         DW   12 XOR '^',30,25,5,?   ;进货价，销售价，进货总数，已售数量，利润率
  GA3    DB  'PAPER', 5 DUP(0) ; 商品名称
         DW   20 XOR '^',30,40,30,?   ;进货价，销售价，进货总数，已售数量，利润率
  S2     DB  'SHOP2',0           ;网店名称，用0结束
  GB1    DB  'PEN', 7 DUP(0) ; 商品名称
         DW   35 XOR '^',50,30,24,?   ;利润率还未计算
  GB2    DB  'BOOK', 6 DUP(0)  ; 商品名称
         DW   12 XOR '^',28,20,15,?  ;利润率还未计算
  GB3    DB  'PAPER', 5 DUP(0) ; 商品名称
         DW   20 XOR '^',30,40,30,?   ;进货价，销售价，进货总数，已售数量，利润率
  AUTH   DB 0;判断是否为登录状态
  LOGIN_HINT DB 'HINT:PRESS ENTER TO SKIP LOGIN, PRESS q TO QUIT$'
  USERNAME  DB 'ENTER YOUR USERNAME:$'
  IN_NAME DB 13;理论上的字符串长度
          DB ?;实际上的字符串长度
          DB 13 DUP(0);申请的字符串长度即其初始化
  PASSWORD DB 'ENTER YOUR PASSWORD:$'
  IN_PWD DB 12
         DB ?
         DB 12 DUP(0)
  SUCCESS DB 'LOGIN SUCCEEDED$'
  FAIL DB 'LOGIN FAILED$'
  GOOD_HINT DB 'HINT:INPUT THE NAME OF GOODS FOR DETAILS$'
  N_F     DB 'TARGET GOOD NOT FOUND, PLEASE TRY AGAIN$'
  IN_GOOD DB 10
          DB ?
          DB 10 DUP(0)
  TEMP1 DD ? ;销售价*已售
  TEMP2 DD ? ;进货*进货总数
  PR1   DW ? ;商店1的利润率
  PR2   DW ? ;商店2的利润率
  APR   DW ? ;平均利润率
  E_T   DW 0
  ;加密用的存储区
;  P1      DW  PASS1             ;地址表（用于间接转移反跟踪）
  E1      DW  OVER
  P2      DW  PASS
  OLDINT1 DW  0,0               ;1号中断的原中断矢量（用于中断矢量表反跟踪）
  OLDINT3 DW  0,0               ;3号中断的原中断矢量

DATA ENDS
CODE SEGMENT USE16
     ASSUME CS:CODE, DS:DATA, SS:STACK
START:  MOV AX,DATA
        MOV DS,AX ;初始化段信息
        xor  ax,ax                  ;接管调试用中断，中断矢量表反跟踪
        mov  es,ax
        mov  ax,es:[1*4]            ;保存原1号和3号中断矢量
        mov  OLDINT1,ax
        mov  ax,es:[1*4+2]
        mov  OLDINT1+2,ax
        mov  ax,es:[3*4]
        mov  OLDINT3,ax
        mov  ax,es:[3*4+2]
        mov  OLDINT3+2,ax
        cli                           ;设置新的中断矢量
        mov  ax,OFFSET NEWINT
        mov  es:[1*4],ax
        mov  es:[1*4+2],cs
        mov  es:[3*4],ax
        mov  es:[3*4+2],cs
        sti
        JMP USER
FAILED: LEA DX, OFFSET FAIL ;用dos系统功能调用，输出登录错误的提示信息
        MOV AH,9H
        INT 21H
        MOV DL,0AH;换行符
        MOV AH,2H
        INT 21H
        INC E_T
        CMP E_T,3
        JZ CAL
        JMP USER
N_FOUND:LEA DX,OFFSET N_F
        MOV AH,9H
        INT 21H
        MOV DL,0AH;换行符
        MOV AH,2H
        INT 21H
        JMP CAL
CMP_Q:  LEA BP, OFFSET IN_NAME
        ADD BP,2
        CMP DS:BYTE PTR [BP],'q'
        JZ THE_END;退出，即跳转至程序结束
        JMP CMP_U;跳转至登录判定
USER:   MOV DL,0AH;换行符
        MOV AH,2H
        INT 21H
        LEA DX, OFFSET LOGIN_HINT;输出提示信息
        MOV AH,9H
        INT 21H
        MOV DL,0AH;换行符
        MOV AH,2H
        INT 21H
        LEA DX, OFFSET USERNAME;提示输入用户名
        MOV AH,9H
        INT 21H
        MOV DL,0AH;换行符
        MOV AH,2H
        INT 21H
        LEA DX, OFFSET IN_NAME;输入用户名
        MOV AH,0AH
        INT 21H
        MOV DL,0AH;换行符
        MOV AH,2H
        INT 21H
        ;计时开始
        cli                       ;计时反跟踪开始
        mov  ah,2ch
        int  21h
        push dx                   ;保存获取的秒和百分秒
        MOV CL , IN_NAME + 1;字符数目
        MOV CH,0
        CMP CL , 0
        JZ  CAL    ;用户只输入回车时直接进入计算功能
        CMP CL , 1
        JZ  CMP_Q    ;用户只输入1个字符时判断是否要退出
        ;计时结束
        mov  ah,2ch                 ;获取第二次秒与百分秒
        int  21h
        sti
        cmp  dx,[esp]               ;计时是否相同
        pop  dx
        jz   OK1                    ;如果计时相同，通过本次计时反跟踪
        jmp  OVER                  ;如果计时不同，则跳转到over
OK1:
        MOV BX,0
        cli                       ;堆栈检查反跟踪
        push  P2                  ;PASS的地址压栈
        MOV CL , IN_NAME + 1;字符数目
        MOV CH,0
CMP_U:  MOV DL , [BNAME + BX]
        CMP BYTE PTR [IN_NAME + BX + 2] , DL    ;若有一个字符不同，输出报错
        JNZ FAILED
        INC BX;比较下一个字符
        CMP BX , CX     ;循环比较直到当前比较的字符数与输入字符数相等为止
        JNZ CMP_U
        CMP BYTE PTR [BNAME + BX] , 0   ;比较完全部字符后看字符串中下一字符是否为0
        JNZ FAILED;如果不是0，则输出报错信息
        pop  ax
        mov  bx,[esp-2]           ;把栈顶上面的字（PASS的地址）取到
        sti
        jmp  bx                   ;如果被跟踪，将不会转移到PASS
        db  'i do not know！'
PASS:   LEA DX, OFFSET PASSWORD;提示输入密码
        MOV AH,9H
        INT 21H
        MOV DL,0AH;换行符
        MOV AH,2H
        INT 21H
        LEA DX, OFFSET IN_PWD;输入密码
        MOV AH,0AH
        INT 21H
        MOV DL,0AH;换行符
        MOV AH,2H
        INT 21H
        MOV CL,IN_PWD+1
        MOV CH,0
        MOV BX,0
        MOV DI,3
CMP_P:  MOVZX DX,[BPASS + BX]
        MOVZX AX,[IN_PWD+BX+2]
        SUB AX,29H
        IMUL AX,DI
        CMP AX,DX
        JNZ FAILED
        INC BX;
        CMP BX,CX;循环比较直到当前比较的字符数与输入字符数相等为止
        JNZ CMP_P
        CMP BYTE PTR [BPASS + BX],0;比较完全部字符后看字符串中下一字符是否为0
        JNZ FAILED
        MOV DL , 1
        MOV AUTH , DL;用户名密码均正确，auth赋值1，进入计算功能
        LEA DX, OFFSET SUCCESS;提示登录成功
        MOV AH,9H
        INT 21H
        MOV DL,0AH;换行符
        MOV AH,2H
        INT 21H
PASS3:  mov  bx,es:[1*4]             ;检查中断矢量表是否被调试工具阻止修改或恢复
        inc  bx
        jmp  bx                 ;正常修改了的化，这里将转移到TESTINT，否则就不知道转到哪了
        db   'Now,you see.'
CAL:    LEA DX, OFFSET GOOD_HINT;提示输入要查找的商品名称
        MOV AH,9H
        INT 21H
        MOV DL,0AH;换行符
        MOV AH,2H
        INT 21H
        LEA DX, OFFSET IN_GOOD;输入查询的商品名
        MOV AH,0AH
        INT 21H
        MOV DL,0AH;换行符
        MOV AH,2H
        INT 21H
        MOV CL,IN_GOOD+1
        MOV CH,0
        CMP CL,0
        JZ USER;只输入回车，则回到功能1
        MOV SI,OFFSET GA1
        MOV DH,0
        SUB SI,20;为了第一次调用时为0
        MOV BX,0
CMP_N:  ADD SI,20;每次调用偏移一个商品的地址
        INC DH;计数器+1
        CMP DH,N+1;如果所有的商品都找过了还没找到
        JZ  N_FOUND;输出错误信息，重新输入商品名
CMP_G:  MOV DL , [SI + BX]
        CMP BYTE PTR [IN_GOOD + BX + 2] , DL    ;若有一个字符不同，比较下一个商品
        JNZ CMP_N
        INC BX;比较下一个字符
        CMP BX , CX     ;循环比较直到当前比较的字符数与输入字符数相等为止
        JNZ CMP_G
        CMP BYTE PTR [SI + BX] , 0   ;比较完全部字符后看字符串中下一字符是否为0
        JNZ CMP_N;如果不是0，比较下一个商品
CHOOSE: MOV AH,AUTH;找到商品后，检测当前是否为登录状态
        CMP AUTH,1
        JZ ADMIN_3;登录状态则转到admin模式，否则未client模式
        MOV SI,OFFSET IN_GOOD+2
        MOV BX,0
        MOV CL , IN_GOOD + 1;获取商品名字符数目
        MOV CH,0
CLI_3:  MOV DL,BYTE PTR [SI];输出商品名称
        CMP BX, CX;循环到输出全部商品字符为止
        JZ USER;返回功能1
        MOV AH,2H;输出单个字符
        INT 21H
        INC SI;移向下一个字符
        INC BX
        JMP CLI_3
ADMIN_3:ADD SI,10;跳过名称
        MOV AX, WORD PTR [SI];进货价
        xor ax,'^'
        CWDE
        MOV EBX,EAX;将进货价放入EBX
        MOV AX, WORD PTR [SI+4];进货数量
        CWDE
        IMUL EBX,EAX;计算进货价*进货数量
        MOV TEMP2,EBX;将进货价*进货数量放入temp2变量中
        MOV AX, WORD PTR [SI+2];销售价
        CWDE
        MOV EBX,EAX;将销售价放入EBX中
        MOV AX, WORD PTR [SI+6];已售数量
        CWDE
        IMUL EBX,EAX;计算销售价*已售数量，放入EBX中
        IMUL EBX,100;乘以100
        MOV EAX,EBX
        CDQ
        IDIV TEMP2;计算销售价*已售数*100/进货价*进货数量，放入EAX中
        SUB AX,100;-100，计算利润率，放入AX中
        MOV PR1,AX
        ADD SI,66;找到商店2中对应的商品
        MOV AX, WORD PTR [SI];进货价
        xor ax,'^'
        CWDE
        MOV EBX,EAX;将进货价放入EBX
        MOV AX, WORD PTR [SI+4];进货数量
        CWDE
        IMUL EBX,EAX;计算进货价*进货数量
        MOV TEMP2,EBX;将进货价*进货数量放入temp2变量中
        MOV AX, WORD PTR [SI+2];销售价
        CWDE
        MOV EBX,EAX;将销售价放入EBX中
        MOV AX, WORD PTR [SI+6];已售数量
        CWDE
        IMUL EBX,EAX;计算销售价*已售数量，放入EBX中
        IMUL EBX,100;乘以100
        MOV EAX,EBX
        CDQ
        IDIV TEMP2;计算销售价*已售数*100/进货价*进货数量，放入EAX中
        SUB AX,100;-100，计算利润率，放入AX中
        MOV PR2,AX
        MOV AX,PR1
        ADD AX,PR2;计算pr1+pr2
        SAR AX,1;apr=（pr1+pr2）/2
        MOV APR,AX
GRADE:  CMP APR,90
        JGE A;平均利润率大于等于90，评级A
        CMP APR,50
        JGE B;平均利润率大于等于50，评级B
        CMP APR,20
        JGE _C;平均利润率大于等于20，评级C
        CMP APR,0
        JGE _D;平均利润率大于等于0，评级D
        JMP F;小于0，评级F
A:      MOV DL,'A'
        MOV AH,2
        INT 21H
        JMP C_END
B:      MOV DL,'B'
        MOV AH,2
        INT 21H
        JMP C_END
_C:     MOV DL,'C'
        MOV AH,2
        INT 21H
        JMP C_END
_D:     MOV DL,'D'
        MOV AH,2
        INT 21H
        JMP C_END
F:      MOV DL,'F'
        MOV AH,2
        INT 21H
C_END:  MOV DL,0AH;换行符
        MOV AH,2H
        INT 21H
        MOV AL,0
        MOV AUTH,AL;将登陆状态改为未登录
        JMP USER
NEWINT:  iret
TESTINT: jmp CAL

OVER:   cli                           ;还原中断矢量
        mov  ax,OLDINT1
        mov  es:[1*4],ax
        mov  ax,OLDINT1+2
        mov  es:[1*4+2],ax
        mov  ax,OLDINT3
        mov  es:[3*4],ax
        mov  ax,OLDINT3+2
        mov  es:[3*4+2],ax
        sti
THE_END:MOV AH,4CH;返回dos
        INT 21H
CODE ENDS
        END START
