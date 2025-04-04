`define RstEnable       1'b1
`define RstDisable      1'b0
`define RomEnable       1'b1 
`define RomDisable      1'b0
`define Zero	        0
`define Valid	        1'b1
`define Invalid	        1'b0
//I
`define Inst_ori   	6'b001101
`define Inst_addi  	6'b001000
`define Inst_andi  	6'b001100
`define Inst_xori  	6'b001110
`define Inst_lui   	6'b001111
`define Inst_subi  	6'b001001

//lw sw
`define Inst_lw 	6'b100011
`define Inst_sw 	6'b101011

//beq bne
`define Inst_beq  	6'b000100
`define Inst_bne  	6'b000101

//R
`define Inst_r    	6'b000000
`define Inst_add  	6'b100000
`define Inst_sub  	6'b100010
`define Inst_and	6'b100100
`define Inst_or    	6'b100101
`define Inst_xor   	6'b100110
`define Inst_sll   	6'b000000
`define Inst_srl   	6'b000010
`define Inst_sra   	6'b000011

`define Inst_jr    	6'b001000
//J
`define Inst_j   	6'b000010
`define Inst_jal 	6'b000011

//12
`define Inst_slt	6'b101010
`define Inst_bgtz	6'b000111
`define Inst_bltz	6'b000001
`define Inst_jalr	6'b001001
`define Inst_mult	6'b011000
`define Inst_multu	6'b011001
`define Inst_div	6'b011010
`define Inst_divu	6'b011011
`define Inst_mfhi	6'b010000
`define Inst_mflo	6'b010010
`define Inst_mthi	6'b010001
`define Inst_mtlo	6'b010011

//
`define Inst_ll		6'b110000
`define Inst_sc		6'b111000
`define Inst_mfc0	6'b000000
`define Inst_mtc0	6'b000000
`define Inst_eret	6'b011000
`define syscall		6'b001100

`define Nop     	6'b000000
`define Or      	6'b000001
`define Add		6'b000010
`define And		6'b000011
`define Xor		6'b000100
`define Lui		6'b000101
`define Sub     	6'b000110
`define Sll     	6'b000111
`define Srl     	6'b001000
`define Sra		6'b001001
`define J		6'b001010
`define Jal		6'b001011
`define Beq		6'b001100
`define Bne		6'b001101
`define Jr		6'b001110
`define Lw  		6'b010000
`define Sw  		6'b010001
`define Bgtz		6'b010010
`define Bltz		6'b010011
`define Slt		6'b010100
`define Mult		6'b010101
`define Multu		6'b010110
`define Div		6'b010111
`define Divu		6'b011000
`define Mfhi		6'b011001
`define Mflo		6'b011010
`define Mthi		6'b011011
`define Mtlo		6'b011100
//MEM
`define RamWrite 	1'b1
`define RamUnWrite 	1'b0
`define RamEnable 	1'b1
`define RamDisable 	1'b0

//ll sc
`define SetFlag		1'b1
`define ClearFlag	1'b0
`define Inst_ll		6'b110000
`define Inst_sc		6'b111000
`define Ll		6'b011101
`define Sc		6'b011110

//interupt
`define ZeroWord	32'h0000_0000
`define IntrOccur	1'b1
`define IntrNotOccur	1'b0

`define CP0_count	5'd9
`define CP0_compare	5'd11
`define CP0_status	5'd12
`define CP0_epc		5'd14
`define CP0_cause	5'd13

`define Inst_syscall	32'b000000_00000_0000_0000_0000_000_001100
`define Inst_eret	32'b010000_10000_00000_00000_00000_011000
`define Inst_cp0	6'b010000
`define Inst_mfc0	5'b00000
`define Inst_mtc0	5'b00100

`define Syscall		6'b011111
`define Eret		6'b100000
`define Mfc0		6'b100001
`define Mtc0		6'b100010
