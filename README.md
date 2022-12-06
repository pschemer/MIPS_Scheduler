**MIPS Scheduler** 
Accept a sequence of machine code (as hexadecimal strings) from the user, decode, identify and report control signals and stalls needed to execute the given sequence correctly in a 5-stage pipeline with no
forwarding support.

Main program: 
• Accept an integer N from the user which specifies how many instructions to process.
• Accept a sequence of N machine instruction words as a sequence of strings from the user.
o Every instruction is given as one hexadecimal string from the user.
• Extract the numeric value from each input string and generate a label for each of them based on
their order in the given sequence.
o Every input is a valid hexadecimal value, for example " 012A4020" or " AE1F0010".
o The first instruction should get label I0, the second instruction gets label I1, etc.
o Support MIPS instructions: add, addi, sll, slt, lw, sw, bne. 
o Assumes all instructions from the user are valid supported instructions.
• Decode each instruction and report the control signals generated for that instruction.
o Assemble all control signals together as the lowest 11 bits of a 32-bit integer following this format:
    31 Unused Bits 10 0
    RegDst ALUOp ALUSrc Branch MemRead MemWrite RegWrite MemToReg
    § RegDst: bit 10-9, ALUOp: bit 8-7, ALUSrc: 6 Branch: bit 5, MemRead: bit 4,
        MemWrite: bit 3, RegWrite: bit 2, MemToReg: bit 1-0.
    § Encode RegDst and MemToReg: 00 for signal 0; 01 for signal 1, 11 for signal X.
    § Unused bits should be set to zero
o Print out the control signal word as 8 hexadecimal digits.
• Identify and report how many stall cycles are needed for each instruction due to data hazards.
o Assumes 5-stage pipeline processor with no forwarding
o Analyze the given instructions in sequential order.

SAMPLE

Please input instruction sequence:
032AC020↵
030AC820↵
02EA5820↵
032CC020↵
I0: Control signals: 0x00000304
Stall cycles: 0
-------------------------------------------
I1: Control signals: 0x00000304
Stall cycles: 2
-------------------------------------------
I2: Control signals: 0x00000304
Stall cycles: 0
-------------------------------------------
I3: Control signals: 0x00000304
Stall cycles: 1
-------------------------------------------