.data
inputa: 	.asciiz "Please enter a number : "
msg1:	.asciiz "Nearest prime number is : " 
msg2:	.asciiz "\nNearest prime number is : "
.text
.globl main
main:
	li $v0, 4
	la $a0, inputa
	syscall
	li $v0, 5
	syscall
	add $t0, $zero, $v0
	
	li $t7, 3
	bne $t7, $t0, next   #special case: 3
	li $v0, 4
	la $a0, msg1
	syscall
	li $a0, 5
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, msg2
	syscall
	li $a0, 2
	li $v0, 1
	syscall
	j end
	
next:	li $t8, 1
	li $t9, 2
	
	add $t3, $zero, $t7  
  	add $t4, $zero, $t7
limit:	slt $t2, $t3, $t0     #t3 is the limit number
	beq $t2, $zero, temp
	add $t3, $t3, $t4
	add $t3, $t3, $t4
	add $t4, $t4, $t8
	add $t3, $t3, $t4
	add $t3, $t3, $t4
	add $t4, $t4, $t8
	j limit	
	
temp:	add $t3, $t4, $zero
	
	#X<A
	and $t2, $t0, $t8
	add $t1, $t0, $zero
	bne $t2, $zero, comp
	sub $t1, $t1, $t8
comp:	add $t1, $t1, $t9
	li $t4, 3
comp1:	slt $t2, $t4, $t3
	beq $t2, $zero, ans
	add $t5, $t1, $zero
	add $s1, $t4, $t4
	add $s1, $s1, $s1
	#sub $t5, $t1, $t4
comp2:	sub $t5, $t5, $s1
	#sub $t5, $t5, $t4
	#sub $t5, $t5, $t4
	#sub $t5, $t5, $t4
	slt $t2, $t4, $t5
	bne $t2, $zero, comp2 
	beq $t5, $t4, comp
	add $t5, $t5, $t4
	beq $t5, $zero, comp
	add $t4, $t4, $t9
	j comp1
ans:	li $v0, 4
	la $a0, msg1
	syscall
	add $a0, $zero, $t1
	li $v0, 1
	syscall
	#X>B
	and $t2, $t0, $t8        #determine whether the number is odd
	add $t1, $t0, $zero
	bne $t2, $zero, compB
	add $t1, $t0, $t8
compB:	sub $t1, $t1, $t9
	li $t4, 3
comp1B:	slt $t2, $t4, $t3
	beq $t2, $zero, ansB
	add $t5, $t1, $zero
	#sub $t5, $t1, $t4
comp2B:	sub $t5, $t5, $t4
	sub $t5, $t5, $t4
	sub $t5, $t5, $t4
	sub $t5, $t5, $t4
	slt $t2, $t4, $t5
	bne $t2, $zero, comp2B 
	beq $t5, $t4, compB
	add $t5, $t5, $t4
	beq $t5, $zero, compB
	add $t4, $t4, $t9
	j comp1B
ansB:	li $v0, 4
	la $a0, msg2
	syscall
	add $a0, $zero, $t1
	li $v0, 1
	syscall
end:	li $v0, 10
	syscall