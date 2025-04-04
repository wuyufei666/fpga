
`include "define.v"
module Ctrl(
	input wire rst,				
	input wire[31:0] excptype,	
	input wire [31:0] epc,		
	output reg [31:0] ejpc,		
	output reg excpt			
);
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
						ejpc = 32'h00000050;//20 instMem
					//Syscall
					32'h0000_0100:
						ejpc= 32'h00000040;//16 instMem  中断服务程序首地址
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
