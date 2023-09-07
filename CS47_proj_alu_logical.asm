.include "./cs47_proj_macro.asm"
.data
addition: .word 0x00000000
subtraction: .word 0xFFFFFFFF
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
	addi $sp, $sp, -28   #FRAME SAVE
	sw $a0, 28($sp)
	sw $a1, 24($sp)
	sw $a2,20($sp)
	sw $a3, 16($sp)
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 28
	
	beq $a2, '+', logical_addition
	beq $a2, '-', logical_subtraction
	beq $a2, '*', logical_multiplication
	beq $a2, '/' ,logical_division


	
logical_addition:
	addi $sp, $sp, -28  #FRAME SAVE
	sw $a0, 28($sp)
	sw $a1, 24($sp)
	sw $a2, 20($sp)
	sw $a3, 16($sp)
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 28
	
	lw $a2, addition #$a2 will be loaded with all 0s for addition
	jal addition_or_subtraction
	j exit
	
logical_subtraction:
	addi $sp, $sp, -28 #FRAME SAVE
	sw $a0, 28($sp)
	sw $a1, 24($sp)
	sw $a2, 20($sp)
	sw $a3, 16($sp)
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 28
	
	lw $a2, subtraction #a2 will be loaded with all 1s for subtraction
	jal addition_or_subtraction
	j exit
	
addition_or_subtraction:
	addi $sp, $sp, -28 #FRAME SAVE
	sw $a0, 28($sp)
	sw $a1, 24($sp)
	sw $a2, 20($sp)
	sw $a3, 16($sp)
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 28
	
	li $t0, 0  #$t0 will act as counter
	li $t1, 32 #t1 will hold value 32
	li $t8, 0
	extract_bit($a3, $a2, $zero)     #$a3 = a2[0] - Determines addition or subtraction
	beq $a3, 1, subtraction_invert   #If a2[0] = 1, then get twos complement of number
	j ADD_LOOP  #If it is not 1, then proceed with normal addition
	
subtraction_invert:
	not $a1, $a1 #NOT is done on $a1 to invert it
	j ADD_LOOP
	
ADD_LOOP:
	extract_bit($t2, $a0, $t0) #Extract nth bit of first number in $t2
	extract_bit($t3, $a1, $t0) #Extract nth bit of second number in $t2
	xor $t4, $t2, $t3 #$t4 = A XOR B
	xor $t5, $a3,$t4  #t5 = Carry($a3) XOR (A XOR B)
	
	and $t6, $t2, $t3 #$t6 = A AND B
	and $t7, $a3, $t4 #t7 = C AND (A XOR B)
	or $a3, $t7, $t6 #Carry = (C AND (A XOR B)) OR (A AND B)
	
	insert_at_bit($t8, $t0, $t5, $t9) #Insert $t5(SUM) into nth bit of $t8
	addi $t0, $t0, 1 #Increment loop counter
	beq $t0, $t1, addition_subtraction_exit #If counter = 32, exit
	j ADD_LOOP
	
addition_subtraction_exit: 
	move $v0, $t8 #$t8 the final sum is then moved to $v0
	move $v1, $a3 #Give $v1 the carry(possible use for overflow)
	
	lw $a0, 28($sp) #RESTORE FRAME
	lw $a1, 24($sp)
	lw $a2, 20($sp)
	lw $a3, 16($sp)
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 28
	jr $ra
	
	
	

exit: #EXIT POINT FOR EVERYTHING
	lw $a0, 28($sp) #RESTORE FRAME
	lw $a1, 24($sp)
	lw $a2, 20($sp)
	lw $a3, 16($sp)
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 28
	jr $ra
####################################################################	
logical_multiplication:
	jal signed_multiplication
	j exit
	
logical_division:
	jal signed_division
	j exit
	
twos_complement_if_neg:
	addi $sp, $sp, -16 #SAVE FRAME
	sw $a0, 16($sp)
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 16
	
	move $v0, $a0
	bge $a0, 0, twos_complement_if_neg_end
	jal twos_complement
	j twos_complement_if_neg_end


twos_complement_if_neg_end:
	lw $a0, 16($sp)
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 16
	jr $ra

twos_complement:
	addi $sp, $sp, -24
	sw $a0, 24($sp)
	sw $a1, 20($sp)
	sw $a2, 16($sp)
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 24
	
	not $a0, $a0
	li $a1, 1
	jal logical_addition
	
	lw $a0, 24($sp)
	lw $a1, 20($sp)
	lw $a2, 16($sp)
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 24
	jr $ra
	
bit_replicator:
	addi $sp, $sp, -16
	sw $a0, 16($sp)
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 16
	
	beq $a0, $zero, zero_replicator
	lw $v0, subtraction
	j bit_replicator_finish
	
bit_replicator_finish:
	lw $a0, 16($sp)
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 16
	jr $ra
	
