#define _CRT_SECURE_NO_WARNINGS
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

struct goods {
	char goods_name[10];//商品名
	short purchase;//进货价
	short retail;//销售价
	short p_num;//进货总数
	short r_num;//销售总数
	short pro;//利润率
};

void search_goods(struct goods *g);
void edit_goods(struct goods *g);
extern void avepro(char*ga1,char*gb1);
extern void proran(char*ga1,char*gb1);
void print(struct goods *g);

int main()
{
	struct goods g[10];
	//初始化10个商品
	strcpy(g[0].goods_name, "PEN");
	g[0].purchase = 35;
	g[0].retail = 56;
	g[0].p_num = 70;
	g[0].r_num = 25;

	strcpy(g[1].goods_name, "BOOK");
	g[1].purchase = 12;
	g[1].retail = 30;
	g[1].p_num = 25;
	g[1].r_num = 5;

	strcpy(g[2].goods_name, "PAPER");
	g[2].purchase = 20;
	g[2].retail = 30;
	g[2].p_num = 40;
	g[2].r_num = 30;

	strcpy(g[3].goods_name, "PENCIL");
	g[3].purchase = 8;
	g[3].retail = 12;
	g[3].p_num = 40;
	g[3].r_num = 25;

	strcpy(g[4].goods_name, "ERASER");
	g[4].purchase = 2;
	g[4].retail = 5;
	g[4].p_num = 60;
	g[4].r_num = 45;

	strcpy(g[5].goods_name, "PEN");
	g[5].purchase = 35;
	g[5].retail = 50;
	g[5].p_num = 30;
	g[5].r_num = 24;

	strcpy(g[6].goods_name, "BOOK");
	g[6].purchase = 12;
	g[6].retail = 28;
	g[6].p_num = 20;
	g[6].r_num = 15;

	strcpy(g[7].goods_name, "PAPER");
	g[7].purchase = 20;
	g[7].retail = 30;
	g[7].p_num = 40;
	g[7].r_num = 30;

	strcpy(g[8].goods_name, "ERASER");
	g[8].purchase = 5;
	g[8].retail = 10;
	g[8].p_num = 35;
	g[8].r_num = 30;

	strcpy(g[9].goods_name, "PENCIL");
	g[9].purchase = 10;
	g[9].retail = 15;
	g[9].p_num = 50;
	g[9].r_num = 40;

	int auth = 0, choice = 0;//用户登录状态和用户输入的菜单选择
	char username[20];//输入用户名
	char password[20];//输入密码
	printf("Welcome to use this program\n---------------------------------------------------\n");
	while (1)
	{
		printf("enter your username:");
		gets(username);
		if (strcmp(username, "LIU WENCHANG")==0)
		{
			break;
		}
		else if (strcmp(username, "") == 0)
		{
			goto inx;
		}
		else
		{
			printf("username error\n");
		}
	}
	while (1)
	{
		printf("enter your password:");
		scanf("%s", password);
		if (strcmp(password, "U201614345") == 0)
		{
			auth = 1;//登录成功
			break;
		}
		else
		{
			printf("password error\n");
		}
	}
	inx:
	while (choice != 6)
	{
		system("cls");	printf("\n\n");
		printf("1=SEARCH GOODS\n");
		if (auth == 1)
		{
			//登录状态显示2-5
			printf("2=EDIT GOODS\n");
			printf("3=CALCULATE AVERAGE PROFIT\n");
			printf("4=APR RANKING\n");
			printf("5=OUTPUT ALL GOODS\n");
		}
		printf("6=EXIT PROGRAM\n");
		printf("select your command:");
		scanf("%d", &choice);
		switch (choice)
		{
		case 1:
			search_goods(g);//查询商品
			printf("press enter to continue\n");
			getchar(); //getchar();
			break;
		case 2:
			if (auth == 0)
			{
				printf("input error, please reselect your command\n");
			}
			else if (auth == 1)
			{
				edit_goods(g);//修改商品信息
			}
			printf("press enter to continue\n");
			getchar(); getchar();
			break;
		case 3:
			if (auth == 0)
			{
				printf("input error, please reselect your command\n");
			}
			else if (auth == 1)
			{
				avepro(g[0].goods_name,g[5].goods_name);//计算平均利润率
			}
			printf("press enter to continue\n");
			getchar(); getchar();
			break;
		case 4:
			if (auth == 0)
			{
				printf("input error, please reselect your command\n");
			}
			else if (auth == 1)
			{
				proran(g[0].goods_name,g[5].goods_name);//计算利润率排名
			}
			printf("press enter to continue\n");
			getchar(); getchar();
			break;
		case 5:
			if (auth == 0)
			{
				printf("input error, please reselect your command\n");
			}
			else if (auth == 1)
			{
				print(g);//输出商品利润及排名信息
			}
			printf("press enter to continue\n");
			getchar(); getchar();
			break;
		case 6:
			printf("thanks for using the program\n");
			getchar(); getchar();
			break;
		default:
			printf("input error, please reselect your command\n");
			printf("press enter to continue\n");
			getchar(); getchar();
		}
	}
}

