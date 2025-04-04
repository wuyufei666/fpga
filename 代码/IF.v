
`include "define.v";
//IF 取指模块
//1、控制PC，程序计数器
 
module IF(
    input wire clk,
    input wire rst, 
    input wire [31:0] jAddr,//J型
    input wire jCe,//J型
    output reg ce, 
    output reg [31:0] pc,
	input wire[31:0] ejpc,	//异常或中断转移地址
	input wire excpt,		//异常或中断有效信号
	input wire[5:0] stall       //流水
);
    always@(*)
        if(rst == `RstEnable)
            ce = `RomDisable;
        else
            ce = `RomEnable;
 
    //程序执行 pc+=4
	//中断-修改
    always@(posedge clk)
        if(ce == `RomDisable)
            pc = `Zero;
	else if(stall[0]==`NoStop)  //流水
		begin
			if(excpt == 1'b1)
				pc <=ejpc;//异常或中断的转移地址更新pc
 			else if(jCe == `Valid)//J型
            			pc = jAddr;
        		else
           			 pc = pc + 4;
		end
endmodule