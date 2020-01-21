.data
msgb:.asciiz"The GCD is:"
inputa:.asciiz "The first number="
inputb:.asciiz "The second number="
.text
.globl main
main:
	#$a0-$a3=引數(argument)暫存器
	#$v0-$v1=數值(value)暫存器
	#$t0-t9=整數(integer)暫存器
	
	#輸入兩自然數求最大公因數
	#讀第一個數到t1
	li $v0,4	        # load syscall code (4 : print string) 
	la $a0,inputa 		# load address of string to be printed into $a0 
	syscall			# print str 
	li $v0,5		# load syscall code (5 : read int)
	syscall			# read int 
	add $t1,$zero,$v0
	#讀第二個數到t2 
	li $v0,4
	la $a0,inputb
	syscall
	li $v0,5
	syscall
	add $t2,$zero,$v0
	#比對 t1 t2 大小，若t1大則做減法，若t1較小則與t2做對調 
comp:	slt $t0,$t1,$t2		#判斷t1<t2 成立t1=1 else t1=0
	beq $t0,$zero,subb	#如果相等跳到subb(標籤)
	add $t3,$t1,$zero
	add $t1,$t2,$zero
	add $t2,$t3,$zero
subb:	sub $t1,$t1,$t2
	bne $t1,$zero,comp
	#顯示最大公因數 
	li $v0,4
	la $a0,msgb
	syscall
	add $a0,$zero $t2
	li $v0,1
	syscall
	li $v0,10
	syscall
