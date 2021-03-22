	jmp start
data1 dw 8


start:
	mov  ax, 0x07c0
	mov ds , ax
	mov dx , [ds:data1]
	neg dx
	
	jmp $
current:
	times 510 - (current - $$) db 0
	db 0x55 , 0xaa