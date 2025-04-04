
`include "define.v"
//MEM_WB 流水寄存器
module MEM_WB(
    input wire clk,
    input wire rst, 
    input wire[5:0] stall,		//from Ctrl
 
	//MEM to MEM_WB input
	input wire[31:0] inst_i,	//根据数据通路，所有流水寄存器必须要加的
	input wire [4:0]  regAddr,
	input wire regWr,
	input wire [31:0] regData,		
 
	//MEM_WB to regFile output
	output reg[31:0] inst_o,	//根据数据通路，所有流水寄存器必须要加的
    output reg we,
    output reg [4:0] waddr,
    output reg [31:0] wdata
 
);
 
    always@(posedge clk)
		begin
			if(rst==`RstEnable)
				begin
					inst_o=`ZeroWord;
					wdata=`Zero;
					we=`Invalid;
					waddr=`Zero;
				end
        	else if(stall[4]==`Stop&&stall[5]==`NoStop)//停顿周期
            	begin
					inst_o=`ZeroWord;
					wdata=`Zero;
					we=`Invalid;
					waddr=`Zero;
				end
 
        	else if(stall[4]==`NoStop)
            	begin
					inst_o=inst_i;
					wdata=regData;
					we=regWr;
					waddr=regAddr;
				end
 
		end
endmodule