start:
	;显示65535到屏幕
	;首先将65535分解，在加0x30 编程ascii码，再传到显存
	;分解要使用16bit除法 ，被除数放在 DX AX 高16bit在dx，底16bit在ax。 除数放在BX 结果上 商在AX 余数在dX
	;mov ax , 0xffff
	mov ax , here
	xor dx , dx ;将dx清0
	mov bx ,10
	div bx  ; dx ax 除以 bx 结果 商在ax 余数在dX
	
	add dl,0x30 ; 编程ascii码，
	mov [0x7c00 + numbers + 0] , dl
	
	xor dx , dx
	div bx
	add dl , 0x30
	mov [0x7c00 + numbers + 1] , dl
	
	xor dx  , dx
	div bx
	add dl ,0x30
	mov [0x7c00 + numbers + 2] ,dl 
	
	xor dx , dx
	div bx
	add dl , 0x30
	mov [0x7c00 + numbers + 3] , dl
	
	xor dx , dx
	div bx
	add dl , 0x30
	mov [0x7c00 + numbers + 4] , dl
	
	;下面为写到显存
	mov ax , 0xb800
	mov es , ax
	mov al , [0x7c00 + numbers + 4] 
	mov [es:0x0] ,al
	mov byte [es:0x1], 0x04
	
	
	mov al , [0x7c00 + numbers + 3] 
	mov [es:0x2] ,al
	mov byte [es:0x3] ,0x04
	
	
	mov al , [0x7c00 + numbers + 2] 
	mov [es:0x4], al
	mov byte [es:0x5], 0x04
	
	
	mov al , [0x7c00 + numbers + 1] 
	mov [es:0x6], al
	mov byte [es:0x7] ,0x04
	
	
	mov al , [0x7c00 + numbers + 0] 
	mov [es:0x8] ,al
	mov byte [es:0x9], 0x04
	
	
	
	
here : jmp near here
	
	
numbers: db 0 ,0 ,0 ,0,0

current:
	times 510 - (current - start)  db 0
	db 0x55,0xaa