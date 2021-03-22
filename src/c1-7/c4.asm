		jmp start
txt: 
		db  'l' ,0x04 ,'a' ,0x04,'b',0x04, 'e' ,0x04,'l' ,0x04,'a' ,0x04, \
			'd' ,0x04,'d',0x04, 'r' ,0x04,'e',0x04, 's' ,0x04,'s',0x04, ':',0x04
		
start :
		;初始化 es 和ds 的值 使用 movsw传送串到 显存
		mov ax , 0x07c0
		mov ds , ax 
		
		mov ax , 0xb800
		mov es , ax
		
		;初始化 si 和 di 的值 设置flags的df位的方向为从小到大
		; 初始化cx 作为rep的次数
		;xor si , si 
		mov si , txt
		xor di , di
		
		cld  ; dz -> 0
		
		mov cx , (start - txt) / 2
		
		rep movsw 
		
		;下面要显示 一个标识（汇编地址）的值 在屏幕上
		;先将数值 传到ax寄存器保存
		;将数值分解 存到buff
		;再把buff中的数据加上属性 ，传输到显存
		mov ax , buff
		;下面使用16bit除法指令分解ax . 16bit 除法 ：被除数由dx ax 组成  结果商在ax 余数在 dx
		xor dx , dx ; 将dx清0
		mov cx , 5
		mov bx , 10 ; 除数设在bx
		mov si , buff 
digit:
		div bx ; 先执行除法
		mov [si] , dl ; 把余数放进去 
		xor dx , dx 
		inc si
		loop digit
		
		mov cx , 5
show:    ; 将buff中的数据显示到显存
		dec si
		mov al , [si]
		add al , 0x30
		mov ah , 0x04 ; 组建一个字符
		mov [es : di ] , ax ; 传送到显存
		add di , 2
		loop show
		
		
buff: db 0,0,0,0,0
		
		jmp $ 
		
		times 510 - ($ - $$) db 0
		db 0x55 , 0xaa
		
		
		
		
