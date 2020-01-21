.data
.text
.globl main
main:
	li $v0, 5
	syscall
	add $a0, $v0, $zero
	add $v0, $zero, $zero
sum:	slti $t0, $a0, 1
	beq  $t0, $zero, L1
	addi $v0, $v0, 1
	jr   $ra	
L1:	addi $sp, $sp, -8
	sw   $ra, 4($sp)
	sw   $a0, 0($sp)
	addi $a0, $a0, -1
	jal  sum
	lw   $a0, 0($sp)
	lw   $ra, 4($sp)
	addi $sp, $sp, 8
	add  $v0, $v0, $a0
	jr   $ra
	add  $v1, $v0, $zero
	li   $v0, 10
	syscall