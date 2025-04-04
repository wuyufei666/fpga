`include "define.v"


module IF(
    input wire clk,
    input wire rst, 
    input wire [31:0] jAddr,//J
    input wire jCe,//J
    output reg ce, 
    output reg [31:0] pc,
	input wire[31:0] ejpc,	//interupt
	input wire excpt		//interupt
);
    always@(*)
        if(rst == `RstEnable)
            ce = `RomDisable;
        else
            ce = `RomEnable;

    
	
    always@(posedge clk)
        if(ce == `RomDisable)
            pc = `Zero;
		else if(excpt == 1'b1)
			pc <=ejpc;	//interupt
 		else if(jCe == `Valid)	//J
            pc = jAddr;

        else
            pc = pc + 4;

endmodule

