
`include "define.v"
//协处理器模块
module CP0(
	input wire clk,		//时钟信号
	input wire rst,		//复位信号
	input wire cp0we,	//CP0寄存器的写信号
	input wire[4:0] cp0Addr,	//CP0寄存器的地址信号
	input wire[31:0] cp0wData,	//CP0寄存器的写入数据
	output reg[31:0] cp0rData,	//CP0寄存器的读出数据
	input wire[5:0] intr,		//输入硬件中断
	output reg intimer,			//输出定时中断
	input wire[31:0] excptype,//异常和中断的记录信息
	input wire[31:0] pc,		//当前指令地址
	output wire[31:0] cause,	//寄存器Cause的输出值
	output wire[31:0] status	//寄存器Status的输出值
);
	reg[31:0] Count;
	reg[31:0] Compare;
	reg[31:0] Status;
	reg[31:0] Cause;
	reg[31:0] Epc;
	
	assign cause = Cause;
	assign status = Status;
 
	always@(*)
		Cause[15:10]= intr;//对应IP[7:2]
 
	always@(posedge clk)
		if(rst == `RstEnable)
			begin
				Count= `Zero;
				Compare = `Zero;
				Status= 32'h10000000;
				Cause = `ZeroWord;
				Epc = `Zero;
				intimer = `IntrNotOccur;
			end
		else
			begin
				Count = Count + 1;
				if(Compare != `Zero && Count == Compare)
					intimer = `IntrOccur;
				if(cp0we == `Valid)
					case(cp0Addr)
						`CP0_count:
							Count = cp0wData;
						`CP0_compare:
							begin
								Compare = cp0wData;
								intimer = `IntrNotOccur;
							end
						`CP0_status:
							Status = cp0wData;
						`CP0_epc:
							Epc = cp0wData;
						`CP0_cause:
							begin
								Cause[9:8]=cp0wData[9:8];
								Cause[23:22]= cp0wData[23:22];
							end
						default: ;
					endcase
				case(excptype)
					//timerInt
					32'h0000_0004:
						begin
							//interupt instruction
							Epc = pc;
							//Status's Ex1
							Status[1]=1'b1;
							//Cause's ExcCode
							Cause[6:2]= 5'b00000;
						end
					//Syscall
					32'h0000_0100:
						begin
							Epc = pc+ 4;
							Status[1]= 1'b1;
							Cause[6:2]= 5'b01000;
						end
					//Eret
					32'h0000_0200:
						Status[1]=1'b0;
					default : ;
				endcase
			end
	always@(*)
		if(rst==`RstEnable)
			cp0rData= `Zero;
		else
			case(cp0Addr)
				`CP0_count:
					cp0rData = Count ;
				`CP0_compare:
					cp0rData = Compare;
				`CP0_status:
					cp0rData = Status;
				`CP0_epc:
					cp0rData = Epc;
				`CP0_cause:
					cp0rData= Cause;
				default:
					cp0rData= `Zero;
			endcase
endmodule