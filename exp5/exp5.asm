.386
.model flat,stdcall
option casemap:none
WinMain proto:dword,:dword,:dword,:dword
WndProc proto:dword,:dword,:dword,:dword
Display proto:dword
include exp5.inc
include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include shell32.inc
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib shell32.lib
goods struct
gname db 10 dup(20H)
purchase dw 0 ;进货价
retail dw 0   ;销售价
stock dw 0    ;进货数量
sold dw 0     ;销售数量
apr dw 0      ;平均利润
goods ends
.data
N equ 5
COUNT dw ?
BUF1 db 10 dup(0)
s1 db 'shop1',0
s2 db 'shop2',0
classname db 'TryWinClass',0;窗口类名
appname db 'our first window',0;窗口标题
menuname db 'MyMenu',0
dlgname db 'MyDialog',0
aboutMsg db 'I am LiuWenchang from CSIE1601',0
hInstance dd 0
CommandLine dd 0
buf goods<'pen',35,56,70,25,?>
goods<'book',12,30,25,5,?>
goods<'paper',20,30,40,30,?>
goods<'pencil',8,12,40,25,?>
goods<'eraser',2,5,60,45,?>
buf2 goods<'pen',35,50,30,24,?>
goods<'book',12,28,20,15,?>
goods<'paper',20,30,40,30,?>
goods<'eraser',10,15,50,40,?>
goods<'pencil',10,15,50,40,?>
msg_name db 'name ',0
msg_pur db 'purchase     ',0
msg_ret db 'retail      ',0
msg_st db 'stock      ',0
msg_sd db 'sold     ',0
msg_apr db 'ave profit',0
.code
;主程序
start:
invoke GetModuleHandle,NULL;获得并保存本程序的句柄
mov hInstance,eax
invoke GetCommandLine
mov CommandLine,eax
invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT;调用窗口主程序
invoke ExitProcess,eax;退出本程序，返回Windows
;窗口主程序
WinMain proc hInst:dword,hPreInst:dword,CmdLine:dword,CmdShow:dword
        local wc:WNDCLASSEX;创建主窗口时所需要的信息由该结构说明
        local msg:MSG;消息结构变量用于存放获取的信息
        local hWnd:HWND;存放窗口句柄
;给WNDCLASSEX结构变量wc的各字段赋值
mov wc.cbSize,SIZEOF WNDCLASSEX;WNDCLASSEX结构类型的字节数
mov wc.style,CS_HREDRAW or CS_VREDRAW;窗口风格
mov wc.lpfnWndProc,OFFSET WndProc;本窗口过程的入口地址
mov wc.cbClsExtra,NULL;不用自定义数据则不需要OS预留空间，置NULL
mov wc.cbWndExtra,NULL;同上
push hInst;本应用程序句柄->wc.hInstance
pop wc.hInstance
mov wc.hbrBackground,COLOR_WINDOW+1;窗口的背景设为白色
mov wc.lpszMenuName,OFFSET menuname;菜单名
mov wc.lpszClassName,OFFSET classname;窗口类名
invoke LoadIcon,NULL,IDI_APPLICATION;装入系统默认图标
mov wc.hIcon,eax;保存图标的句柄
mov wc.hIconSm,0;窗口不带小图标
invoke LoadCursor,NULL,IDC_ARROW;装入系统默认的光标
mov wc.hCursor,eax;保存光标的句柄
invoke RegisterClassEx,ADDR wc;注册窗口类
invoke CreateWindowEx,NULL,ADDR classname,;建立classname类窗口
ADDR appname,;窗口标题地址
WS_OVERLAPPEDWINDOW+WS_VISIBLE,;创建可显示的窗口
CW_USEDEFAULT,CW_USEDEFAULT,;窗口左上角坐标默认值
CW_USEDEFAULT,CW_USEDEFAULT,;窗口宽度，高度默认值
NULL,NULL,;无父窗口，无菜单
hInst,NULL;本程序句柄，无参数传递给窗口
mov hWnd,eax;保存窗口的句柄
invoke ShowWindow,hWnd,SW_SHOWNORMAL
invoke UpdateWindow,hWnd
StartLoop:;进入消息循环
invoke GetMessage,ADDR msg,NULL,0,0;从windows获取消息
cmp eax,0;如果eax不为0，则转换并分发消息
je ExitLoop;如果eax为0，则转exitloop
invoke TranslateMessage,ADDR msg;从键盘接受按键并转换为消息
invoke DispatchMessage,ADDR msg;将消息分发到窗口的消息处理程序
jmp StartLoop;再循环获取消息
ExitLoop:
mov eax,msg.wParam;设置返回码
ret
WinMain endp
;窗口消息处理程序
WndProc proc hWnd:dword,uMsg:dword,wParam:dword,lParam:dword
local hdc:HDC;存放设备上下文句柄
.if uMsg==WM_DESTROY;收到的是销毁窗口信息
    invoke PostQuitMessage,NULL;发出退出消息