void search_goods(struct goods *g)
{
	char str[20];
	int flag = 0;
	while (1)
	{
		printf("please input target goods:\n");
		getchar();
		gets(str);
		if (strcmp(str, "") == 0)
		{
			return;
		}
		for (int i = 0; i < 5; i++)
		{
			//shop1中寻找
			if (strcmp(str, g[i].goods_name) == 0)
			{
				printf("shop1\n");
				printf("商品名称：%s,销售价：%d,进货总数：%d,已售数量：%d\n", g[i].goods_name, g[i].retail, g[i].p_num, g[i].r_num);
				flag = 1;
			}
		}
		if (flag == 1)
		{
			break;
		}
	}
	for (int i = 5; i < 10; i++)
	{
		//shop2中寻找
		if (strcmp(str, g[i].goods_name) == 0)
		{
			printf("shop2\n");
			printf("商品名称：%s,销售价：%d,进货总数：%d,已售数量：%d\n", g[i].goods_name, g[i].retail, g[i].p_num, g[i].r_num);
		}
	}
}

void edit_goods(struct goods *g)
{
	char str1[10], str2[10], input[10], temp[10];
	int s_flag = 0,start,end,re=-1,index;
	short edit;
iny:
	while (s_flag != 1 && s_flag != 2)
	{
		printf("input target shop:(shop1/shop2):\n");
		getchar();
		gets(str1);
		if (strcmp(str1, "shop1") == 0)
		{
			s_flag = 1;
		}
		else if (strcmp(str1, "shop2") == 0)
		{
			s_flag = 2;
		}
		else if (strcmp(str1, "") == 0)
		{
			return;
		}
	}
	printf("input target goods:\n");
	gets(str2);
	if (strcmp(str2, "") == 0)
	{
		return;
	}
	if (s_flag == 1)
	{
		start = 0; end = 5;
	}
	else
	{
		start = 5; end = 10;
	}
	for (int i = start; i < end; i++)
	{
		if (strcmp(str2, g[i].goods_name) == 0)
		{
			re = i;//找到目标商品
			break;
		}
	}
	if (re == -1)
	{
		goto iny;//未找到商品则重新输入商店和商品名
	}
	printf("press N to skip\n");
	index = 0;
	while (index == 0)
	{
		printf("进货价：%d>>",g[re].purchase);
		scanf("%s", input);
		edit = atoi(input);
		_itoa(edit, temp, 10);
		if (strlen(input) != strlen(temp))
		{
			index = 0;
			edit = g[re].purchase;
		}
		else
		{
			index = 1;
		}
		if(strcmp(input,"N")==0)
		{
			edit = g[re].purchase;
			break;
		}
		if (edit < 0)
		{
			index = 0;
		}
	}
	g[re].purchase = edit;
	index = 0;
	while (index == 0)
	{
		printf("销售价：%d>>",g[re].retail);
		scanf("%s", input);
		edit = atoi(input);
		_itoa(edit, temp, 10);
		if (strlen(input) != strlen(temp))
		{
			index = 0;
			edit = g[re].retail;
		}
		else
		{
			index = 1;
		}
		if (strcmp(input, "N") == 0)
		{
			edit = g[re].retail;
			break;
		}
		if (edit < 0)
		{
			index = 0;
		}
	}
	g[re].retail = edit;
	index = 0;
	while (index == 0)
	{
		printf("进货总数：%d>>",g[re].p_num);
		scanf("%s", input);
		edit = atoi(input);
		_itoa(edit, temp, 10);
		if (strlen(input) != strlen(temp))
		{
			index = 0;
			edit = g[re].p_num;
		}
		else
		{
			index = 1;
		}
		if (strcmp(input, "N") == 0)
		{
			edit = g[re].p_num;
			break;
		}
		if (edit < 0)
		{
			index = 0;
		}
	}
	g[re].p_num = edit;
}

void print(struct goods *g)
{
	printf("%-30s%-30s%-30s\n","Goods","Apr","Rank");
	for (int i = 0; i < 5; i++)
	{
		printf("%-30s%-30d", g[i].goods_name, g[i].pro);
		for (int j = 5; j < 10; j++)
		{
			if (strcmp(g[i].goods_name, g[j].goods_name) == 0)
			{
				printf("%-30d\n", g[j].pro);
			}
		}
	}
}