;part1编写者：刘文长 同组：倪向敏
NAME 3-PART1
EXTRN part2:FAR
.386
CRLF MACRO ;换行符
     MOV DL,0AH;换行符
     MOV AH,2H
     INT 21H
     MOV DL,0DH;换行符
     MOV AH,2H
     INT 21H
     ENDM
SEP  MACRO ;输入分隔符>
     MOV DL,'>'
     MOV AH,2H
     INT 21H
     ENDM
OUTSTRING MACRO OUT;九号调用输出$结尾的字符串
      LEA DX, OUT
      MOV AH,9H
      INT 21H
      ENDM
OUTC  MACRO A;输出数字,数字放在si中
      MOV AX,WORD PTR [A]
      CALL F2T10
      OUTSTRING BUF
      ENDM
INSTRING MACRO IN;十号调用，输入一个字符串
      LEA DX, IN;输入用户名
      MOV AH,0AH
      INT 21H
      ENDM
INCHAR MACRO MARK,MARK2;输入数字，合法则修改data中的值
      ;输入一个数字，如果非法，则返回mark处，如果回车则不做更改，正确则更改data
      INSTRING IN_EDIT;读入一个字符串
      CRLF
      LEA DI,IN_EDIT+2
      MOVSX CX,IN_EDIT+1
      CMP CX,0;直接输入回车
      JZ MARK2;不修改直接过
      CALL F10T2
      CMP DI,-1;判断是否合法
      JZ MARK;不合法则返回mark
      MOV WORD PTR [SI],AX;合法则修改
      ENDM
STACK SEGMENT USE16 STACK
      DB 200 DUP(0)
STACK ENDS
DATA SEGMENT USE16
  BNAME  DB  'LIU WENCHANG',0  ;老板姓名（必须是自己名字的拼音）
  BPASS  DB  'U201614345',0,0    ;密码
  N      EQU  3
  S1     DB  'SHOP1',0           ;网店名称，用0结束
  GA1    DB  'PEN', 7 DUP(0)  ; 商品名称
         DW   35,56,70,25,?  ;进货价，销售价，进货总数，已售数量,利润率
  GA2    DB  'BOOK', 6 DUP(0) ; 商品名称
         DW   12,30,25,5,?   ;进货价，销售价，进货总数，已售数量，利润率
  GA3    DB  'PAPER', 5 DUP(0) ; 商品名称
         DW   20,30,40,30,?   ;进货价，销售价，进货总数，已售数量，利润率
  S2     DB  'SHOP2',0           ;网店名称，用0结束
  GB1    DB  'PEN', 7 DUP(0) ; 商品名称
         DW   35,50,30,24,?   ;利润率还未计算
  GB2    DB  'BOOK', 6 DUP(0)  ; 商品名称
         DW   12,28,20,15,?  ;利润率还未计算
  GB3    DB  'PAPER', 5 DUP(0) ; 商品名称
         DW   20,30,40,30,?   ;进货价，销售价，进货总数，已售数量，利润率
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
  N_F     DB 'TARGET GOOD NOT FOUND, PLEASE TRY AGAIN$'
  IN_GOOD DB 10
          DB ?
          DB 10 DUP(0)
  MENU1 DB '1=SEARCH GOODS$';查询商品信息
  MENU2 DB '2=EDIT GOODS$';修改商品信息
  MENU3 DB '3=CALCULATE AVERAGE PROFIT$';计算平均利润率
  MENU4 DB '4=APR RANKING$';计算利润率排名
  MENU5 DB '5=OUTPUT ALL GOODS$';输出全部商品信息
  MENU6 DB '6=EXIT PROGRAM$';程序退出
  MENU_HINT DB 'SELECT YOUR COMMAND(1-6):$'
  IN_MENU DB 5
          DB ?
          DB 5 DUP(0)
  SHOP_HINT DB 'SELECT YOUR SHOP(1:SHOP1;2:SHOP2;ENTER:RET TO MENU):$'
  CHOOSE_GOODS DB 'INPUT THE NAME OF YOUR TARGET GOODS:$'
  IN_SHOP DB 10
          DB ?
          DB 10 DUP(0)
  INFO1 DB 'PURCHASE PRICE:$'
  INFO2 DB 'RETAIL PRICE:$'
  INFO3 DB 'STOCK QUANTITY:$'
  IN_EDIT DB 10
          DB ?
          DB 10 DUP(0)
  BUF DB ?
DATA ENDS
CODE SEGMENT USE16
     ASSUME CS:CODE, DS:DATA, SS:STACK
;输出以0结尾的字符串
;入口参数：将要输出的字符串的首地址放在DI中
OUTS0 PROC
      MOV BX,0
      OUT_S: MOV DL,[DI+BX]
      CMP DL,0;如果当前字符为0，则结束
      JZ OUT_END
      MOV AH,2H;否则输出当前字符，bx指针+1
      INT 21H
      INC BX
      JMP OUT_S
      OUT_END:
      RET
