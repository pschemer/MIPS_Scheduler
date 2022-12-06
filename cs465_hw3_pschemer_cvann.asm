#############################################################
# NOTE: this is the provided TEMPLATE as your required 
#		starting point of HW3 MIPS programming part.
#		This is the only file you should change and submit.
#
# Author: Hamza Mughal
# CS465 F2019
# HW3 
#############################################################

#############################################################
# PUT YOUR TEAM INFO HERE
# NAME		Patrick Schemering
# G#		01037384
# NAME 2	Carl Vann
# G# 2		01020750
#############################################################

#############################################################
# DESCRIPTION  
#
# PUT YOUR ALGORITHM DESCRIPTION HERE
#############################################################

.data # Start of Data Items
	INIT_INPUT: .asciiz "How many instructions to process? "
	INSTR_SEQUENCE: .asciiz "Please input instruction sequence:\n"
	CONTROL_SIGNALS: .asciiz ": Control signals: "
	STALL_CYCLES: .asciiz "Stall cycles: "
	NEWLINE: .asciiz "\n"

	.align 4
	INPUT: .space 8
	
	
# End of Data Items

.text
main:
	la $a0, INIT_INPUT
	li $v0, 4
	syscall # Print out message asking for N (number of instructions to process)
	
	li $v0, 5
	syscall # read in Int 
	addi $t1, $v0, 0 
	
	
	la $a0, INSTR_SEQUENCE
	li $v0, 4
	syscall 
	
	li $t0, 0 # loop counter	
	Loop: # Read in N strings
		la $a0, INPUT
		li $a1, 9
		li $v0, 8
		syscall # read in one string and store in INPUT
		###########################################
		# Add your code here to process the input
		###########################################
		lbu	$a0, 0($a0)
		jal	atoi		# get u_int value of hex string - same func as hw2
		addi	$sp, $sp, -4 	# expand stack
		sw	$v0, 0($sp)	# save instruction
		
		la $a0, NEWLINE
		li $v0, 4
		syscall 												
																																				
		addi $t0, $t0, 1
		blt $t0, $t1, Loop	# repeat N times
		
		################################################33
		#	Cycles
		#
		#	
		#	Stage[] = [IF][ID][EX][MEM][WB]
		#	Initialized with -1's
		#
		#	Label = init with $zero
		#################################################
		
		# WHILE N > 0 DO:
		#	IF Stage[0] == -1 DO:
		#		Get next instruction from 4*N($sp)
		#		decrement N
		#		parse instruction 
		#		call PARSE
		#		point Stage[0] to return value
		#	IF Stage[4] != -1 DO:
		#		Access Stage[4] contents
		#		add stage[4][0] to $a0
		#		call UNLOCK
		#		Stage[4] = -1
		#
		#	IF Stage[3] != -1 DO:
		#		IF Stage[4] != -1 DO:
		#			increment Stall
		#		ELSE
		#			IF Stage[3] is not waiting DO:
		#				Stage[4] = Stage[3]
		#				Stage[3] = -1
		#	
		#	repeat similar for stage 2
		#
		#	IF Stage[1] != -1 DO:
		#		IF call CHECK(Stage[0]) returns TRUE DO:
		#			call LOCK
		#			Stage[1] = Stage[0]
		#			Stage[0] = -1
		#			
		
		################################################################
		#	bool CHECK (int request)
		#
		#	Hold global word 31-0 to flag locked registers
		#		ex: ori	$flags, $flags, 0x8 # locks $t0
		###############################################################
		
		#	IF ($flags AND request) != 0 
		#		return false
		#	return true
		
		##################################################################
		#	void LOCK (int request)
		#############################################################
		
		#	or $flags, $flags, request
		
		################################################################
		#	void UNLOCK (int request)
		################################################################
		
		#	SRA and SLL to get mask for request bit
		#	flip request bit to 0
		#	and $flags, $flags, mask
		
		#	call SIGNALS
		#	Print Stall Cycles = STALLS
		



exit:
	li $v0, 10
	syscall




#############################################################
# optional: other helper functions
#############################################################
SIGNALS:
	li 	$s0, 0 # locked registers
#
		#	s0	Locked registers
		#	s1	This Instruction
		#	s2	OPCode
		#	s3	RS
		#	s4	RT
		#	s5	RD
		###########################################
		
		
		addi	$t2, $zero, 0xFC000000 # OPCode Mask
		addi	$t3, $zero, 0x03F00000 # RS Mask
		addi	$t4, $zero, 0x001F0000 # RT Mask
		addi	$t5, $zero, 0x0000F800 # RD Mask
		
		and	$s2, $s1, $t2
		and	$s3, $s1, $t3
		and	$s4, $s1, $t4
		and	$s5, $s1, $t5
		
		###########################################
		#	ADD	0x1
		#	ADDI	0x2
		#	SLL	0x3
		#	SLT	0x4
		#	LW	0x5
		#	SW	0x6
		#	BNE	0x7
		#
		###########################################
		
		add	$a0, $s1, 0
		jal	get_insn_code
		
	#Prepare Control Signal Text:
	#
	la $a0, NEWLINE
	li $v0, 4
	syscall
	
	addi	$a0, $zero, 0x49
	li 	$v0, 11
	syscall #Print Label Marker
	
	add	$a0, $t0, 0
	li 	$v0, 1
	syscall #Print label number
	
	la 	$a0, CONTROL_SIGNALS
	li 	$v0, 4
	syscall #Print control signal text
	#
	
		
	#ADD
		#	SIGS:	01 10 0 0 0 0 1 00
		#	LOCK:	rd
		#	REQUIRE:rs,rt
		bne	$v0, 0x1, ADDI
		
	ADDI:
		#	SIGS:	00 00 1 0 0 0 1 00
		#	LOCK:	rt
		#	REQUIRE:rs
		bne	$v0, 0x2, SLL
		
	SLL:	
		#	SIGS:	10 11 0 0 0 0 1 00
		#	LOCK:	rd
		#	REQUIRE:rt
		bne	$v0, 0x3, SLT
		
	SLT:
		#	SIGS:	01 11 0 0 0 0 1 00
		#	LOCK:	rd
		#	REQUIRE:rs,rt
		bne	$v0, 0x4, LW
		
	LW:
		#	SIGS:	00 00 1 0 1 0 1 01
		#	LOCK:	rt
		#	REQUIRE:rs
		bne	$v0, 0x5, SW
		
	SW:
		#	SIGS:	00 00 1 0 0 1 0 00
		#	LOCK:	
		#	REQUIRE:rs,rt
		bne	$v0, 0x6, BNE
		
	BNE:
		#	SIGS:	00 01 0 1 0 0 0 00
		#	LOCK:	
		#	REQUIRE:rs,rt
		
		
		
	
		
		
