
`timescale 1ns / 1ps

module clk_div(input clk,
					input rst,
					output Clk_CPU
					);
					


    reg[31:0]clkdiv;
	always @ (posedge clk or posedge rst) begin 
		if (rst) clkdiv <= 0; else clkdiv <= clkdiv + 1'b1; end
		
	//assign Clk_CPU = clkdiv[24] ;
	assign Clk_CPU = clkdiv[22] ;
		
endmodule


