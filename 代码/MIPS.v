
`include "define.v";
//5、MIPS封装
//修改EX实例化，新增Mem实例化
 
//新增端口rdData wtData memAddr memCe memWr
//原op变为op_i
//新增ls内部变量
module MIPS(
    input wire clk,
    input wire rst,
    input wire [31:0] instruction,
    input wire [31:0] rdData,//ls
	output wire romCe,
	output wire [31:0] instAddr,
	output wire [31:0] wtData,//ls
	output wire [31:0] memAddr,//ls
	output wire memCe,//ls
	output wire memWr,//ls
	input wire[5:0] intr,	//硬件中断的输入信号
	output wire intimer		//定时中断的输出信号
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
 
	//J型
	wire [31:0] jAddr;
    wire jCe;
 
	//ls
	wire [5:0] op_ex;
	wire[31:0] memAddr_ex,memData_ex;
	wire [4:0] regAddr_mem;
	wire [31:0] regData_mem;
	wire regWr_mem;
 
	//md-hl
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
 
	//中断
	wire cp0we;
	wire[4:0] cp0Addr;
	wire[31:0] cp0wData;
	wire[31:0] cp0rData;
	wire[31:0] epc_ex , ejpc;
	wire[31:0] excptype_id,excptype_ex;
	wire[31:0] cause, status;
	wire[31:0] pc_id, pc_ex;
    wire regcWrite_o;
    wire [4:0] regcAddr_o;
 
 
	//流水线
	wire stall_id;//from id to ctrl
	wire [5:0] stall_o;//form ctrl to 流水寄存器
 
	//IF_ID输出 ID输入
	wire [31:0] instruction_o_ifid;
 
	//ID输出 ID_EX输入
	wire [31:0] pc_o_id;
	wire[31:0] instruction_o_id;
 
	//ID_EX输出 EX输入
	wire[31:0] instruction_o_idex;
	wire[31:0] excptype_o;
    wire [5:0] op_o; 
	wire[31:0] pc_o;
    wire [31:0] regaData_o, regbData_o; 
	wire regcWrite_o_ex;
	wire [4:0]regcAddr_o_ex; 
 
	//EX输出 EX_MEM输入
	wire [31:0] instruction_o_ex;
 
	//EX_MEM输出 MEM输入
	wire[31:0] instruction_o_exmem;
	wire [31:0] regcData_o_exmem;
	wire regcWrite_o_exmem;
	wire [4:0] regcAddr_o_exmem;
	wire [5:0] op_o_exmem;
	wire [31:0] memAddr_o_exmem;
	wire [31:0] memData_o_exmem;
 
	//MEM 输出 MEM_WB 输入
	wire [31:0] instruction_o_mem;
 
	//MEM_WB 输出 regFile 输入
	wire [31:0] instruction_o_memwb;	
	wire [4:0] regAddr_memwb;
	wire regWr_memwb;
	wire [31:0] regData_memwb;
 
 
	//流水线
	wire[5:0] ex_op;				//ex 反馈 id op码
	wire[4:0] ex_wd_to_id; 			//ex 反馈 id读地址
	wire ex_wreg_to_id;				//ex 反馈 给 id 读信号
	wire [31:0] ex_wdata_to_id; 	//ex 反馈 给 id 读数据
	wire[4:0] mem_wd_to_id; 		//mem 反馈 id读地址
	wire mem_wreg_to_id;			//mem 反馈 给 id 读信号
	wire [31:0] mem_wdata_to_id;  	//mem 反馈 给 id 读数据
 
 
 
 
	//中断修改
	//流水线修改
    IF if0(
        .clk(clk),
        .rst(rst),
		.jAddr(jAddr),//J型
		.jCe(jCe),//J型
        .ce(romCe), 
        .pc(instAddr),
		.ejpc(ejpc),//异常或中断转移地址
		.excpt(excpt),//异常或中断信号
		.stall(stall_o)
    );
 
 
	//流水线-添加
    IF_ID if_id0(
	    .clk(clk),
	    .rst(rst), 
	    .stall(stall_o),		//Ctrl input
	    .pc_i(instAddr), 		//from IF
		.inst_i(instruction),	//from instMem
	    .pc_o(pc_id), 			//to ID
		.inst_o(instruction_o_ifid)	//to ID
	);
 
 
 
 
	//中断修改
	//流水线修改
    ID id0(
        .rst(rst), 
//       .pc(instAddr),//J型
//       .inst(instruction_o),   //流水线修改
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
		.jAddr(jAddr),//J型
		.jCe(jCe),//J型
		.pc_i(pc_id),//pc的输入信号
		.pc(pc_o_id),	//pc的输出信号
		.excptype(excptype_id),//中断或异常的记录信息
		.inst_i(instruction_o_ifid),
		.inst_o(instruction_o_id),
		.stallreq(stall_id),
		.ex_op_i(ex_op),						//ex 反馈 id op码
		.ex_wd_to_id_i(ex_wd_to_id),  			//ex 反馈 id读地址
		.ex_wreg_to_id_i(ex_wreg_to_id),		//ex 反馈 给 id 读信号
		.ex_wdata_to_id_i(ex_wdata_to_id), 		//ex 反馈 给 id 读数据
		.mem_wd_to_id_i(mem_wd_to_id),  		//mem 反馈 id读地址
		.mem_wreg_to_id_i(mem_wreg_to_id),		//mem 反馈 给 id 读信号
		.mem_wdata_to_id_i(mem_wdata_to_id) 	//mem 反馈 给 id 读数据		
    );
 
 
	//流水线-添加
	ID_EX id_ex0(
	    .clk(clk),
	    .rst(rst), 
	    .stall(stall_o),		//from Ctrl
		//id to ID_EX input
		.inst_i(instruction_o_id),
		.excptype_i(excptype_id),
		.op_i(op_id), 
		.pc_i(pc_o_id),		    
	    .regaData_i(regaData_id),
	    .regbData_i(regbData_id),
	    .regcWrite_i(regcWrite_id),
	    .regcAddr_i(regcAddr_id),	
		//ID_EX to EX output 
		.inst_o(instruction_o_idex),
		.excptype_o(excptype_o),
		.op_o(op_o), 
		.pc_o(pc_o),	   
	    .regaData_o(regaData_o),
	    .regbData_o(regbData_o),
	    .regcWrite_o(regcWrite_o_ex),
	    .regcAddr_o(regcAddr_o_ex)
	);
 
	
 
 
    //乘除md-修改EX实例化
	//中断修改
	//流水线修改
    EX ex0(
        .rst(rst),
        //.op(op),    
		.op_i(op_o),    
        .regaData(regaData_o),
        .regbData(regbData_o),
        .regcWrite_i(regcWrite_o_ex),
        .regcAddr_i(regcAddr_o_ex),
		.rHiData(rHiData_ex),//md
		.rLoData(rLoData_ex),//md
        .regcData(regcData_ex),
        .regcWrite(regcWrite_ex),
        .regcAddr(regcAddr_ex),
		.op(op_ex),//ls
		.memAddr(memAddr_ex),//ls
		.memData(memData_ex),//ls
		.whi(whi_ex),//md
		.wlo(wlo_ex),//md
		.wHiData(wHiData_ex),//md
		.wLoData(wLoData_ex),//md
		.cp0we(cp0we),//CPO的写信号
		.cp0Addr(cp0Addr),//CPO的地址信息
		.cp0wData(cp0wData),//CPO的写入数据
		.cp0rData(cp0rData),//CPO的读出数据
		.pc_i(pc_o),//pc的输入值
		.excptype_i(excptype_o),//异常或中断的记录信息输入值
		.excptype(excptype_ex),//异常或中断的记录信息输出值
		.epc(epc_ex),//epc的输出值
		.pc(pc_ex),//pc的输出值
		.cause(cause),//cause的输入值
		.status(status),//status的输入值
		.inst_i(instruction_o_idex),
		.inst_o(instruction_o_ex),
		.ex_op_o(ex_op),			 			//ex 反馈 给 id op码
		.ex_wd_to_id_o(ex_wd_to_id),		 	//ex 反馈 给 id 读地址
		.ex_wreg_to_id_o(ex_wreg_to_id),		//ex 反馈 给 id 读信号
		.ex_wdata_to_id_o(ex_wdata_to_id) 		//ex 反馈 给 id 读数据
    );    
 
	EX_MEM ex_mem0(
		.clk(clk),
	    .rst(rst), 
	    .stall(stall_o),		//from Ctrl
	
		//EX to EX_MEM input
		.inst_i(instruction_o_ex),	//根据数据通路，所有流水寄存器必须要加的
	    .regcData_i(regcData_ex),
	    .regcWrite_i(regcWrite_ex),
	    .regcAddr_i(regcAddr_ex),
		.op_i(op_ex),
	    .memAddr_i(memAddr_ex),
	    .memData_i(memData_ex),
	
		//EX_MEM to MEM output
		.inst_o(instruction_o_exmem),	//根据数据通路，所有流水寄存器必须要加的
	    .regcData_o(regcData_o_exmem),
	    .regcWrite_o(regcWrite_o_exmem),
	    .regcAddr_o(regcAddr_o_exmem),
		.op_o(op_o_exmem),
	    .memAddr_o(memAddr_o_exmem),
	    .memData_o(memData_o_exmem)
	);
 
	//新增HiLo寄存器
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
 
 
	//新增Mem实例化
	//修改Mem实例化 llsc
	//流水线修改
	MEM mem0(
        .rst(rst),		
	    .op(op_o_exmem),
	 	.regcData(regcData_o_exmem),
		.regcAddr(regcAddr_o_exmem),
		.regcWr(regcWrite_o_exmem),
		.memAddr_i(memAddr_o_exmem),
		.memData(memData_o_exmem),	
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
		.wLLbit(wLLbit),//llsc
		.inst_i(instruction_o_exmem),
		.inst_o(instruction_o_mem),
		.mem_wd_to_id_o(mem_wd_to_id),		 		//mem 反馈 给 id 读地址
		.mem_wreg_to_id_o(mem_wreg_to_id),			//mem 反馈 给 id 读信号
		.mem_wdata_to_id_o(mem_wdata_to_id) 	 	//mem 反馈 给 id 读数据
	);
 
	//新增流水线寄存器
	MEM_WB mem_wb0(
	    .clk(clk),
	    .rst(rst), 
	    .stall(stall_o),		//from Ctrl
	
		//MEM to MEM_WB input
		.inst_i(instruction_o_mem),	//根据数据通路，所有流水寄存器必须要加的
		.regAddr(regAddr_mem),
		.regWr(regWr_mem),
		.regData(regData_mem),		
	
		//MEM_WB to regFile output
		.inst_o(instruction_o_memwb),	//根据数据通路，所有流水寄存器必须要加的
	    .we(regWr_memwb),
	    .waddr(regAddr_memwb),
	    .wdata(regData_memwb)		
	);
 
 
	//新增LLbit实例化 llsc
	LLbit llbit0(
		.clk(clk),
		.rst(rst),
		.excpt(excpt),
		.wbit(wbit), 	
		.wLLbit(wLLbit),	
		.rLLbit(rLLbit)
	);
 
	
 
	//修改RegFile实例化
	//流水线修改
    RegFile regfile0(
        .clk(~clk), //下降沿写入
        .rst(rst),
	.inst(instruction_o_memwb),
	.we(regWr_memwb),
	.waddr(regAddr_memwb),
	.wdata(regData_memwb),
        .regaRead(regaRead),
        .regbRead(regbRead),
        .regaAddr(regaAddr),
        .regbAddr(regbAddr),
        .regaData(regaData_regFile),
        .regbData(regbData_regFile)
    );
 
	//中断-新增加模块
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
 
	//中断-新增加模块
	//流水线-修改
	Ctrl ctrl0(
		.rst(rst),
		.ejpc(ejpc),
		.excpt(excpt),
		.excptype(excptype_ex),
		.epc(epc_ex),
		.stall_id(stall_id),  //from id
		.stall_o(stall_o)     //to 流水寄存器
	);
 
endmodule