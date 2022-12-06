#############################################################
# PUT YOUR TEAM INFO HERE
# NAME:		Patrick Schemering
# G#:		G-01037384
# NAME 2:	Carl Vann
# G# 2:		G-01020750
#############################################################

#############################################################
# Data segment
#############################################################

.data

#############################################################
# Code segment
#############################################################

.text

#############################################################
# atoi
#############################################################
#############################################################
# DESCRIPTION  
# u_int atoi(char* start_addr)
#
# Iterates through char array of length 8 with guarenteed
# hexadecimal values and returns the u_int value
#############################################################
		
.globl atoi
atoi:
	addu		$v0, $zero, 0			#retVal init to 0 @ v0
	addu		$t4, $zero, 0			#idx is 0 @ t4
	addu		$t5, $zero, 8			#len is 8 @ t5

LOOPatoi:
	lbu		$t0, 0($a0)			#load byte from *start_addr

	li		$t1, 0x30			#numeral offset
	li		$t2, 0x39			#alpha offset

	andi		$t1, $t1, 0x000000ff		#Cast to word for compare
	andi		$t2, $t2, 0x000000ff
	bgt		$t0, $t2, ALPHA			#if greater than 0x39, test for A-F

	addiu		$t0, $t0, -0x30			#If char 48<>55, is numeric, subtract 48
	j		PROCatoi

ALPHA:
	addiu		$t0, $t0, -0x37			#subtract 55 from hex char ('A' - 'F')

PROCatoi:
	or		$v0, $v0, $t0			# flip on bits for retval

	addiu		$t4, $t4, 1			# ++idx
	beq		$t4, $t5, RETatoi		# check loop condition idx = len
	addiu		$a0, $a0, 0x1			# move to next char *(start_addr + idx)
	sll		$v0, $v0, 4			# shift left for next value
	j		LOOPatoi			# Compute next char
	
RETatoi:
	#prepare return
	addi		$sp, $sp, -8			# move stack pointer x2
	sw		$ra, 4($sp)			# Save return addr 
	sw		$s0, 0($sp)			# Save caller's s0
	add		$s0, $v0, $zero			# Save our retVal
	add		$a0, $zero, 1			# call report(1)
	#report status
	#jal	report
	
	#	restore retVal, Caller's s0, stack pointer, and return
	add	$v0, $s0, $zero
	lw	$s0, 0($sp)
	lw	$ra, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
	
	

#############################################################
# get_insn_code
#############################################################
#############################################################
# DESCRIPTION
# int get_insn_code(u_int instruction)  
#
# gets the instruction from private helper function
# reports stage 1 pass
# returns insn code
#
# insn_codes =	{
#			0x1:add, 0x2:addi, 0x3:sll, 0x4:slt
#			0x5:lw, 0x6:sw, 0x7:bne, 0x8:j, 0x33:invalid
#		}
# 
#############################################################

	
.globl get_insn_code
get_insn_code:
	
	addi		$sp, $sp, -4
	sw		$ra, 0($sp)
	jal		priv_get_insn_code		# call private helper function
	lw		$ra, 0($sp)
	addi		$sp, $sp, 4
	
	#prepare return
	addi		$sp, $sp, -8			# move stack pointer x2
	sw		$ra, 4($sp)			# Save return addr 
	sw		$s0, 0($sp)			# Save caller's s0
	add		$s0, $v0, $zero			# Save our retVal
	add		$a0, $zero, 2			# call report(2)
	#report status
	#jal		report
	
	#	restore retVal, Caller's s0, stack pointer, and return
	add	$v0, $s0, $zero
	lw	$s0, 0($sp)
	lw	$ra, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra



#############################################################
# get_dest_reg
#############################################################
#############################################################
# DESCRIPTION 
# int get_dest_reg(u_int instruction) 
#
# gets instruction type from private helper function
# returns destination register ($rt | $rd) for this instruction
# returns 33 for invalid instruction
# returns 32 if instruction has no destination register
# 
#############################################################
	
.globl get_dest_reg
get_dest_reg:

	addi	$sp, $sp, -8		# expand stack x2
	sw	$ra, 4($sp)		# store ret addr
	sw	$a0, 0($sp)		# store param1
	jal	priv_get_insn_code	# call get_insn_code(u_int instruction)
	
	add	$t0, $v0, $zero		# get instruction
					# restore param1, ret addr, stack
	lw	$a0, 0($sp)
	lw	$ra, 4($sp)
	addi	$sp, $sp, 8
	
	beq	$t0, 33, RETget_dest	# if invalid, return	
	
	addiu	$t1, $zero, 0x001F0000	# Mask for $rt
	addiu	$t2, $zero, 0x0000F800	# Mask for $rd
	
	bne	$t0, 0x1, ADDI		# if op is ADD
	and	$v0, $a0, $t2		# Extract $rd
	srl	$v0, $v0, 11		# Shift to lsb
	j	RETget_dest		# return

