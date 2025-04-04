
`include "define.v"
module HiLo (
	input wire rst,
	input wire clk ,
	input wire [31:0] wHiData,
	input wire [31:0] wLoData,
	input wire whi ,
	input wire wlo ,
	output reg [31:0] rHiData,
	output reg [31:0] rLoData
);
	reg [31:0]hi,lo;//内部存储
	always@ (*)
		if(rst==`RstEnable)
			begin
				rHiData = `Zero;
				rLoData = `Zero;
			end
		else
			begin
				rHiData = hi;
				rLoData = lo;
			end
	always@(posedge clk)
		if (rst ==`RstDisable && whi==`Valid)
			hi=wHiData;
		else ;
 
	always@(posedge clk)
		if (rst ==`RstDisable && wlo==`Valid)
			lo=wLoData;
		else ;
endmodule