.elseif uMsg==WM_KEYDOWN
.if wParam==VK_F1
invoke MessageBox,hWnd,ADDR aboutMsg,ADDR appname,0
;your code
.endif
.elseif uMsg==WM_COMMAND
.if wParam==IDM_FILE_EXIT
invoke SendMessage,hWnd,WM_CLOSE,0,0
.elseif wParam==IDM_Action_Average
call Average
.elseif wParam==IDM_Action_List
invoke Display,hWnd
.elseif wParam==IDM_HELP_ABOUT
invoke MessageBox,hWnd,ADDR aboutMsg,ADDR appname,0
.endif
;.elseif uMsg==WM_PAINT
;redraw window again
.else
invoke DefWindowProc,hWnd,uMsg,wParam,lParam;不是本程序要处理的消息，作其他缺省处理
ret
.endif
mov eax,0
ret
WndProc endp
;输出信息函数
Display proc hWnd:dword
xx equ 10
yy equ 10
len_gap equ 100
wid_gap equ 30
size_of equ sizeof(goods)
local hdc:HDC
invoke GetDC,hWnd
mov hdc,eax
invoke TextOut,hdc,xx+0*len_gap,yy+0*wid_gap,OFFSET msg_name,5
invoke TextOut,hdc,xx+1*len_gap,yy+0*wid_gap,OFFSET msg_pur,13
invoke TextOut,hdc,xx+2*len_gap,yy+0*wid_gap,OFFSET msg_ret,11
invoke TextOut,hdc,xx+3*len_gap,yy+0*wid_gap,OFFSET msg_st,10
invoke TextOut,hdc,xx+4*len_gap,yy+0*wid_gap,OFFSET msg_sd,9
invoke TextOut,hdc,xx+5*len_gap,yy+0*wid_gap,OFFSET msg_apr,10
invoke TextOut,hdc,xx+0*len_gap,yy+1*wid_gap,OFFSET buf[0*20].gname,10
mov ax,buf[0*size_of].purchase
call F2T10
invoke TextOut,hdc,xx+1*len_gap,yy+1*wid_gap,OFFSET BUF1,2
mov ax,buf[0*size_of].retail
call F2T10
invoke TextOut,hdc,xx+2*len_gap,yy+1*wid_gap,OFFSET BUF1,2
mov ax,buf[0*size_of].stock
call F2T10
invoke TextOut,hdc,xx+3*len_gap,yy+1*wid_gap,OFFSET BUF1,2
mov ax,buf[0*size_of].sold
call F2T10
invoke TextOut,hdc,xx+4*len_gap,yy+1*wid_gap,OFFSET BUF1,2
mov ax,buf[0*size_of].apr
call F2T10
invoke TextOut,hdc,xx+5*len_gap,yy+1*wid_gap,OFFSET BUF1,3
invoke TextOut,hdc,xx+0*len_gap,yy+2*wid_gap,OFFSET buf[1*20].gname,10
mov ax,buf[1*size_of].purchase
call F2T10
invoke TextOut,hdc,xx+1*len_gap,yy+2*wid_gap,OFFSET BUF1,2
mov ax,buf[1*size_of].retail
call F2T10
invoke TextOut,hdc,xx+2*len_gap,yy+2*wid_gap,OFFSET BUF1,2
mov ax,buf[1*size_of].stock
call F2T10
invoke TextOut,hdc,xx+3*len_gap,yy+2*wid_gap,OFFSET BUF1,2
mov ax,buf[1*size_of].sold
call F2T10
invoke TextOut,hdc,xx+4*len_gap,yy+2*wid_gap,OFFSET BUF1,2
mov ax,buf[1*size_of].apr
call F2T10
invoke TextOut,hdc,xx+5*len_gap,yy+2*wid_gap,OFFSET BUF1,3
invoke TextOut,hdc,xx+0*len_gap,yy+3*wid_gap,OFFSET buf[2*20].gname,10
mov ax,buf[2*size_of].purchase
call F2T10
invoke TextOut,hdc,xx+1*len_gap,yy+3*wid_gap,OFFSET BUF1,2
mov ax,buf[2*size_of].retail
call F2T10
invoke TextOut,hdc,xx+2*len_gap,yy+3*wid_gap,OFFSET BUF1,2
mov ax,buf[2*size_of].stock
call F2T10
invoke TextOut,hdc,xx+3*len_gap,yy+3*wid_gap,OFFSET BUF1,2
mov ax,buf[2*size_of].sold
call F2T10
invoke TextOut,hdc,xx+4*len_gap,yy+3*wid_gap,OFFSET BUF1,2
mov ax,buf[2*size_of].apr
call F2T10
invoke TextOut,hdc,xx+5*len_gap,yy+3*wid_gap,OFFSET BUF1,2
invoke TextOut,hdc,xx+0*len_gap,yy+4*wid_gap,OFFSET buf[3*20].gname,10
mov ax,buf[3*size_of].purchase
call F2T10
invoke TextOut,hdc,xx+1*len_gap,yy+4*wid_gap,OFFSET BUF1,2
mov ax,buf[3*size_of].retail
call F2T10
invoke TextOut,hdc,xx+2*len_gap,yy+4*wid_gap,OFFSET BUF1,2
mov ax,buf[3*size_of].stock
call F2T10
invoke TextOut,hdc,xx+3*len_gap,yy+4*wid_gap,OFFSET BUF1,2
mov ax,buf[3*size_of].sold
call F2T10
invoke TextOut,hdc,xx+4*len_gap,yy+4*wid_gap,OFFSET BUF1,3
mov ax,buf[3*size_of].apr
call F2T10
invoke TextOut,hdc,xx+5*len_gap,yy+4*wid_gap,OFFSET BUF1,2
invoke TextOut,hdc,xx+0*len_gap,yy+5*wid_gap,OFFSET buf[4*20].gname,10
mov ax,buf[4*size_of].purchase
call F2T10
invoke TextOut,hdc,xx+1*len_gap,yy+5*wid_gap,OFFSET BUF1,2
mov ax,buf[4*size_of].retail
call F2T10
invoke TextOut,hdc,xx+2*len_gap,yy+5*wid_gap,OFFSET BUF1,2
mov ax,buf[4*size_of].stock
call F2T10
invoke TextOut,hdc,xx+3*len_gap,yy+5*wid_gap,OFFSET BUF1,2
mov ax,buf[4*size_of].sold
call F2T10
invoke TextOut,hdc,xx+4*len_gap,yy+5*wid_gap,OFFSET BUF1,2
mov ax,buf[4*size_of].apr
call F2T10
invoke TextOut,hdc,xx+5*len_gap,yy+5*wid_gap,OFFSET BUF1,2
ret
Display endp
;计算平均函数
Average proc
pusha
MOV ESI, offset buf
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
MOV EDX, 0
MOV EDI, offset buf2
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
INC EDX
CMP EDX,N
JE  FLAG6
ADD EDI, 20
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
JE  avr_finish
ADD ESI, 20
JMP XUNHUAN
avr_finish:
popa
ret
Average endp
;函数F2T10，将二进制的数转换成10进制的ASCII码
;函数输入参数：通过AX传递，引用是应把要转换的参数放进AX中
;函数输出为转换之后的字符串，放在变量BUF1之中（以'$'结尾）
F2T10   PROC
        PUSH EBX     ;保护现场
        PUSH ECX
        PUSH EDX
        PUSH ESI
        MOV BX , 10 ;等会BX作为被除数（因为是要转化成10进制）
        MOV ECX , 0  ;计数器清零
        LEA ESI , BUF1    ;将BUF1的地址给SI，等会通过变址寻址把相应的数据放在BUF1中
        OR  AX , AX     ;AX为正数是直接进入后面的转换
        JNS LOP1
        NEG AX          ;AX为负数时先转变成正数
        MOV BYTE PTR [ESI],'-'   ;此时应该先存放一个负号
        INC ESI
LOP1:   XOR DX , DX   ;通过异或将DX清零，这种清零方式应该更快一些（可以试着验证一下）
        DIV BX         ;除10取余，二进制转化为10进制的正常操作
        PUSH DX        ;将余数进栈（因为顺序是反的，第一个余数应该是转换后的进制的最后一位，此时进行一次进出栈转换顺序）
        INC CX
        OR  AX , AX     ;AX为0时跳出循环
        JNZ LOP1
LOP2:   POP AX         ;将之前的余数出栈
        ADD AL , 30H   ;将余数加30H变成相应的ASCII码
        MOV [ESI],AL     ;将余数出栈
        INC ESI
        LOOP LOP2   ;计数器减一并且判断是否跳出循环
        MOV BYTE PTR [ESI],' '   ;在存放空间的最后加入一个字符串结束符，方便等会字符串的输出
        POP ESI      ;保护现场
        POP EDX
        POP ECX
        POP EBX
        RET
F2T10   ENDP
end start
