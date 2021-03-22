mov ax , 0x07c0
mov ds , ax



mov bx , data1
;0x80无符号数去比较，对于8bit的有符号数，小于0x80的为正数
;db整数的个数，存在ah中 al，dw正数的个数，存在bx中

;调整汇编地址等于ds段内偏移
mov ax , 0x07c0
mov ds, ax

;首先计算8bit数据的数量
;先计算有多少个db，在对每个db用0x80去判断
mov cx , (data2 - data1)
mov	si , data1


;ax 清0
xor ax , ax
cnt1:
	cmp byte [si] , 0x80
	inc si
	ja ng
	jb po
	
	ng:
		inc ah
		loop cnt1
	po:
		inc al
		loop cnt1
	
	
;下面计算dw的正数数量
mov cx , (tag - data2) / 2
xor ax , ax
mov si , data2
cnt2:
	cmp word [si] , 0x8000
	add si , 2
	ja popo
	jb ngng
	
popo:
	inc ah
	loop cnt2
ngng:
	inc al
	loop cnt2

jmp $	

data1 db 0x05,0xff,0x80,0xf0,0x97,0x30
data2 dw 0x90 , 0xfff0, 0xa0, 0x1235,0x2f,0xc0,0xc5bc
tag:


times 510 - ($-$$) db 0
db 0x55,0xaa