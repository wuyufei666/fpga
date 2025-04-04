
`include "define.v";
 
module IF_ID(
    input wire clk,
    input wire rst, 
    input wire[5:0] stall,	//Ctrl 
    input wire [31:0] pc_i, //from IF
    input wire[31:0] inst_i,//from instMem
    output reg [31:0] pc_o, //to ID
    output reg [31:0] inst_o//to ID
);
 
 
    always@(posedge clk)
 
        if(rst == `RstEnable)
		begin
        	    	inst_o<=`ZeroWord;
			pc_o<=`ZeroWord;
		end
        else if(stall[1]==`Stop&&stall[2]==`NoStop)
        	begin
            			inst_o<=`ZeroWord;
				pc_o<=`ZeroWord;				
		end
 
        else if(stall[1]==`NoStop)
            begin
            			inst_o<=inst_i;
				pc_o<=pc_i;				
	    end
 
 
endmodule
 