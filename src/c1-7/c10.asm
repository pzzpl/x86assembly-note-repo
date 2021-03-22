
mov ax ,0xb800
mov es , ax


mov ax , 1000
mov bx , 100

cmp ax,bx
jg lbb

cmp ax,bx
je lbz

cmp ax,bx 
jl lbl





lbb:
	mov byte [es:0] ,'>'
	mov byte [es:1] ,0x04
	jmp end
lbz:
	mov byte [es:0] ,'='
	mov byte [es:1] ,0x04
	jmp end
lbl:
	mov byte [es:0] ,'<'
	mov byte [es:1] ,0x04
	jmp end
	
	
end :
	jmp $
times 510 - ($ - $$) db 0
db 0x55,0xaa