zero_replicator:
	lw $v0, addition
	j bit_replicator_finish
	
twos_complement_64bit:
	addi $sp, $sp, -28
	sw $a0, 28($sp)
	sw $a1, 24($sp)
	sw $a2, 20($sp)
	sw $s0, 16($sp)
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 28
	
	not $a0, $a0
	not $a1, $a1
	move $s0, $a1
	li $a1, 1
	jal logical_addition
	move $a1, $s0
	move $s0, $v0
	move $a0, $v1
	jal logical_addition
	move $v1, $v0
	move $v0, $s0
	
	lw $a0, 28($sp)
	lw $a1, 24($sp)
	lw $a2, 20($sp)
	lw $s0, 16($sp)
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 28
	jr $ra
	
unsigned_multiplication:
	addi $sp, $sp, -40
	sw $a0, 40($sp)
	sw $a1, 36($sp)
	sw $a2, 32($sp)
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 40
	
	li $s0, 0 #$s0 = 0
	li $s1, 0 #$s1 = 0
	move $s2, $a1 #$s2 = second number(temporary)
	move $s3, $a0 #s3 = first number(temporary)
	j multiply_loop
	
multiply_loop:
	extract_bit($t0, $s2, $zero) #$t0 = second number[0]
	move $a0, $t0 #Make $a0 = $t0 for bit replicator
	jal bit_replicator
	move $t0, $v0 #Load result of bit replicator back into $t0
	and $t1, $s3, $t0 #Multiply(AND) the first number with the nth digit
	move $a0, $s1 #Move $s1 to $a0
	move $a1, $t1 #Move multiplication result to $a1 and add
	
	jal logical_addition
	move $s1, $v0 #Result of addition back into $s1
	li $t2, 1 #load temporary with 1
	li $t0, 31 #load temporary with 31
	srl $s2, $s2, 1 #shift second number right by 1
	extract_bit($t3, $s1, $zero) #$t3 = take bit from $s1
	insert_at_bit($s2, $t0, $t3, $t4) #Make 31st bit of #s2
	srl $s1, $s1, 1  #Shift register to the right
	addi $s0, $s0, 1 #Increment counter
	beq $s0, 32, unsigned_multiplication_finish
	j multiply_loop
	
unsigned_multiplication_finish:
	move $v0, $s2
	move $v1, $s1
	
	lw $a0, 40($sp)
	lw $a1, 36($sp)
	lw $a2, 32($sp)
	lw $s0, 28($sp)
	lw $s1, 24($sp)
	lw $s2, 20($sp)
	lw $s3, 16($sp)
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 40
	jr $ra
	
signed_multiplication:
	addi $sp, $sp, -44
	sw $a0  , 44($sp)
	sw $a1, 40($sp)
	sw $s1, 36($sp)
	sw $s2, 32($sp)
	sw $s3, 28($sp)
	sw $s4, 24($sp)
	sw $s5, 20($sp)
	sw $s6, 16($sp)
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 44
	
	move $s1, $a0,            #Here, temporaries are used to hold the original
	move $s2, $a1             #numbers and then get their twos complement if they are
	jal twos_complement_if_neg#negative
	move $s3, $v0             #
	move $a0, $a1             #
	jal twos_complement_if_neg
	move $a1, $v0
	move $a0, $s3
	jal unsigned_multiplication #Once both numbers in their twos complement, insert in circuit
	li $t0, 31                  
	move $a0, $v0 #Move result back into argument register incase twos complement
	move $a1, $v1
	extract_bit($s4, $s1, $t0) #Extract sign bits from original numbers
	extract_bit($s5, $s2, $t0)
	xor $s6, $s4, $s5 #XOR of those bits will determine sign 
	bne $s6, 1, signed_multiplication_finish#If it is 1, meaning negative
	jal twos_complement_64bit #Retrieve twos complement
	j signed_multiplication_finish
	
signed_multiplication_finish:
	lw $a0, 44($sp)
	lw $a1, 40($sp)
	lw $s1, 36($sp)
	lw $s2, 32($sp)
	lw $s3, 28($sp)
	lw $s4, 24($sp)
	lw $s5, 20($sp)
	lw $s6, 16($sp)
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 44
	jr $ra
##############################################################
unsigned_division:
	addi $sp, $sp, -52
	sw $a0, 52($sp)
	sw $a1, 48($sp)
	sw $s0, 44($sp)
	sw $s1, 40($sp)
	sw $s2, 36($sp)
	sw $s3, 32($sp)
	sw $s4, 28($sp)
	sw $t0, 24($sp)
	sw $t1, 20($sp)
	sw $t2, 16($sp)
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 52
	
	li $s3, 0 #Load $s3# with 0
	li $s2, 0 #Load $s0 with 0
	move $s0, $a0 #$s0 = first number
	move $s1, $a1 #s1 = second number
	j division_loop
	
