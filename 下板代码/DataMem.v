`include "define.v"
module DataMem(
        input wire clk,
        input wire ce,
        input wire we,
        input wire [31:0] addr,
        input wire [31:0] wtData,
        output reg [31:0] rdData
);

    reg [31:0] datamem [1023 : 0];
    always@(*)      
        if(ce == `RamDisable)
          rdData = `Zero;
        else
          rdData = datamem[addr[11 : 2]]; 
    always@(posedge clk)
        if(ce == `RamEnable && we == `RamWrite)
            datamem[addr[11 : 2]] = wtData;
        else ;

endmodule

