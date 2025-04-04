
//7、系统封装
//整合MIPS DataMem InstMem
//端口信号只需clk rst，其余信号在MIPS中增加，并且新增使用内部信号连线
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
 
	//中断
	wire[5:0] intr;
	wire intimer;
	assign intr={5'b0,intimer};
	//修改MIPS实例
	//中断-修改
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
		.intr(intr),//中断
		.intimer(intr[0])//中断
    );	
    
    InstMem instrom0(
        .ce(romCe),
        .addr(instAddr),
        .data(instruction)
    );
	//新增DataMem实例化
	DataMem datamem0(       
    	.ce(memCe),        
    	.clk(clk),        
    	.we(memWr),        
    	.addr(memAddr),        
    	.wtData(wtData),        
    	.rdData(rdData)  
	);
endmodule