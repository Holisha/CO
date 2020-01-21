.data
msg1:.asciiz "The nearest prime number is:"
msg2:.asciiz "\nThe nearest prime number is:"
input:.asciiz "The number="
.text
.globl main

main:	
	li $v0, 4	# print
	la $a0, input
	syscall
	li $v0, 5	# read int
	syscall
	add $t4, $v0 ,$zero
	add $s1, $v0, $zero
	
	li $t7, 3	#start from 3
	
	#slt $t0, $t7, $t4	#i 3 < input
	#bne $t0, $zero,  prime
	
	bne $t4, $t7, prime		#input not equal to 3 
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
	j exit
# t0 and t4 and s1 = input	t1 TF 	t2, t3 upper bound		 t5 and t6 store the variable		t7, 3	t8, 1	t9, 2
prime:
	li $t8, 1
	li $t9, 2
	add $t0, $t4, $zero
	add $t2, $t7, $zero
	add $t3, $t7, $zero
	
ub:	#upper bound
	slt $t1, $t2, $t4	#  input < sqrt( input )^2 + c
	beq $t1, $zero, oe
	add $t2, $t2, $t3	# 2(n-1) 
	add $t2, $t2, $t3 
	add $t3, $t3, $t8
	add $t2, $t2, $t3	# 2n
	add $t2, $t2, $t3
	add $t3, $t3, $t8	# 2 (n) (n-1) > n^2 ; therefore, n+1 is the upper bound
	j ub
	
oe:	#  odd or even	X < B  
	li $t2, 3
	and $t1, $t4, $t8
	bne $t1, $zero ,tmp
	add $t4 ,$t4, $t8
	
tmp:
	beq $t4, $s1, con1
	add $t0, $t4, $zero	
	
loop1:
	slt $t1, $t2, $t3  
	beq $t1, $zero,	ansB	# i == input+c	
cmp1:
	beq $t0, $zero, con1
	slt $t1, $t0, $zero
	beq $t1, $zero, cmp2	# i +=2
	add $t2, $t2, $t9
	add $t0, $t4, $zero
	j loop1
	
cmp2:
	sub $t0, $t0, $t2
	j cmp1
		
con1:	# continue
	add $t4, $t4, $t9
	add $t0, $t4, $zero
	j loop1
		
ansB:	
	li $v0, 4
	la $a0, msg1
	syscall
	add $a0, $t4, $zero
	li $v0, 1
	syscall
	
	# X > A
	add $t4, $s1, $zero
	li $t2, 3
	slt $t1, $t3, $t4	# upper bound < input
	beq $t1, $zero ,oe2
	add $t3, $t4, $zero
	
oe2:	and $t1, $t4, $t8
	bne $t1, $zero ,temp
	sub $t4 ,$t4, $t8	#input is even

temp:
	beq $t4, $s1, con2
	add $t0, $t4, $zero
	
loop2:
	slt $t1, $t2, $t3  
	beq $t1, $zero,	ansA	# i == input - c	
	beq $t2, $t4, ansA
comp1:
	beq $t0, $zero, con2
	slt $t1, $t0, $zero
	beq $t1, $zero, comp2	# i +=2
	add $t2, $t2, $t9
	add $t0, $t4, $zero
	j loop2
	
comp2:
	sub $t0, $t0, $t2
	j comp1
		
con2:	# continue
	sub $t4, $t4, $t9
	add $t0, $t4, $zero
	j loop2
	
ansA:	
	li $v0, 4
	la $a0, msg2
	syscall
	add $a0, $t4, $zero
	li $v0, 1
	syscall

exit:
	li $v0, 10
	syscall
