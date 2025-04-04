`include "define.v"
module MIPS(
    input wire clk,
    input wire rst,
    input wire [31:0] instruction,
    input wire [31:0] rdData,		//lw sw
	output wire romCe,
	output wire [31:0] instAddr,
	output wire [31:0] wtData,	//lw sw
	output wire [31:0] memAddr,	//lw sw
	output wire memCe,		//lw sw
	output wire memWr,		//lw sw
	input wire[5:0] intr,		//interupt
	output wire intimer		//interupt
);
    wire [31:0] regaData_regFile, regbData_regFile;
    wire [31:0] regaData_id, regbData_id; 
    wire [31:0] regcData_ex;
    //wire [5:0] op; 
    wire [5:0] op_id; //lw sw  
    wire regaRead, regbRead;
    wire [4:0] regaAddr, regbAddr;
    wire regcWrite_id, regcWrite_ex;
    wire [4:0] regcAddr_id, regcAddr_ex;

	//J
	wire [31:0] jAddr;
    	wire jCe;

	//lw sw
	wire [5:0] op_ex;
	wire[31:0] memAddr_ex,memData_ex;
	wire [4:0] regAddr_mem;
	wire [31:0] regData_mem;
	wire regWr_mem;

	//mult div
	wire [31:0] wHiData_ex;
	wire [31:0] wLoData_ex;
	wire whi;
	wire wlo;
	wire [31:0] rHiData_ex;
	wire [31:0] rLoData_ex;

	//llsc
	wire excpt;
	wire wbit;
	wire wLLbit;
	wire rLLbit;

	//interupt
	wire cp0we;
	wire[4:0] cp0Addr;
	wire[31:0] cp0wData;
	wire[31:0] cp0rData;
	wire[31:0] epc_ex , ejpc;
	wire[31:0] excptype_id,excptype_ex;
	wire[31:0] cause, status;
	wire[31:0] pc_id, pc_ex;


    IF if0(
        .clk(clk),
        .rst(rst),
	.jAddr(jAddr),//J
	.jCe(jCe),//J
        .ce(romCe), 
        .pc(instAddr),
	.ejpc(ejpc),//interupt
	.excpt(excpt)//interupt
    );

	
    ID id0(
        .rst(rst), 
//       .pc(instAddr),//J
        .inst(instruction),
        .regaData_i(regaData_regFile),
        .regbData_i(regbData_regFile),
        //.op(op),
	.op(op_id),//lw sw
        .regaData(regaData_id),
        .regbData(regbData_id),
        .regaRead(regaRead),
        .regbRead(regbRead),
        .regaAddr(regaAddr),
        .regbAddr(regbAddr),
        .regcWrite(regcWrite_id),
        .regcAddr(regcAddr_id),
	.jAddr(jAddr),//J
	.jCe(jCe),//J
	.pc_i(instAddr),//interupt
	.pc(pc_id),	//interupt
	.excptype(excptype_id)//interupt
    );

  
    EX ex0(
        .rst(rst),
        //.op(op),    
	.op_i(op_id),    
        .regaData(regaData_id),
        .regbData(regbData_id),
        .regcWrite_i(regcWrite_id),
        .regcAddr_i(regcAddr_id),
	//mult div
	.rHiData(rHiData_ex),
	.rLoData(rLoData_ex),
	.whi(whi_ex),
	.wlo(wlo_ex),
	.wHiData(wHiData_ex),
	.wLoData(wLoData_ex),
        .regcData(regcData_ex),
        .regcWrite(regcWrite_ex),
        .regcAddr(regcAddr_ex),
	//lw sw
	.op(op_ex),
	.memAddr(memAddr_ex),
	.memData(memData_ex),
	
	//interupt
	.cp0we(cp0we),
	.cp0Addr(cp0Addr),
	.cp0wData(cp0wData),
	.cp0rData(cp0rData),
	.pc_i(pc_id),
	.excptype_i(excptype_id),
	.excptype(excptype_ex),
	.epc(epc_ex),
	.pc(pc_ex),
	.cause(cause),
	.status(status)
    );    

	
	HiLo hilo0(
		.rst(rst),
		.clk(clk),
		.wHiData(wHiData_ex),
		.wLoData(wLoData_ex),
		.whi(whi_ex),
		.wlo(wlo_ex),
		.rHiData(rHiData_ex),
		.rLoData(rLoData_ex)
	);

	MEM mem0(
        .rst(rst),		
	    .op(op_ex),
	 	.regcData(regcData_ex),
		.regcAddr(regcAddr_ex),
		.regcWr(regcWrite_ex),
		.memAddr_i(memAddr_ex),
		.memData(memData_ex),	
		.rdData(rdData),
		.rLLbit(rLLbit),//llsc
		.regAddr(regAddr_mem),
		.regWr(regWr_mem),
		.regData(regData_mem),	
		.memAddr(memAddr),
		.wtData(wtData),
		.memWr(memWr),	
		.memCe(memCe),
		.wbit(wbit),   //llsc
		.wLLbit(wLLbit)//llsc
	);

	
	LLbit llbit0(
		.clk(clk),
		.rst(rst),
		.excpt(excpt),
		.wbit(wbit), 	
		.wLLbit(wLLbit),	
		.rLLbit(rLLbit)
	);

	

	
    RegFile regfile0(
        .clk(clk),
        .rst(rst),
        //.we(regcWrite_ex),
	.we(regWr_mem),
        //.waddr(regcAddr_ex),
	.waddr(regAddr_mem),
        //.wdata(regcData_ex),
	.wdata(regData_mem),
        .regaRead(regaRead),
        .regbRead(regbRead),
        .regaAddr(regaAddr),
        .regbAddr(regbAddr),
        .regaData(regaData_regFile),
        .regbData(regbData_regFile)
    );

	
	CP0 cp0(
		.clk(clk),
		.rst(rst),
		.cp0we(cp0we),
		.cp0wData(cp0wData),
		.cp0Addr(cp0Addr),
		.cp0rData(cp0rData),
		.intr(intr),
		.intimer(intimer),
		.pc(pc_ex),
		.excptype(excptype_ex),
		.cause(cause),
		.status(status)
	);

	
	Ctrl ctrl0(
		.rst(rst),
		.ejpc(ejpc),
		.excpt(excpt),
		.excptype(excptype_ex),
		.epc(epc_ex)
	);

endmodule

