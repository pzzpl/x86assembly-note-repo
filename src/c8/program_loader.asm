;下面语句不占空间
app_lba_start equ 100 ; 用户程序存在100号逻辑扇区

section mbr align=16 vstart=0x7c00 ; 为了方便

	xor ax , ax ; 这里是设置加载器的堆栈段 和 栈顶指针
	mov ss , ax 
	mov sp , ax
	
	
	;设置 计算目的内存的ds段地址
	mov ax , [cs:phy_base];一共4个B 要用16bit除法
	mov dx , [cs:phy_base + 2] ;高16bit
	mov bx , 16
	div bx
	mov ds , ax
	mov es , ax 
	
	;另外一种写法 等价12~17行 右移4bit ==== 除以16
	;mov ax , [cs:phy_base];一共4个B 要用16bit除法
	;mov dx , [cs:phy_base + 2] ;高16bit
	;shl ax , 4
	;ror dx ,4
	;and  dx , 0xf000 
	;or ax , dx
	;mov ds , ax 
	;mov es , ax
	
	;下面为设置参数 di+si  bx  
	;调用过程read_hard_disk_0
	xor di , di
	mov si , app_lba_start ; 100号逻辑扇区
	xor bx , bx ; ds : bx 
	call read_hard_disk_0 ;相对过程调用
	
	
	;下面通过分析用户程序头部
	;1.要知道究竟用户程序有多大
	;2.要知道程序入口地址
	;3.要重定位，因为用户程序头部的都是汇编地址，对于代码段，要计算其段地址 数据段要计算ds的段地址
	;栈要计算栈的段地址
	mov dx,[0]
	mov ax ,[2]
	mov bx , 512
	div bx
	cmp dx, 0
	;因为余数要占一个扇区，而头表页算一个山区
	;即系通过判断余数，来觉得读取的扇区数是否要减一
	jnz @1
	dec ax ; 余数为0就要减去1，不为0什么也不用做
@1:
	cmp ax , 0 ; 如果用户程序大小为0 就不用下面的操作
	jz direct  
	
	mov cx , ax
	push ds ; 保存当前调用者的ds ，因为下面要改变ds
	
	
	
	;di+si为产数即系LBA28的值
	
@2:
	;每次都一个扇区，ds的值+0x20
	mov ax , ds
	add ax , 0x20 ;即系加上512字节，得到新的数据段地址
	mov ds , ax
	
	;bx为基址寻址，即系目标内存的位置
	xor bx , bx
	inc si ; si刚才已经为100 ，di全部是0
	call read_hard_disk_0
	loop @2
	
	
	pop ds ;对应上面 
	
	
	;下面为所有用户程序都已经都到0x10000的内存地址
	;接下来要做的是重定位程序头表的入口地址和重定位表的各个地址
	;他们本来是汇编地址，我们要逐个计算其段地址
direct: 
	;计算入口地址
	mov dx , [0x08] ;此时 ds的值为0x1000 ，左移4bit+0x08即系头表的入口代码段汇编地址
	mov ax  , [0x06]
	call calc_segment_base
	mov [0x06] , ax
	
	;下面计算重定位表的地址  
	
	mov cx , [0x0a] ; 重定位表的表项数
	mov bx ,  0x0c ; 即系重定位表表头地址 ds:bx
	
realloc:
	mov dx , [bx + 0x02];重定位表，每一行大小为4字节
	mov ax , [bx]
	call calc_segment_base
	mov [bx] , ax
	add bx , 4
	loop realloc
	
	
	jmp far [0x04] ; ds:0x04内存双字单元，存储着ip和cs，（实质是用户程序头的程序入口地址)




;-----------------------------一下是读磁盘一个扇区的过程
;都磁盘的规则
;先告诉驱动要都的逻辑扇区号
;用28bit的二进制表示
;最高4位为设置模式


;di+si 存储起始逻辑扇区号
;ds:bx 为目的内存逻辑地址
;0x1f2端口 为读取几个逻辑扇区
;0x1f3 0x1f4 0x1f5 0x1f6 为32位，第28bit存储逻辑扇区号 高4位为mode设置
;0x1f7 为读命令  还是 写命令 都命令则往0x1f7写入0x20
;32bit的十六进制是：e0 00 00 00 64
;这里约定 过程调用 通过 di+si 传递 逻辑扇区号
;用ds：bx 指定目的内存地址
;用in ax , bdx 读16bit的端口
;用in al , imm8/dx  读取一个字节的端口
;用out dx , ax 写16位 端口
;用out dx , al 写8bit端口

;最后监听0x1f7其位控制端口，也为状态端口
;0x1f0为数据端口
read_hard_disk_0:
	;常规操作，保存主要寄存器，保证调用程序能够恢复执行
	push ax
	push bx
	push cx
	push dx
	;设置读取的扇区数量
	mov dx , 0x1f2
	mov al , 1 ; 这里要都1个
	out dx , al ; 用out输出一个字节到端口0x1f2 ，意味着一次IO最多读取255个扇区
	
	inc dx  ;写下一个端口 填LBA28 0x1f3
	mov ax ,si
	out dx , al
	
	inc dx  ; 0x1f4
	out dx , ah
	
	inc dx  ; 0x1f5
	mov ax , di
	out dx , al
	
	inc dx 
	mov al 0xe0 ; mode 和LBA28剩下的4位为0 高4位mode为e
	or al , ah ; LBA高4位，防止有漏的位，这里其实没有用，因为这4bit为0
	out dx , al
	
	
.wait:
	in al , dx
	and al , 0x88 ; 最高位要为0 第4位要为1
	cmp  al , 0x08
	jnz .wait ; 这里用jne也可以 jnz就是不为0
	
	;来到这里就是可以读磁盘， 读到ds:bx
	; 首先要读取 512B /  2B = 2 ^8 = 256
	mov cx 256
	mov dx , 0x1f0 ; 设置数据端口
.readw:
	in ax ,dx
	mov [ds:bx] , ax
	add bx , 2
	loop .readw
	
	pop dx 
	pop cx 
	pop bx
	pop ax
	
	ret ; ret指令讲压在栈帧底的调用者的下一条指令的地址恢复到cs和ip 同一个段内
;-------------------------------
calc_segment_base:
	push dx 
	
	add ax , [cs:phy_base]
	adc dx , [cs:phy_base+0x02]
	shr ax , 4
	ror dx , 4
	and dx , 0xf000
	or ax, dx 
	
	pop dx
	
	ret
	
	pop dx
	
phy_base dd 0x10000 ; 指定用户程序加载到的内存地址


times 510 - ($ - $$ ) db 0
db 0x55 , 0xaa