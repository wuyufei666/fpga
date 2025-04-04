
`include "define.v";
//ID_EX 流水寄存器
 
module ID_EX(
    input wire clk,
    input wire rst, 
    input wire[5:0] stall,		//from Ctrl
 
	//id to ID_EX input
	input wire[31:0] inst_i,	//根据数据通路，所有流水寄存器必须要加的
	input wire [31:0] excptype_i,
	input wire [5:0] op_i,  
	input wire [31:0] pc_i,  	
    input wire [31:0] regaData_i,
    input wire [31:0] regbData_i,
    input wire regcWrite_i,
    input wire [4:0] regcAddr_i,	
 
	//ID_EX to EX output 
	output reg[31:0] inst_o,	//根据数据通路，所有流水寄存器必须要加的
	output reg [31:0] excptype_o,//
	output reg [5:0] op_o,
	output reg  [31:0] pc_o, 
    output reg [31:0] regaData_o,
    output reg [31:0] regbData_o,
    output reg regcWrite_o,
    output reg [4:0] regcAddr_o
);
 
    always@(posedge clk)
		begin
			if(rst==`RstEnable)
				begin
					inst_o=`ZeroWord;
					excptype_o=excptype_i;
					op_o=`Nop;
					pc_o=`Zero;
					regaData_o=`Zero;
					regbData_o=`Zero;
					regcWrite_o=`Invalid;
					regcAddr_o=`Zero;
				end
        	else if(stall[2]==`Stop&&stall[3]==`NoStop)//停顿周期
            	begin
					inst_o=`ZeroWord;
					excptype_o=excptype_i;
					op_o=`Nop;
					pc_o=`Zero;
					regaData_o=`Zero;
					regbData_o=`Zero;
					regcWrite_o=`Invalid;
					regcAddr_o=`Zero;		
				end
 
        	else if(stall[2]==`NoStop)
            	begin
            		inst_o<=inst_i;	
					excptype_o=excptype_i;
					op_o=op_i;
					pc_o=pc_i;
					regaData_o=regaData_i;
					regbData_o=regbData_i;
					regcWrite_o=regcWrite_i;
					regcAddr_o=regcAddr_i;		
				end
 
		end
 
endmodule
 