
module SoC(
    input wire clk,
    input wire rst
);
    wire [31:0] instAddr;
    wire [31:0] instruction;
    wire romCe;

   //ls
    wire memCe, memWr;    
    wire [31:0] memAddr;
    wire [31:0] rdData;
    wire [31:0] wtData;

	//interupt
	wire[5:0] intr;
	wire intimer;
	assign intr={5'b0,intimer};

    MIPS mips0(
	.intr(intr),//
	.intimer(intr[0]),//

        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .instAddr(instAddr),
        .romCe(romCe),
	.rdData(rdData),        
    	.wtData(wtData),        
    	.memAddr(memAddr),        
    	.memCe(memCe),        
    	.memWr(memWr) 
    );	
    
    InstMem instrom0(
        .ce(romCe),
        .addr(instAddr),
        .data(instruction)
    );

	//DataMem
	DataMem datamem0(       
    	.ce(memCe),        
    	.clk(clk),        
    	.we(memWr),        
    	.addr(memAddr),        
    	.wtData(wtData),        
    	.rdData(rdData)  
	);
endmodule

