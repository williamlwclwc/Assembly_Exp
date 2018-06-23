.386
STACK SEGMENT USE16 STACK
      DB 200 DUP(0)
STACK ENDS
DATA SEGMENT USE16
  BNAME  DB  'LIU WENCHANG',0  ;老板姓名（必须是自己名字的拼音）
  BPASS  DB  'U201614345',0,0    ;密码
  N      EQU  40
  M      EQU  3000
  S1     DB  'SHOP1',0           ;网店名称，用0结束
  GA1    DB  'PEN', 7 DUP(0)  ; 商品名称
         DW   35,56,70,25,?  ;进货价，销售价，进货总数，已售数量,利润率
  GA2    DB  'BOOK', 6 DUP(0) ; 商品名称
         DW   12,30,25,5,?   ;进货价，销售价，进货总数，已售数量，利润率
  GA3    DB  'BAG', 7 DUP(0) ; 商品名称
         DW  12,30,3000,0,?  ;利润率还未计算
  GAN    DB  N-3 DUP('Temp-Value',15,0,20,0,30,0,2,0,?,?)
  S2     DB  'SHOP2',0           ;网店名称，用0结束
  GB1    DB  'PEN', 7 DUP(0) ; 商品名称
         DW   35,50,30,24,?   ;利润率还未计算
  GB2    DB  'BOOK', 6 DUP(0)  ; 商品名称
         DW   12,28,20,15,?  ;利润率还未计算
  GB3    DB  'BAG', 7 DUP(0) ; 商品名称
         DW  12,30,25,5,?  ;利润率还未计算
  GBN    DB  N-3 DUP('Temp-Value',15,0,20,0,30,0,2,0,?,?)
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
  TEMP1 DW 0 ;临时存SI
  TEMP2 DD ? ;进货*进货总数
  TEMP3 DD ? ;为了移位
  PR1   DW ? ;商店1的利润率
  PR2   DW ? ;商店2的利润率
  APR   DW ? ;平均利润率
  TIMER_END DB 'TIMER END$'
  TWO   DW 2
DATA ENDS
CODE SEGMENT USE16
     ASSUME CS:CODE, DS:DATA, SS:STACK
START:  MOV AX,DATA
        MOV DS,AX ;初始化段信息
        JMP USER
FAILED: LEA DX, OFFSET FAIL ;用dos系统功能调用，输出登录错误的提示信息
        MOV AH,9H
        INT 21H
        MOV DL,0AH;换行符
        MOV AH,2H
        INT 21H
        JMP USER
N_FOUND:LEA DX,OFFSET N_F
        MOV AH,9H
        INT 21H
        MOV DL,0AH;换行符
        MOV AH,2H
        INT 21H
        JMP CAL
END_T:  LEA DX, OFFSET TIMER_END
        MOV AH,9H
        INT 21H
        MOV DL,0AH;换行符
        MOV AH,2H
        INT 21H
        MOV AX,1;计时结束
        CALL TIMER
        JMP USER
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
        MOV CL , IN_NAME + 1;字符数目
        MOV CH,0
        CMP CL , 0
        JZ  CAL    ;用户只输入回车时直接进入计算功能
        CMP CL , 1
        JZ  CMP_Q    ;用户只输入1个字符时判断是否要退出
        MOV BX,0
CMP_U:  MOV DL , [BNAME + BX]
        CMP BYTE PTR [IN_NAME + BX + 2] , DL    ;若有一个字符不同，输出报错
        JNZ FAILED
        INC BX;比较下一个字符
        CMP BX , CX     ;循环比较直到当前比较的字符数与输入字符数相等为止
        JNZ CMP_U
        CMP BYTE PTR [BNAME + BX] , 0   ;比较完全部字符后看字符串中下一字符是否为0
        JNZ FAILED;如果不是0，则输出报错信息
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
CMP_P:  MOV DL,[BPASS + BX]
        CMP BYTE PTR [IN_PWD + BX + 2],DL
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
CHOOSE: MOV CX,0;用CX当做计数器
        MOV AH,AUTH;找到商品后，检测当前是否为登录状态
        CMP AUTH,1
        JZ PROFIT;登录状态则转到admin模式，否则未client模式
        MOV BX,0
        MOV TEMP1,SI;先将当前商品的地址保存起来
        MOV BP,1
        MOV AX,0;计时开始
        CALL TIMER
