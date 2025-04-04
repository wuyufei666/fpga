
`include "define.v";
//4、为操作数取值存值模块
//取值 regaData regbData
//存值 wdata
module RegFile(
    input wire clk,
    input wire rst,
    input wire we,
	input wire[31:0] inst, //流水线
    input wire [4:0] waddr,
    input wire [31:0] wdata,
    input wire regaRead,
    input wire regbRead,
    input wire [4:0] regaAddr,
    input wire [4:0] regbAddr,
    output reg [31:0] regaData,
    output reg [31:0] regbData
);
    reg [31:0] reg32 [31 : 0];
 
	initial
		reg32[0]=32'h0000_0000;
    always@(*)
        if(rst == `RstEnable)          
            regaData = `Zero;
        else if(regaAddr == `Zero)
            regaData = `Zero;
        else
            regaData = reg32[regaAddr];
    always@(*)
        if(rst == `RstEnable)          
            regbData = `Zero;
        else if(regbAddr == `Zero)
            regbData = `Zero;
        else	
            regbData = reg32[regbAddr];
    always@(posedge clk)
        if(rst == `RstDisable)
            if((we == `Valid) && (waddr != `Zero))
                reg32[waddr] = wdata;
	    	else ;
        else ;
          
endmodule