ADDI:
	bne	$t0, 0x2, SLL		# else if op is ADDI
	and	$v0, $a0, $t1		# Extract $rt
	srl	$v0, $v0, 16		# Shift to lsb
	j	RETget_dest		# return

SLL:
	bne	$t0, 0x3, SLT		# else if op is SLL
	and	$v0, $a0, $t2		# Extract $rd
	srl	$v0, $v0, 11		# Shift to lsb
	j	RETget_dest		# return
	
SLT:
	bne	$t0, 0x4, LW		# else if op is SLT
	and	$v0, $a0, $t2		# Extract $rd
	srl	$v0, $v0, 11		# Shift to lsb
	j	RETget_dest		# return
	
LW:
	bne	$t0, 0x5, ELSE		# else if op is LW
	and	$v0, $a0, $t1		# Extract $rt
	srl	$v0, $v0, 16		# Shift to lsb
	j	RETget_dest		# return
	
ELSE:					# else [OP is SW, BNE, J]
	addi	$v0, $zero, 32		# 32 - no register value changed
	
RETget_dest:
	#prepare return
	addi		$sp, $sp, -8			# move stack pointer x2
	sw		$ra, 4($sp)			# Save return addr 
	sw		$s0, 0($sp)			# Save caller's s0
	add		$s0, $v0, $zero			# Save our retVal
	add		$a0, $zero, 3			# call report(3)
	#report status
	#jal		report
	
	#	restore retVal, Caller's s0, stack pointer, and return
	add	$v0, $s0, $zero
	lw	$s0, 0($sp)
	lw	$ra, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra


#############################################################
# get_src_regs
#############################################################
#############################################################
# DESCRIPTION 
# int get_src_regs(u_int instruction)
#
# gets intstruction type from private helper function
# switch(num_src_registers)
#	case 1: retval_0 = $rs, retval_1 = 32; break;
#	case 2: retval_0 = $rs, retval_1 = $rt; break;
#	case 32: return no_src;
#	case 33: return invalid;
# return retval_0, retval_1;
# 
#############################################################

.globl get_src_regs
get_src_regs:
	
	addi	$sp, $sp, -8		# expand stack x2
	sw	$ra, 4($sp)		# store ret addr
	sw	$a0, 0($sp)		# store param1
	jal	priv_get_insn_code	# call get_insn_code(u_int instruction)
	
	add	$t0, $v0, $zero		# get instruction
					# restore param1, ret addr, stack
	lw	$a0, 0($sp)
	lw	$ra, 4($sp)
	addi	$sp, $sp, 8
	
	beq	$t0, 33, RETget_src	# if invalid, return	
	
	addiu	$t1, $zero, 0x001F0000	# Mask for $rt
	addiu	$t2, $zero, 0x03E00000	# Mask for $rs
	
	bne	$t0, 0x1, ADDIs		# if op is ADD
	and	$v0, $a0, $t2		# Extract $rs
	srl	$v0, $v0, 21		# Shift to lsb
	and	$v1, $a0, $t1		# Extract $rt
	srl	$v1, $v1, 16
	j	RETget_src		# return

ADDIs:
	bne	$t0, 0x2, SLLs		# else if op is ADDI
	and	$v0, $a0, $t2		# Extract $rs
	srl	$v0, $v0, 21		# Shift to lsb
	addi	$v1, $zero, 32		
	j	RETget_src		# return

SLLs:
	bne	$t0, 0x3, SLTs		# else if op is SLL
	and	$v0, $a0, $t1		# Extract $rt
	srl	$v0, $v0, 16		# Shift to lsb
	addi	$v1, $zero, 32
	j	RETget_src		# return
	
SLTs:
	bne	$t0, 0x4, LWs		# else if op is SLT
	and	$v0, $a0, $t2		# Extract $rs
	srl	$v0, $v0, 21		# Shift to lsb
	and	$v1, $a0, $t1		# Extract $rt
	srl	$v1, $v1, 16		# Shift to lsb
	j	RETget_src		# return
	
