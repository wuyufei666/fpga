`include "define.v";
module MIPS(
	//interupt
	input wire[5:0] intr,
	input wire intimer,
	
    	input wire clk,
    	input wire rst,
    	input wire [31:0] instruction,
    	input wire [31:0] rdData,//ls
	output wire romCe,
	output wire [31:0] instAddr,
	output wire [31:0] wtData,//ls
	output wire [31:0] memAddr,//ls
	output wire memCe,//ls
	output wire memWr//ls
);
    	wire [31:0] regaData_regFile, regbData_regFile;
    	wire [31:0] regaData_id, regbData_id; 
    	wire [31:0] regcData_ex;
   	 //wire [5:0] op; 
    	wire [5:0] op_id; //ls  
    	wire regaRead, regbRead;
    	wire [4:0] regaAddr, regbAddr;
    	wire regcWrite_id, regcWrite_ex;
    	wire [4:0] regcAddr_id, regcAddr_ex;

	//J
	wire [31:0] jAddr;
    	wire jCe;

	//ls
	wire [5:0] op_ex;
	wire[31:0] memAddr_ex,memData_ex;
	wire [5:0] regAddr_mem;
	wire [31:0] regData_mem;
	wire regWr_mem;

	//mult div
	wire [31:0] wHiData_ex;
	wire [31:0] wLoData_ex;
	wire whi_ex;
	wire wlo_ex;
	wire [31:0] rHiData_ex;
	wire [31:0] rLoData_ex;

	//ll sc
	wire wbit;
	wire wLLbit;
	wire rLLbit;
	wire excpt;
	//interupt
	wire cp0we;
	wire[4:0] cp0Addr;
	wire[31:0] cp0wData;
	wire[31:0] cp0rData;
	wire[31:0] epc_ex;
	wire[31:0] ejpc;
	wire[31:0] excptype_id,excptype_ex;
	wire[31:0] cause,status;
	wire[31:0] pc_id,pc_ex;
	

    IF if0(
        .clk(clk),
        .rst(rst),
	.jAddr(jAddr),//J
	.jCe(jCe),//J
        .ce(romCe), 
        .pc(instAddr),
	.ejpc(ejpc),  //interupt
	.excpt(excpt)  //interupt
    );
    ID id0(
        .rst(rst), 
       	//.pc(instAddr),//J
	.pc_i(instAddr),   //interupt
	.pc(pc_id),
	.excptype(excptype_id),   //interupt

        .inst(instruction),
        .regaData_i(regaData_regFile),
        .regbData_i(regbData_regFile),
        //.op(op),
	.op(op_id),//ls
        .regaData(regaData_id),
        .regbData(regbData_id),
        .regaRead(regaRead),
        .regbRead(regbRead),
        .regaAddr(regaAddr),
        .regbAddr(regbAddr),
        .regcWrite(regcWrite_id),
        .regcAddr(regcAddr_id),
	.jAddr(jAddr),//J
	.jCe(jCe)//J

    );

    EX ex0(

	//intertupt
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
	.status(status),

        .rst(rst),
        //.op(op),    
	.op_i(op_id),    
        .regaData(regaData_id),
        .regbData(regbData_id),
        .regcWrite_i(regcWrite_id),
        .regcAddr_i(regcAddr_id),
        .regcData(regcData_ex),
        .regcWrite(regcWrite_ex),
        .regcAddr(regcAddr_ex),
	.op(op_ex),//ls
	.memAddr(memAddr_ex),//ls
	.memData(memData_ex),//ls


	.rHiData(rHiData_ex),
	.rLoData(rLoData_ex),
	.whi(whi_ex),
	.wlo(wlo_ex),
	.wHiData(wHiData_ex),
	.wLoData(wLoData_ex) 
    );    
	HiLo hilo0(
		.rst(rst),
		.clk(clk),
		.rHiData(rHiData_ex),
		.rLoData(rLoData_ex),
		.whi(whi_ex),
		.wlo(wlo_ex),
		.wHiData(wHiData_ex),
		.wLoData(wLoData_ex) 
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
		.regAddr(regAddr_mem),
		.regWr(regWr_mem),
		.regData(regData_mem),	
		.memAddr(memAddr),
		.wtData(wtData),
		.memWr(memWr),	
		.memCe(memCe),
		//
		.rLLbit(rLLbit),
		.wbit(wbit),
		.wLLbit(wLLbit)
	);

	LLbit llbit0(
		.rst(rst),
		.clk(clk),
		.wbit(wbit),
		.wLLbit(wLLbit),
		.rLLbit(rLLbit),
		.excpt(excpt)
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

endmodule

