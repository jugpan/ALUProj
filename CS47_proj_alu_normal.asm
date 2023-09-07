.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:
	beq $a2, '+', addition   #Branch onto the respective part of code after 
	beq $a2, '-', subtraction#matching the operator
	beq $a2, '*', multiplication
	beq $a2, '/', division
	
addition: 
	add $v0, $a0, $a1
	jr $ra
	
subtraction: 
	sub $v0, $a0, $a1
	jr $ra
	
multiplication: 
	mult $a0, $a1
	mfhi $v1
	mflo $v0
	jr $ra
	
division: 
	div $a0, $a1
	mfhi $v1
	mflo $v0
	jr	$ra
