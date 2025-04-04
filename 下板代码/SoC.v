module SoC(
    input wire clk0,  
    input wire rst,
	/*IO interface*/
	input wire [1:0] sel,
	output reg[10:0] displayout,//
	output wire[15:0] led
);
wire[6:0] out1;
wire[6:0] out2;
wire[6:0] out3;
wire[6:0] out4;
shumaguan U1(out1,led[3:0]);
shumaguan U2(out2,led[7:4]);
shumaguan U3(out3,led[11:8]);
shumaguan U4(out4,led[15:12]);
always@(*)
	begin
	if(led[3:0]>0) displayout={4'b1110,out1};
	else if(led[7:4]>0) displayout={4'b1101,out2};
	else if(led[11:8]>0) displayout={4'b1011,out3};
	else if(led[15:12]>0) displayout={4'b0111,out4};
	end


   wire clk;
 clk_div clk_div0(
        .clk(clk0),
        .rst(rst),
        .Clk_CPU(clk)
    );
    
    

    wire [31:0] instAddr;
    wire [31:0] instruction;
    wire romCe;

	//lw sw
    wire memCe, memWr;    
    wire [31:0] memAddr;
    wire [31:0] rdData;
    wire [31:0] wtData;

	//interupt
	wire[5:0] intr;
	wire intimer;
	assign intr={5'b0,intimer};


	//FPGA
	wire ramCe, ramWe, ioCe, ioWe;
	wire[31:0] ramWtData, ramAddr, ramRdData;
	wire[31:0] ioWtData, ioAddr, ioRdData;	


	
    MIPS mips0(
        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .instAddr(instAddr),
        .romCe(romCe),
	.rdData(rdData),        
    	.wtData(wtData),        
    	.memAddr(memAddr),        
    	.memCe(memCe),        
    	.memWr(memWr),
	.intr(intr),//interupt
	.intimer(intr[0])//interupt
    );	
    

	MIOC mioc0(
		.memCe(memCe),
		.memWr(memWr),
		.memAddr(memAddr),
		.wtData(wtData),
		.rdData(rdData),
		.ramCe(ramCe),
		.ramWe(ramWe),
		.ramAddr(ramAddr),
		.ramRdData(ramRdData),
		.ramWtData(ramWtData),
		.ioCe(ioCe),
		.ioWe(ioWe),
		.ioAddr(ioAddr),
		.ioRdData(ioRdData),
		.ioWtData(ioWtData)
	);


    InstMem instrom0(
        .ce(romCe),
        .addr(instAddr),
        .data(instruction)
    );

/*
	
	DataMem datamem0(       
    	.ce(memCe),    
    	.clk(clk),        
    	.we(memWr),        
    	.addr(memAddr),        
    	.wtData(wtData),        
    	.rdData(rdData)  
	);
*/

	
	DataMem datamem0(
		.ce(ramCe),
		.clk(clk),
		.we(ramWe),
		.addr(ramAddr),
		.rdData(ramRdData),
		.wtData(ramWtData)
	);


	
	IO io0(
		.ce(ioCe),
		.clk(clk),
		.we(ioWe),
		.addr(ioAddr),
		.rdData(ioRdData),
		.wtData(ioWtData),
		.Sel(sel),
		.Button(),
		.Seg(),
		.Led(led)
	);



	

endmodule


