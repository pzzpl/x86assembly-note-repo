;用字符串存储字符
;输出到显存
;求1~100的累积
;输出到显存
	jmp start
tips: db '1+2+3+.....+100 = '

start:
	;先另汇编地址和段内偏移相同
	mov ax , 0x07c0
	mov ds , ax
	;令es指向显存
	mov ax , 0xb800
	mov es , ax
	
	
	
	;下面为显示1+..+100
	;先计算db有多小个字符
	mov cx , start - tips
	mov si , tips ; 源数据从这个偏移开始
	mov di , 0
	
showlable:
	mov al , [ds:si]
	inc si
	mov [es:di] , al
	mov byte [es:di+1] ,0x04 ; 显示属性
	add di , 2
	loop showlable
	
;下面位计算1~100累积
	mov cx , 100
	xor ax , ax
accu:
	add ax, cx
	loop accu
;下面为分解累加和的数位
;用栈
	mov bx , 10
	xor cx , cx;设置栈顶指针 和 栈段寄存器
	mov sp , cx
	mov sp , cx
	;循环在商为0时结束
resolve:	
	inc cx ; cx记录栈中元素个数
	xor dx , dx
	div bx
	;余数在dx
	or dl , 0x30
	push dx
	cmp ax , 0 ; 商为0 则停止循环
	jne resolve
	
;下面为显示结果
popstk:
	pop dx
	mov [es:di]  ,dx
	mov byte [es:di +1] , 0x04
	add di , 2
	loop popstk
	
	jmp $


	times 510 - ($ - $$) db 0
	db 0x55 , 0xaa

	