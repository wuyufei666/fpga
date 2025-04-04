
`include "define.v"
//控制模块
module Ctrl(
	input wire rst,				//复位信号
	input wire[31:0] excptype,	//异常或中断信息记录
	input wire [31:0] epc,		//输入epc的值，用于eret 指令
	output reg [31:0] ejpc,		//输出ejpc的值
	output reg excpt,			//中断或异常有效信号
	input stall_id,  			//from id
	output reg[5:0] stall_o    //to 流水寄存器
);
 
 
 
 
/*
	//左移寄存器
	always@(*)
		if(rst == `RstEnable)
			stall_o=6'b0;
		else
			stall_o={stall_o[4:0],stall_id};
*/
/*
	reg f=1;
	//循环左移寄存器
	always@(*)
		if(rst == `RstEnable)
			stall_o=6'b0;
		else
			{f,stall_o}={stall_o[4:0],stall_id,f};
*/
 
	always@(*)
		if(rst == `RstEnable)
			stall_o=6'b0;
		else
			stall_o={stall_o[5:2],stall_id,stall_id};
	always@(*)
		if(rst == `RstEnable)
			begin
				excpt = `Invalid;
				ejpc = `Zero;
			end
		else
			begin
				excpt = `Valid;
				case(excptype)
					//timerInt
					32'h0000_0004:
						ejpc = 32'h00000050;//自己指定：中断服务地址 50h右移2位(即除以4)=20 instMem
					//Syscall
					32'h0000_0100:
						ejpc= 32'h00000040;//自己指定：中断服务地址 40h右移2位(即除以4)=16 instMem
					//Eret
					32'h0000_0200:
						ejpc = epc;
					default:
						begin
							ejpc= `Zero;
							excpt = `Invalid;
						end
				endcase
			end
endmodule