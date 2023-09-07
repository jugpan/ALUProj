# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#
	#Macro : insert_at_bit($destination, $bitPosition, $bitValue, $tempRegister)
	#Usage : insert a bit value 0 or 1 at given position
	.macro insert_at_bit($destination, $bitPosition, $bitValue, $tempRegister)
	add $tempRegister, $zero, 1
	sllv $tempRegister, $tempRegister, $bitPosition
	not $tempRegister, $tempRegister
	and $destination, $destination, $tempRegister
	sllv $bitValue, $bitValue, $bitPosition
	or $destination, $bitValue, $destination
	.end_macro
	
	#Macro : extract_bit($bitValue, $bitPattern, $bitPosition)
	#Usage : extract_bit(value of extracted bit(0 or 1) 
	.macro extract_bit($bitValue, $bitPattern, $bitPosition)
	addi $bitValue, $zero, 1
	sllv $bitValue, $bitValue, $bitPosition
	and $bitValue, $bitValue, $bitPattern
	srlv $bitValue, $bitValue, $bitPosition
	.end_macro
	