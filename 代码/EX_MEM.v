
`include "define.v"
//EX_MEM 流水寄存器
module EX_MEM(
    input wire clk,
    input wire rst, 
    input wire[5:0] stall,		//from Ctrl
 
	//EX to EX_MEM input
	input wire[31:0] inst_i,	//根据数据通路，所有流水寄存器必须要加的
    input reg [31:0] regcData_i,
    input wire regcWrite_i,
    input wire [4:0] regcAddr_i,
	input wire [5:0] op_i,
    input wire [31:0] memAddr_i,
    input wire [31:0] memData_i,
 
	//EX_MEM to MEM output
	output reg[31:0] inst_o,	//根据数据通路，所有流水寄存器必须要加的
    output reg [31:0] regcData_o,
    output reg regcWrite_o,
    output reg [4:0] regcAddr_o,
	output reg [5:0] op_o,
    output reg [31:0] memAddr_o,
    output reg [31:0] memData_o
 
);
 
    always@(posedge clk)
		begin
			if(rst==`RstEnable)
				begin
					inst_o=`ZeroWord;
					regcData_o=`Zero;
					regcWrite_o=`Invalid;
					regcAddr_o=`Zero;
					op_o=`Nop;
					memAddr_o=`Zero;
					memData_o=`Zero;
				end
        	else if(stall[3]==`Stop&&stall[4]==`NoStop)//停顿周期
            	begin
					inst_o=`ZeroWord;
					regcData_o=`Zero;
					regcWrite_o=`Invalid;
					regcAddr_o=`Zero;
					op_o=`Nop;
					memAddr_o=`Zero;
					memData_o=`Zero;
				end
 
        	else if(stall[3]==`NoStop)
            	begin
					inst_o=inst_i;
					regcData_o=regcData_i;
					regcWrite_o=regcWrite_i;
					regcAddr_o=regcAddr_i;
					op_o=op_i;
					memAddr_o=memAddr_i;
					memData_o=memData_i;
				end
 
		end
endmodule