OUTS0 ENDP
;寻找输入的商品的偏移地址，结果放到SI中
SEARCH_G PROC
        OUTSTRING CHOOSE_GOODS;提示输入要查找的商品名称
        CRLF
        INSTRING IN_GOOD;输入查询的商品名
        CRLF
        MOV CL,IN_GOOD+1
        MOV CH,0
        CMP CL,0
        JZ MENU;只输入回车，则回到功能3(1)
        MOV SI,OFFSET GA1
        MOV DH,0
        SUB SI,20;为了第一次调用时为0
        MOV BX,0
CMP_N:  ADD SI,20;每次调用偏移一个商品的地址
        INC DH;计数器+1
        CMP DH,N+1;如果所有的商品都找过了还没找
        JZ  N_FOUND;输出错误信息，重新输入商品名
CMP_G:  MOV DL , [SI + BX]
        CMP BYTE PTR [IN_GOOD + BX + 2] , DL    ;若有一个字符不同，比较下一个商品
        JNZ CMP_N
        INC BX;比较下一个字符
        CMP BX , CX     ;循环比较直到当前比较的字符数与输入字符数相等为止
        JNZ CMP_G
        CMP BYTE PTR [SI + BX] , 0   ;比较完全部字符后看字符串中下一字符是否为0
        JNZ CMP_N;如果不是0，比较下一个商品
        RET
SEARCH_G ENDP
;修改信息子程序：入口参数：商品名称偏移地址SI,BX存放shop的选择
EDIT PROC
     PUSH SI;保护现场
     MOV SI,0;计数器清零
     CALL SEARCH_G
     ADD SI,12
     CMP BX,'1'
     JZ I1
     ADD SI,66;如果是shop2，加66
I1:  OUTSTRING INFO1
     OUTC SI
     SEP
     INCHAR I1,I11
I11: ADD SI,2
     CRLF
I2:  OUTSTRING INFO2
     OUTC SI
     SEP
     INCHAR I2,I22
I22: ADD SI,2
     CRLF
I3:  OUTSTRING INFO3
     OUTC SI
     SEP
     INCHAR I3,I4
     CRLF
I4:  POP SI;恢复现场
     RET
EDIT ENDP;出口参数为
;函数F2T10，将二进制的数转换成10进制的ASCII码
;函数输入参数：通过AX传递，引用是应把要转换的参数放进AX中
;函数输出为转换之后的字符串，放在变量BUF之中（以'$'结尾）
F2T10   PROC
        PUSH BX     ;保护现场
        PUSH CX
        PUSH DX
        PUSH SI
        MOV BX , 10 ;等会BX作为被除数（因为是要转化成10进制）
        MOV CX , 0  ;计数器清零
        LEA SI , BUF    ;将BUF的地址给SI，等会通过变址寻址把相应的数据放在BUF中
        OR  AX , AX     ;AX为正数是直接进入后面的转换
        JNS LOP1
        NEG AX          ;AX为负数时先转变成正数
        MOV BYTE PTR [SI],'-'   ;此时应该先存放一个负号
        INC SI
LOP1:   XOR DX , DX   ;通过异或将DX清零，这种清零方式应该更快一些（可以试着验证一下）
        DIV BX         ;除10取余，二进制转化为10进制的正常操作
        PUSH DX        ;将余数进栈（因为顺序是反的，第一个余数应该是转换后的进制的最后一位，此时进行一次进出栈转换顺序）
        INC CX
        OR  AX , AX     ;AX为0时跳出循环
        JNZ LOP1
LOP2:   POP AX         ;将之前的余数出栈
        ADD AL , 30H   ;将余数加30H变成相应的ASCII码
        MOV [SI],AL     ;将余数出栈
        INC SI
        LOOP LOP2   ;计数器减一并且判断是否跳出循环
        MOV BYTE PTR [SI],'$'   ;在存放空间的最后加入一个字符串结束符，方便等会字符串的输出
        POP SI      ;保护现场
        POP DX
        POP CX
        POP BX
        RET
F2T10   ENDP
;函数F10T2，将以DI为指针的字节存储区中的十进制数字转换成二进制数送入AX/EAX之中
;入口参数：DI，指向待转换数的存储区首址，cx存放十进制数字串的长度
;出口参数：DI当其值为-1时表示转换出现错误，结果放在ax中，ebx用来存放当前正被转换的数字
F10T2   PROC
        PUSH EBX;保护现场
        MOV EAX,0
        MOV BL,[DI]
        CMP BL,'0';首个数字不能是0
        JZ  ERR
        DEC DI
NEXT1:  INC DI
        MOV BL,[DI];取DI指向的字符
