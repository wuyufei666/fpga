`include "define.v"

module IO(
	input wire ce,
	input wire clk,
	input wire we,
	input wire[31:0]addr,
	input wire[31:0]wtData,
	output reg[31:0]rdData,
	/*IO interface*/   
	input wire [1:0] Sel,
	input wire [31:0] Button,
	output reg[31:0] Seg,
	output reg [15:0] Led	

);

	/*access IO device*/
/*
    reg [31:0] iomem [1023 : 0];
    always@(*)      
        if(ce == `RamDisable)
          rdData = `Zero;
        else
          rdData = iomem[addr[11 : 2]]; 
    always@(posedge clk)
        if(ce == `RamEnable && we == `RamWrite)
            iomem[addr[11 : 2]] = wtData;
        else ;

*/

	//read
	always@(*)
		if(ce == `IODisable)
			rdData = `Zero;
		else if(we == `IOUnWrite)
			case(addr)
				`KEY:
					begin 
						//rdData = {16{Sel}};
						rdData = {30'h0,Sel};
					 end
				`BUTTON: 
					begin rdData = Button; end
			endcase

	//write
	always@(posedge clk)
		if(ce == `IOEnable && we == `IOWrite)
			case(addr)
				`SEG:
					begin Seg = wtData; end
				`LED: 
					begin Led = wtData[15:0];end
			endcase
		else ;


endmodule