LWs:
	bne	$t0, 0x5, SWs		# else if op is LW
	and	$v0, $a0, $t2		# Extract $rs
	srl	$v0, $v0, 21		# Shift to lsb
	addi	$v1, $zero, 32
	j	RETget_src		# return
	
SWs:
	bne	$t0, 0x6, BNEs		# else if op is SW
	and	$v0, $a0, $t2		# Extract $rs
	srl	$v0, $v0, 21		# Shift to lsb
	and	$v1, $a0, $t1		# Extract $rt
	srl	$v1, $v1, 16		# Shift to lsb
	j	RETget_src		# return
	
BNEs:
	bne	$t0, 0x4, ELSEs		# else if op is BNE
	and	$v0, $a0, $t2		# Extract $rs
	srl	$v0, $v0, 21		# Shift to lsb
	and	$v1, $a0, $t1		# Extract $rt
	srl	$v1, $v1, 16		# Shift to lsb
	j	RETget_src		# return
	
ELSEs:					# else [OP is J]
	addi	$v0, $zero, 32		# 32 - no register value changed
	
RETget_src:
	#prepare return
	addi		$sp, $sp, -8			# move stack pointer x2
	sw		$ra, 4($sp)			# Save return addr 
	sw		$s0, 0($sp)			# Save caller's s0
	add		$s0, $v0, $zero			# Save our retVal
	add		$a0, $zero, 4			# call report(4)
	#report status
	#jal		report
	
	#	restore retVal, Caller's s0, stack pointer, and return
	add	$v0, $s0, $zero
	lw	$s0, 0($sp)
	lw	$ra, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra




#############################################################
# optional: other helper functions
#############################################################

#############################################################
# int priv_get_insn_code(u_int instr)
#############################################################	
#############################################################
# DESCRIPTION 
# private version of get_insn_code (does not report)
#
# opcode = (instr & mask_opcode) >> 26;
# func = (instr & mask_func)
# if (opcode != 0)
# 	switch(opcode)
#		case 0x8: retval = 2; break;
#		case 0x23: retval = 5; break;
#		case 0x2b: retval = 6; break;
#		case 0x05: retval = 7; break;
#		case 0x02: retval = 8; break;
#		default: retval = 33;
# else
#	switch(func)
#		case 0x20: retval = 1; break;
#		case 0x00: retval = 3; break;
#		case 0x2a: retval = 4; break;
#		default: reval = 33;
# return retval;
#############################################################			
priv_get_insn_code:
	
	addiu		$t0, $zero, 0xfc000000		# Mask for opcode
	addiu		$t1, $zero, 0x0000003f		# Mask for func
	
	and		$t0, $a0, $t0			# Extract opcode bits
	beq		$t0, $zero, privRTYPE		# R-Type if opcode = 0
	
	addiu		$v0, $zero, 0x2
	srl		$t2, $t0, 26
	beq		$t2, 0x08, privRETget_insn_code	# Return 0x2 if opcode is 0x08
	
	addiu		$v0, $zero, 0x5
	srl		$t2, $t0, 26
	beq		$t2, 0x23, privRETget_insn_code	# Return 0x5 if opcode is 0x23
	
	addiu		$v0, $zero, 0x6
	srl		$t2, $t0, 26
	beq		$t2, 0x2b, privRETget_insn_code	# Return 0x6 if opcode is 0x2b
	
	addiu		$v0, $zero, 0x7
	srl		$t2, $t0, 26
	beq		$t2, 0x05, privRETget_insn_code	# Return 0x7 if opcode is 0x05
	
	addiu		$v0, $zero, 0x8
	srl		$t2, $t0, 26
	beq		$t2, 0x02, privRETget_insn_code	# Return 0x8 if opcode is 0x02
	
	addiu		$v0, $zero, 33			# Return 33 for invalid
	j		privRETget_insn_code
	
privRTYPE:
	and		$t0, $a0, $t1			# Extract func-e bits
	
	addiu		$v0, $zero, 0x1
	beq		$t0, 0x20, privRETget_insn_code	# Return 0x1 if func is 0x20
	
	addiu		$v0, $zero, 0x3
	beq		$t0, 0x00, privRETget_insn_code	# Return 0x2 if func is 0x00
	
	addiu		$v0, $zero, 0x4
	beq		$t0, 0x2a, privRETget_insn_code	# Return 0x4 if func is 0x2a
	
	addiu		$v0, $zero, 33			# Return 33 for invalid

privRETget_insn_code:
	
	jr	$ra
