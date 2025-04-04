`include "define.v"
module LLbit(
	input wire clk,
	input wire rst,
	input wire excpt,
	input wire wbit, 	
	input wire wLLbit,	
	output reg rLLbit	
);

	reg LLbit; 

	always@(*)
        if(rst == `RstEnable)
            rLLbit = `Zero;
        else
            rLLbit = LLbit;

    
    always@(posedge clk)
        if(rst ==`RstDisable && wbit==`Valid)
            LLbit=wLLbit;
        else ;

endmodule