NEXT2:  CMP BL,'0'
        JB  ERR
        CMP BL,'9'
        JA  ERR
        SUB BL,30H
        MOVZX EBX,BL
        IMUL EAX,10;计算EAX*10+EBX->EAX，若溢出或超过范围转错误处理
        JO  ERR
        ADD EAX,EBX
        JO  ERR
        JS  ERR
        JC  ERR
        DEC CX
        JNZ NEXT1
        CMP EAX,7FFFH;转换结果是否超过16位，二进制有符号数能表示的范围
        JA  ERR
QQ:     POP EBX;恢复现场
        RET
ERR:    MOV DI,-1
        JMP QQ
F10T2   ENDP
START:  MOV AX,DATA
        MOV DS,AX ;初始化段信息
        JMP USER
FAILED: OUTSTRING FAIL;用dos系统功能调用，输出登录错误的提示信息
        CRLF;换行符
        JMP USER
N_FOUND:OUTSTRING N_F
        CRLF
        JMP SEAR_G
CMP_Q:  LEA BP, OFFSET IN_NAME
        ADD BP,2
        CMP DS:BYTE PTR [BP],'q'
        JZ THE_END;退出，即跳转至程序结束
        JMP CMP_U;跳转至登录判定
CMP_M:  LEA BP, IN_MENU+2;得到实际输入字符串
        CMP DS:BYTE PTR [BP],'1'
        JZ SEAR_G
        CMP DS:BYTE PTR [BP],'2'
        JZ EDIT_G
        CMP DS:BYTE PTR [BP],'3'
        JZ CAL_APR
        CMP DS:BYTE PTR [BP],'4'
        JZ APR_RANK
        CMP DS:BYTE PTR [BP],'5'
        JZ OUT_ALL
        CMP DS:BYTE PTR [BP],'6'
        JZ THE_END
        JMP MENU;输入错误则返回menu
USER:   CRLF
        OUTSTRING LOGIN_HINT;输出提示信息
        CRLF
        OUTSTRING USERNAME;提示输入用户名
        CRLF
        INSTRING IN_NAME;输入用户名
        CRLF
        MOV CL , IN_NAME + 1;字符数目
        MOV CH,0
        CMP CL , 0
        JZ  MENU    ;用户只输入回车时直接进入功能3
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
PASS:   OUTSTRING PASSWORD;提示输入密码
        CRLF
        INSTRING IN_PWD;输入密码
        CRLF
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
        OUTSTRING SUCCESS;提示登录成功
        CRLF
MENU:   OUTSTRING MENU1;输出菜单字符串
        CRLF
        CMP AUTH,0
        JZ MENU66;如果未登录，不输出2~5功能的菜单
        OUTSTRING MENU2
        CRLF
        OUTSTRING MENU3
        CRLF
        OUTSTRING MENU4
        CRLF
        OUTSTRING MENU5
        CRLF
MENU66: OUTSTRING MENU6
        CRLF
        OUTSTRING MENU_HINT
CHOOSE: INSTRING IN_MENU
        CRLF
        MOV CL , IN_MENU+ 1;字符数目
        MOV CH,0
        CMP CL , 0
        JZ  MENU    ;用户只输入回车时直接进入计算功能
        CMP CL , 1
        JZ  CMP_M    ;用户只输入1个字符时判断1-6功能
SEAR_G: CALL SEARCH_G
        LEA DI,S1
        CALL OUTS0 ;输出shop1，商品名，销售价，进货数，已售数
        CRLF
        MOV DI,SI
        CALL OUTS0
        CRLF
        OUTC SI+12
        CRLF
        OUTC SI+14
        CRLF
        OUTC SI+16
        CRLF
        LEA DI,S2
        CALL OUTS0 ;输出shop2，商品名，销售价，进货数，已售数
        CRLF
        ADD SI,66
        MOV DI,SI
        CALL OUTS0
        CRLF
        OUTC SI+12
        CRLF
        OUTC SI+14
        CRLF
        OUTC SI+16
        CRLF
        JMP MENU
EDIT_G: OUTSTRING SHOP_HINT
        CRLF
        INSTRING IN_SHOP;指定商店
        CRLF
        MOVSX CX,IN_SHOP+1
        CMP CX,0;直接输入回车
        JZ MENU;没有找到的话要求重新输入
        CMP CX,1
        JNZ EDIT_G
        LEA DI, IN_SHOP+2
        MOV BX,[DI]
        CALL EDIT;调用修改子程序，得到出口参数，根据出口参数进行下一步跳转
        JMP MENU;直接回车和修改完成后均回到菜单
CAL_APR:JMP MENU
APR_RANK:JMP MENU
OUT_ALL:JMP MENU
THE_END:MOV AH,4CH;返回dos
        INT 21H
CODE ENDS
        END START
