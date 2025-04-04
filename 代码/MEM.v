
`include "define.v";
//访存（mem）模块设计
module MEM(
	input wire rst,		
	input wire [5:0] op,
	input wire [31:0] regcData,
	input wire [4:0] regcAddr,
	input wire regcWr,
	input wire [31:0] memAddr_i,
	input wire [31:0] memData,	
	input  wire [31:0] rdData,
	input wire rLLbit,		//llsc
	output wire [4:0]  regAddr,
	output wire regWr,
	output wire [31:0] regData,	
	output wire [31:0] memAddr,
	output reg [31:0] wtData,
	output reg memWr,	
	output reg memCe,
	output reg wbit,		//llsc
	output reg wLLbit,		//llsc
 
	input wire[31:0] inst_i, 	//接受
	output reg[31:0] inst_o, 	//传送
 
	output reg [4:0] mem_wd_to_id_o,		 //mem 反馈 给 id 读地址
	output reg mem_wreg_to_id_o,			 //mem 反馈 给 id 读信号
	output reg [31:0] mem_wdata_to_id_o 	 //mem 反馈 给 id 读数据
	
);
 
	assign regAddr = regcAddr;    
	assign regWr = regcWr;    
//	assign regData = (op == `Lw) ? rdData : regcData;    
 
	//因为regData是wire型的，所以为了不修改原来的代码，就不使用always
	//而是修改regcData的值，来传到regData
 
 
	//二选一，选出Sc指令的rt<-1或rt<0
	wire [31:0]regDataLL= (rLLbit==`SetFlag) ? 32'b1 : 32'b0; 
	//二选一，存往regFile的值 sc指令存的值regcDataLL 还是  寄存器传入的值regcData
	wire [31:0]regcDataLL=  (op == `Sc ) ? regDataLL : regcData;
	//二选一，存往regFile的值 lw取得的值rdData 还是 寄存器传入的值regcData
    assign regData = (op == `Lw) ? rdData : regcDataLL;  
 
	assign memAddr = memAddr_i;
	
 
    always@(*)
		inst_o=inst_i;
 
	always@(*)
		begin
			mem_wd_to_id_o=regcAddr;
			mem_wreg_to_id_o=regcWr;
			mem_wdata_to_id_o=regData;
		end
 
	always @ (*)        
	    if(rst == `RstEnable)          
	      begin            
	          wtData = `Zero;            
	          memWr = `RamUnWrite;            
	          memCe = `RamDisable;  
			  wbit=	`Invalid;
   			  wLLbit=`ClearFlag;
	      end        
		else
		  begin
	        wtData = `Zero;            
	        memWr = `RamUnWrite;            
	        memCe = `RamDisable;  
			wbit=	`Invalid;
   			wLLbit=`ClearFlag;
 
			case(op)                
			    `Lw:                  
			      begin                    
			         wtData = `Zero;                        
			         memWr = `RamUnWrite;                     
			         memCe = `RamEnable;                    
			      end                
			    `Sw:                  
			      begin                    
			         wtData = memData;                    
			         memWr = `RamWrite;                      
			         memCe = `RamEnable;                   
			     end
 
				//Ll Sc
				`Ll:
					begin		
						//rt<-datamem[addr]
						//不需要写到DataMem中
			         	wtData = `Zero;                  
			         	memWr = `RamUnWrite;                     
			         	memCe = `RamEnable; 
    					//LLbit<-1
						wbit=`Valid;
						wLLbit = `SetFlag;
					end
				`Sc:
					begin	
						if(rLLbit==`SetFlag)
							begin	
								//datamem[addr]<-rt
			         			wtData = memData;                    
			         			memWr = `RamWrite;                      
			        			memCe = `RamEnable;    
								//rt<-1
								//在EX中实现
								//LLbit<-0
								wbit=`Valid;
								wLLbit = `ClearFlag;
							end
						else
							begin
								//把rt<-0
								//在Mem前面对regcData处理来实现
							end
					end
 
 
				`Syscall:
					begin
						//LLbit<-0
						wbit=`Valid;
						wLLbit = `ClearFlag;
					end
 
				`Eret:
					begin
						//LLbit<-0
						wbit=`Valid;
						wLLbit = `ClearFlag;
					end
 
 
 
 
				default:                  
				    begin                    
				        wtData = `Zero;                    
				        memWr = `RamUnWrite;                    
				        memCe = `RamDisable;  
				 		wbit=	`Invalid;
	   			  		wLLbit=`ClearFlag;                
				    end             
			endcase
		  end
endmodule
 
 
 