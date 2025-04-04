
//0、宏定义文件
`define RstEnable 1'b1
`define RstDisable 1'b0
`define RomEnable 1'b1
`define RomDisable 1'b0
`define Zero 0
`define Valid 1'b1
`define Invalid 1'b0
`define SetFlag 1'b1 	//检查LLbit的值，控制信号，不是数据信号
`define ClearFlag 1'b0	//检查LLbit的值，控制信号，不是数据信号
 
//MEM宏编译
`define RamWrite 1'b1
`define RamUnWrite 1'b0
`define RamEnable 1'b1
`define RamDisable 1'b0
 
//中断编码
`define ZeroWord 32'h0000	
`define IntrOccur 1'b1
`define IntrNotOccur 1'b0
//cp0中各寄存器地址
`define CP0_count 5'd9
`define CP0_compare 5'd11
`define CP0_status 5'd12
`define CP0_epc 5'd14
`define CP0_cause 5'd13
 
//流水线CPU
`define Stop 1'b1
`define NoStop 1'b0
 
//指令外部编码
 
//MIPS 基本整数指令集
//表1 20条MIPS整数指令
 
//R型编码
`define Inst_reg 6'b000000
`define Inst_add 6'b100000
`define Inst_sub 6'b100010
`define Inst_and 6'b100100
`define Inst_or  6'b100101
`define Inst_xor 6'b100110
`define Inst_sll 6'b000000
`define Inst_srl 6'b000010
`define Inst_sra 6'b000011
`define Inst_jr  6'b001000
 
//I型编码
`define Inst_addi 6'b001000
`define Inst_andi 6'b001100
`define Inst_ori  6'b001101
`define Inst_xori 6'b001110
`define Inst_lw 6'b100011
`define Inst_sw 6'b101011
`define Inst_beq  6'b000100	
`define Inst_bne  6'b000101	
`define Inst_lui  6'b001111
//J型编码
`define Inst_j 	 6'b000010	
`define Inst_jal 6'b000011	
//MIPS 扩展整数指令集
//表2 MIPS 12条整数指令
`define Inst_slt 6'b101010
`define Inst_bgtz 6'b000111	//j i	
`define Inst_bltz 6'b000001	//j i 	
`define Inst_jalr 6'b001001	//r 
`define Inst_mult 6'b011000	 //r 
`define Inst_multu 6'b011001 //r 
`define Inst_div 6'b011010	 //r 
`define Inst_divu 6'b011011 //r 
`define Inst_mfhi 6'b010000	 //r 
`define Inst_mflo 6'b010010	 //r 
`define Inst_mthi 6'b010001	 //r 
`define Inst_mtlo 6'b010011	 //r 
//表3 MIPS与中断异常相关6条指令
`define Inst_ll 6'b110000	 //i
`define Inst_sc 6'b111000	 //i
`define Inst_syscall 32'b000000_00000_000000000000000_001100//全译码
`define Inst_eret 32'b010000_10000_000000000000000_011000//全译码
`define Inst_cp0  6'b010000	
`define Inst_mfc0 5'b00000	 //010000扩展编码
`define Inst_mtc0 5'b00100	 //010000扩展编码
 
 
 
//另外
//`define Inst_subi 6'b001001	//i
//内部供EX的编码
`define Nop 6'b000000
`define Or  6'b000001
`define And 6'b000010
`define Xor 6'b000011
`define Add 6'b000100
`define Sub 6'b000101
`define Lui 6'b100000 
`define Sll 6'b000110
`define Srl 6'b000111
`define Sra 6'b001000
`define J   6'b001001
`define Jal 6'b001010
`define Jr  6'b001011
`define Beq 6'b001100
`define Bne 6'b001101
`define Bgtz 6'b001110
`define Bltz 6'b001111
 
`define Lw  6'b010000
`define Sw  6'b010001
 
`define Slt  6'b010010
`define Mult 6'b010011
`define Multu 6'b010100
`define Div 6'b010101
`define Divu 6'b010110
`define Mfhi 6'b010111
`define Mflo 6'b011000
`define Mthi 6'b011001
`define Mtlo 6'b011010
`define Ll 6'b011011
`define Sc 6'b011100
`define Syscall 6'b011101
`define Eret 6'b011110
`define Mfc0 6'b011111
`define Mtc0 6'b100001