CLI_3:  CMP BP,M
        JGE END_T;如果循环了M次，那么返回功能一
        INC BP
        MOV SI,TEMP1;重置SI
        ADD SI,10;跳过名称
        MOV AX, WORD PTR [SI+6];AX存放已售数量
        MOV BX, WORD PTR [SI+4];BX存放进货数量
        CMP AX,BX
        JGE USER;如果已售数量大于等于进货数量，则回到功能一
        INC AX
        MOV WORD PTR [SI+6],AX;已售数量+1
        MOV CX,1;CX为0则认为处于功能四，否则计数器从1开始，更新利润率
        MOV SI, OFFSET GA1;从第一个商品开始刷新全部商品的利润率
        ADD SI,10;跳过名称
PROFIT: MOV AX, WORD PTR [SI];进货价
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
        MOV TEMP3,EBX
        SAL EBX,6;*64
        MOV EAX,EBX
        MOV EBX,TEMP3
        SAL EBX,5;*32
        ADD EAX,EBX;
        MOV EBX,TEMP3
        SAL EBX,2;*4
        ADD EAX,EBX
        CDQ
        IDIV TEMP2;计算销售价*已售数*100/进货价*进货数量，放入EAX中
        SUB AX,100;-100，计算利润率，放入AX中
        MOV PR1,AX
        ADD SI,606;找到商店2中对应的商品
        MOV AX, WORD PTR [SI];进货价
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
        MOV TEMP3,EBX
        SAL EBX,6;*64
        MOV EAX,EBX
        MOV EBX,TEMP3
        SAL EBX,5;*32
        ADD EAX,EBX;
        MOV EBX,TEMP3
        SAL EBX,2;*4
        ADD EAX,EBX
        CDQ
        IDIV TEMP2;计算销售价*已售数*100/进货价*进货数量，放入EAX中
        SUB AX,100;-100，计算利润率，放入AX中
        MOV PR2,AX
        MOV AX,PR1
        ADD AX,PR2;计算pr1+pr2
        CWD
        IDIV TWO;apr=（pr1+pr2）/2
        MOV APR,AX
        MOV WORD PTR [SI+8],AX;将计算的平均利润率放到？位置上
        CMP CX,0
        JZ GRADE;如果CX是0，那么进入功能四评级
        CMP CX,N
        JGE CLI_3;所有利润率都更新后，循环直到已售数量=进货数量
        INC CX
        ADD SI,20
        JMP PROFIT;否则计数器+1，更新下一个利润率
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
THE_END:MOV AH,4CH;返回dos
        INT 21H
;时间计数器(ms),在屏幕上显示程序的执行时间(ms)
;使用方法:
;	   MOV  AX, 0	;表示开始计时
;	   CALL TIMER
;	   ... ...	;需要计时的程序
;	   MOV  AX, 1
;	   CALL TIMER	;终止计时并显示计时结果(ms)
;输出: 改变了AX和状态寄存器
TIMER	PROC
	    PUSH  DX
        PUSH  CX
	    PUSH  BX
        MOV   BX, AX
	    MOV   AH, 2CH
        INT   21H	     ;CH=hour(0-23),CL=minute(0-59),DH=second(0-59),DL=centisecond(0-100)
	    MOV   AL, DH
        MOV   AH, 0
        IMUL  AX,AX,1000
        MOV   DH, 0
        IMUL  DX,DX,10
        ADD   AX, DX
        CMP   BX, 0
        JNZ   _T1
        MOV   CS:_TS, AX
_T0:	POP   BX
        POP   CX
        POP   DX
        RET
_T1:	SUB   AX, CS:_TS
        JNC   _T2
        ADD   AX, 60000
_T2:	MOV   CX, 0
        MOV   BX, 10
_T3:	MOV   DX, 0
        DIV   BX
        PUSH  DX
        INC   CX
        CMP   AX, 0
        JNZ   _T3
        MOV   BX, 0
_T4:	POP   AX
        ADD   AL, '0'
        MOV   CS:_TMSG[BX], AL
        INC   BX
        LOOP  _T4
        PUSH  DS
        MOV   CS:_TMSG[BX+0], 0AH
        MOV   CS:_TMSG[BX+1], 0DH
        MOV   CS:_TMSG[BX+2], '$'
        LEA   DX, _TS+2
        PUSH  CS
        POP   DS
        MOV   AH, 9
        INT   21H
        POP   DS
        JMP   _T0
_TS	DW    ?
    DB    'Time elapsed in ms is '
_TMSG	DB    12 DUP(0)
    TIMER   ENDP
CODE    ENDS
        END START
CODE ENDS
        END START
