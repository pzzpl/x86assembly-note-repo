section s1 
offset dw str1,str2,num

section s2 align=16 vstart=0
str1 db 'hello'
str2 db 'world'

section s3 align=16
num dw 0x0020


jmp $

times 510 - ($-$$) db 0
db 0x55,0xaa