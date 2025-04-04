
`include "define.v"
//3、执行指令模块
 
module EX (
        input wire rst,
        //input wire [5:0] op,   
		input wire [5:0] op_i,      
        input wire [31:0] regaData,
        input wire [31:0] regbData,
        input wire regcWrite_i,
        input wire [4:0] regcAddr_i,
        input wire [31:0] rHiData,//乘除 读hi数据
        input wire [31:0] rLoData,//乘除 读hi数据
        output reg [31:0] regcData,
        output wire regcWrite,
        output wire [4:0] regcAddr,
		output wire [5:0] op,
    	output wire [31:0] memAddr,
    	output wire [31:0] memData,
    	output reg whi,	//乘除 写hi使能
   		output reg wlo,	//乘除 写lo使能
   		output reg [31:0] wHiData,	//乘除 写hi数据
   		output reg [31:0] wLoData,  //乘除 写lo数据
		output reg cp0we,			//CPO寄存器的写信号
		output reg [4:0] cp0Addr,	//CPO寄存器的地址信号
		output reg [31:0] cp0wData,	//CPO寄存器的写入数据
		input wire[31:0] cp0rData,	//CPO寄存器的读出数据
		input wire[31:0] pc_i,		//当前指令地址
		input wire [31:0] excptype_i,//输入的异常或中断信息记录
		output reg [31:0] excptype,	//输出的异常或中断信息记录
		output wire [31:0] epc,		//输出的epc值，用于eret 指令
		output wire [31:0] pc,		//输出的pc值，用于异常或中断响应
		input wire [31:0] cause,	//输入的cause寄存器值
		input wire [31:0] status,	//输入的status寄存器值
		input wire[31:0] inst_i, 	//接受
		output reg[31:0] inst_o,	//传送
		output reg[5:0] ex_op_o,			 //ex 反馈 给 id op码
		output reg [4:0] ex_wd_to_id_o,		 //ex 反馈 给 id 读地址
		output reg ex_wreg_to_id_o,			 //ex 反馈 给 id 读信号
		output reg [31:0] ex_wdata_to_id_o 	 //ex 反馈 给 id 读数据
    );    
 
	assign op = op_i;
    assign memAddr = regaData;
    assign memData = regbData;
 
	//中断
	assign pc = pc_i;
	//还是需要给MEM传送指令的 LLbit<-0
//	assign op = (excptype == `ZeroWord) ?
//				 op_i : `Nop;
	assign regcWrite =(excptype == `ZeroWord) ?
				 regcWrite_i : `Invalid;
 
 
    always@(*)
		inst_o=inst_i;
 
	always@(*)
		begin
			ex_op_o=op_i;
			ex_wd_to_id_o=regcAddr;
			ex_wreg_to_id_o=regcWrite;
			ex_wdata_to_id_o=regcData;
		end
 
	always@(*)
        if(rst == `RstEnable)
			begin
              	regcData = `Zero;
				whi=`Invalid;
				wlo=`Invalid;
			  	wHiData=`Zero;
			  	wLoData=`Zero;
 
			end
        else
		  begin
            regcData = `Zero;
			whi=`Invalid;
			wlo=`Invalid;
       		wHiData=`Zero;
			wLoData=`Zero;
			cp0we=`Invalid;
			cp0wData= `Zero;
			cp0Addr =`CP0_epc;  
            //case(op)
            case(op_i)
                `Or:
                    regcData = regaData | regbData;
				`And:
		    		regcData = regaData & regbData;
				`Xor:
		    		regcData = regaData ^ regbData;
				`Add:
		    		regcData = regaData + regbData;
				`Sub:
		    		regcData = regaData - regbData;
				`Lui:
					begin
		    			regcData = regaData | regbData;
					end
      
             	`Sll:
                	regcData = regbData << regaData;
              	`Srl:
                	regcData = regbData >> regaData;
				`Sra:
					regcData = ($signed(regbData)) >>> regaData;
				
				//J- JR型
				`J:
					regcData = `Zero;
				`Jal:
                    regcData = regbData;//regaData有其他用处  jr给pc=jaddr=(rs)
 
				//J+型
				`Beq:
					regcData = `Zero;
				`Bne:
					regcData = `Zero;
				`Bltz:
					regcData = `Zero;
				`Bgtz:
					regcData = `Zero;
				//12条整数指令
				`Slt:
		    			regcData = ($signed(regaData)<$signed(regbData))?1'b1:1'b0;

					
				//乘除指令
				`Mult:
					begin
						whi=`Valid;
						wlo=`Valid;
						{wHiData,wLoData}=
							$signed(regaData)*$signed(regbData);
					end
				`Multu:
					begin
						whi=`Valid;
						wlo=`Valid;
						{wHiData,wLoData}=regaData*regbData;
					end
				`Div:
					begin
						whi=`Valid;
						wlo=`Valid;
						wHiData=$signed(regaData)%$signed(regbData);
						wLoData=$signed(regaData)/$signed(regbData);
					end
				`Divu:
					begin
						whi=`Valid;
						wlo=`Valid;
						wHiData=regaData%regbData;
						wLoData=regaData/regbData;
					end
				//剩余4条指令
				`Mfhi:				
					regcData = rHiData;
				`Mflo:				
					regcData = rLoData;
				`Mthi:		
					begin		
						whi=`Valid;
						wHiData = regaData;
					end
				`Mtlo:		
					begin		
						wlo=`Valid;		
						wLoData = regaData;
					end
 
				//中断
				`Mfc0:
					begin
						cp0Addr = regaData[4:0];
						regcData = cp0rData;
					end
				`Mtc0:
					begin
						regcData= `Zero;
						cp0we = `Valid;
						cp0Addr = regaData[4:0];
						cp0wData = regbData;
					end
                default:
                    regcData = `Zero;
            endcase    
		  end
	/*增加关于中断查询和响应的代码*/
	//tips:cp0rData默认读出的是epc的地址
	assign epc = (excptype == 32'h0000_0200) ? cp0rData : `Zero;
 
	always@(*)
		if(rst ==`RstEnable)
			excptype = `Zero;
			//Cause's IP[2] Status's IM[2]; Status EXL, IE
		else if(cause[10]&& status[10]== 1'b1 && status[1:0] == 2'b01)
			//timerInt
			excptype = 32'h0000_0004;
		else if(excptype_i[8] == 1'b1 && status[1] == 1'b0)
			//Syscall
			excptype = 32'h00000100;
		else if(excptype_i[9]== 1'b1)
			//Eret
			excptype = 32'h0000_0200;
		else
			excptype = `Zero;
  
	assign regcWrite = regcWrite_i;
	assign regcAddr = regcAddr_i;
 
 
 
 
endmodule