division_loop:
	sll $s2, $s2, 1 #shift $s2  (REMAINDER) by left 1
	li $t0, 31 #Load temporary with 31
	extract_bit($t1, $s0, $t0) #Take last bit of dividend $s0
	insert_at_bit($s2, $zero, $t1, $t5) #Insert it into remainder register
	addi $t0, $zero, 1#$t0 becomes 1
	sll $s0, $s0, 1 #shift dividend to left
	move $t2, $a0 #Move dividend to $t2
	move $a0, $s2 #Make remainder register to $a0
	jal logical_subtraction #Subtract remainder and divisor
	move $s2, $a0 #Move remainder back to $s2
	move $a0, $t2#Move dividend back into $a0
	move $s4, $v0
	bge $s4, $zero, POSITIVE_REMAINDER #Check if difference is positive
	j increment #DOES NOT REASSIGN REMAINDER IF NEGATIVE(ROLLBACK)
	
POSITIVE_REMAINDER:
	move $s2, $s4 #move difference to $s2 (NEW REMAINDER)
	li $t0, 1 #load immediate 1 bit to insert
	insert_at_bit($s0, $zero, $t0, $t2)#MSB of lower-end of 64-bit register gets filled with 1
	j increment
	
increment:
	addi $s3, $s3, 1 ##
	beq $s3, 32, unsigned_division_finish #CHECK CONDITION UNTIL 32
	j division_loop
	
unsigned_division_finish:
	move $v1, $s2 #REMAINDER
	move $v0, $s0 #QUOTIENT
	
	lw $a0, 52($sp) #RESTORE FRAME
	lw $a1, 48($sp)
	lw $s0, 44($sp)
	lw $s1, 40($sp)
	lw $s2, 36($sp)
	lw $s3, 32($sp)
	lw $s4, 28($sp)
	lw $t0, 24($sp)
	lw $t1, 20($sp)
	lw $t2, 16($sp)
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 52
	jr $ra
	
signed_division:
	addi $sp, $sp, -52 #STORE FRAME
	sw $a0, 52($sp)
	sw $a1, 48($sp)
	sw $s0, 44($sp)
	sw $s1, 40($sp)
	sw $s2, 36($sp)
	sw $s3, 32($sp)
	sw $s4, 28($sp)
	sw $s5, 24($sp)
	sw $s6, 20($sp)
	sw $s7, 16($sp)
	sw $fp, 12($sp)
	sw $ra, 8($sp) 
	addi $fp, $sp, 52
	
	move $s0, $a0 #FIRST NUMBER = $s0
	move $s1, $a1 #SECOND NUMBER = $s1
	jal twos_complement_if_neg #TWOS COMPLEMENT FIRST NUMBER IF NEGATIVE
	move $s2, $v0
	move $a0, $a1
	jal twos_complement_if_neg #TWOS COMPLEMENT SECOND NUMBER IF NEGATIVE
	move $a1, $v0
	move $a0, $s2
	jal unsigned_division #INSERT NUMBERS INTO DIVISION CIRCUIT
	move $s4, $v0 #$s4 = quotient 
	move $s3, $v1 #$s3 = remainder
	li $t4, 31 
	extract_bit($s5, $s0, $t4) #FIND SIGN BIT OF FIRST NUMBER
	extract_bit($s6, $s1, $t4) #FIND SIGN BIT OF SECOND NUMBER
	xor $s7, $s5, $s6 #XOR between them to get sign of quiotient
	bne $s7, 1, remainder #BRANCH OFF TO FIND REMAINDER IF ITS POSITIVE
	move $a0, $s4 #IF NOT, THEN... 
	jal twos_complement #GET TWOS COMPLEMENT OF QUOTIENT
	move $s4, $v0 
	j remainder
	
remainder:
	li $t4, 31
	extract_bit($s5, $s0, $t4) #MSB of FIRST NUMBER(DIVIDEND)
	move $s7, $s5 
	bne $s7, 1, signed_division_finish #If dividend is positive, finish
	move $a0, $s3
	jal twos_complement #If not get twos complement of remainder then done
	move $s3, $v0
	j signed_division_finish
	
signed_division_finish:
	move $v0, $s4 #QUOTIENT 
	move $v1, $s3 #REMAINDER
	
	lw $a0, 52($sp) #RESTORE FRAME
	lw $a1, 48($sp)
	lw $s0, 44($sp)
	lw $s1, 40($sp)
	lw $s2, 36($sp)
	lw $s3, 32($sp)
	lw $s4, 28($sp)
	lw $s5, 24($sp)
	lw $s6, 20($sp)
	lw $s7, 16($sp)
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 52
	jr $ra
	
	
	
	
	
	

	
	
	
	
	
	

	

	
