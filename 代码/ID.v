
`include "define.v";
 
//ID 译码模块
//2、为操作数做准备
module  ID (
    input wire rst,    
//	input wire [31:0] pc,	//J型
//    input wire [31:0] inst,
    input wire [31:0] regaData_i,
    input wire [31:0] regbData_i,
    output reg [5:0] op,    
    output reg [31:0] regaData,
    output reg [31:0] regbData,
    output reg regaRead,
    output reg regbRead,
    output reg regcWrite,
    output reg [4:0] regaAddr,
    output reg [4:0] regbAddr,    
    output reg [4:0] regcAddr,
	output reg [31:0] jAddr,	//J型
    	output reg jCe,//J型
	input wire [31:0] pc_i,		//将原来输入pc变为pc_i
	output wire[31:0] pc,		//新增输出pc
	output wire[31:0] excptype,	//异常信息记录
	
	input wire[31:0] inst_i, 	//接受
	output reg[31:0] inst_o, 	//传送
	output wire stallreq,		//to Ctrl

	input wire[5:0] ex_op_i,			//ex 反馈 id op码
	input wire[4:0] ex_wd_to_id_i,  		//ex 反馈 id读地址
	input wire ex_wreg_to_id_i,			//ex 反馈 给 id 读信号
	input wire [31:0] ex_wdata_to_id_i, 		//ex 反馈 给 id 读数据
	
	input wire[4:0] mem_wd_to_id_i,  		//mem 反馈 id读地址
	input wire mem_wreg_to_id_i,			//mem 反馈 给 id 读信号
	input wire [31:0] mem_wdata_to_id_i  		//mem 反馈 给 id 读数据
);
 
	//方便修改
	reg [31:0] inst;
 
	
	//锁存器
	always@(*)
		if(rst!=`RstEnable)
			if(inst_i!=`ZeroWord)
				inst=inst_i;
			else ;
		else ;
	always@(*)
		inst_o=inst;	
 
 
    //操作指令
    wire [5:0] inst_op = inst[31:26];   
    //扩展的立即数 
    reg [31:0] imm;
	//用于R型指令
    wire[5:0] func = inst[5:0]; 
	//用于J型指令
	wire [31:0] npc = pc + 4;
	//中断
	reg is_syscall;
	reg is_eret;
	assign pc = pc_i;
	assign excptype= {22'b0, is_eret, is_syscall,8'b0};
 
	//流水线
	reg stall_for_rega_loadreleate;
	reg stall_for_regb_loadreleate;
	wire pre_inst_is_load;
 
	
	assign stallreq=stall_for_rega_loadreleate|stall_for_regb_loadreleate;
	assign pre_inst_is_load =(ex_op_i==`Lw)?1'b1:1'b0;
 
 
    always@(*)
		inst_o=inst_i;
	
 
 
 
 
    always@(*)
        if(rst == `RstEnable)
          	 begin
            	op = `Nop;            
	            regaRead = `Invalid;
	            regbRead = `Invalid;
	            regcWrite = `Invalid;
	            regaAddr = `Zero;
	            regbAddr = `Zero;
	            regcAddr = `Zero;
	            imm    = `Zero;
				jCe = `Invalid;//J型
	            jAddr = `Zero;//J型
				is_eret = `Invalid;//中断
				is_syscall = `Invalid;//中断
 
          	 end
		else if(inst == `Inst_eret)
			 begin
				op =`Eret;
				regaRead = `Invalid;
				regbRead = `Invalid;
				regcWrite= `Invalid;
				regaAddr = `Zero;
				regbAddr = `Zero;
				regcAddr = `Zero;
				imm= `Zero;
				jCe=`Invalid;
				jAddr=`Zero;
				is_eret = `Valid;
				is_syscall = `Invalid;
			  end
		else if(inst == `Inst_syscall)
			  begin
				op = `Syscall;
				regaRead = `Invalid;
				regbRead= `Invalid;
				regcWrite = `Invalid;
				regaAddr = `Zero;
				regbAddr = `Zero;
				regcAddr = `Zero;
				imm= `Zero;
				jCe=`Invalid;
				jAddr=`Zero;
				is_eret = `Invalid;
				is_syscall = `Valid;
			  end
 
 
		else 
			begin//后面的end
			    jCe = `Invalid;//J型
		        jAddr = `Zero;//J型
				is_eret = `Invalid;//中断
				is_syscall = `Invalid;//中断
 
	          	case(inst_op)
					`Inst_cp0:
						case(inst[25:21])
							`Inst_mfc0:
								begin
									op = `Mfc0;
									regaRead = `Invalid;
									regbRead = `Invalid;
									regcWrite = `Valid;
									regaAddr = `Zero;
									regbAddr = `Zero;
									regcAddr = inst[20:16];
									imm= {27'h0, inst[15:11]};
								end
							`Inst_mtc0:
								begin
									op =`Mtc0;
									regaRead = `Invalid;
									regbRead = `Valid;
									regcWrite = `Invalid;
									regaAddr = `Zero;
									regbAddr = inst[20:16];
									regcAddr = `Zero;
									imm= {27'h0, inst[15:11]};
								end
								
							default:
								begin
									op= `Nop;
									regaRead = `Invalid;
									regbRead = `Invalid;
									regcWrite = `Invalid;
									regaAddr = `Zero;
									regbAddr = `Zero;
									regcAddr = `Zero;
									imm= `Zero;
								end
						endcase
 
	               	`Inst_ori:
	                 	begin
		                    op = `Or;                    
		                    regaRead = `Valid;
		                    regbRead = `Invalid;
		                    regcWrite = `Valid;
		                    regaAddr = inst[25:21];
		                    regbAddr = `Zero;
		                    regcAddr = inst[20:16];
		                    imm = {16'h0, inst[15:0]};
	                  	end
				    `Inst_andi:
			  		  	begin
		                    op = `And;                    
		                    regaRead = `Valid;
		                    regbRead = `Invalid;
		                    regcWrite = `Valid;
		                    regaAddr = inst[25:21];
		                    regbAddr = `Zero;
		                    regcAddr = inst[20:16];
		                    imm = {16'h0, inst[15:0]};
		                end
					`Inst_xori:
			 			begin
		                    op = `Xor;                    
		                    regaRead = `Valid;
		                    regbRead = `Invalid;
		                    regcWrite = `Valid;
		                    regaAddr = inst[25:21];
		                    regbAddr = `Zero;
		                    regcAddr = inst[20:16];
		                    imm = {16'h0, inst[15:0]};
	                  	end
	
					`Inst_addi:
				  		begin
		                    op = `Add;                    
		                    regaRead = `Valid;
		                    regbRead = `Invalid;
		                    regcWrite = `Valid;
		                    regaAddr = inst[25:21];
		                    regbAddr = `Zero;
		                    regcAddr = inst[20:16];
		                    imm = {{16{inst[15]}}, inst[15:0]};
		                end
//					`Inst_subi:
//					 	begin
//		                    op = `Sub;                    
//		                    regaRead = `Valid;
//		                    regbRead = `Invalid;
//		                    regcWrite = `Valid;
//		                    regaAddr = inst[25:21];
//		                    regbAddr = `Zero;
//		                    regcAddr = inst[20:16];
//		                    imm = {{16{inst[15]}}, inst[15:0]};
//	                    end
					`Inst_lui:
					  	begin
		                    op = `Lui;                    
		                    regaRead = `Valid;
		                    regbRead = `Invalid;
		                    regcWrite = `Valid;
		                    regaAddr = inst[25:21];
		                    regbAddr = `Zero;
		                    regcAddr = inst[20:16];
		                    imm = {inst[15:0],16'h0};
	                  	end
					`Inst_reg:
	        		    case(func)
		                	`Inst_add:
			                    begin
			                        op = `Add;  
				                    regaRead = `Valid;
				                    regbRead = `Valid;
				                    regcWrite = `Valid;
				                    regaAddr = inst[25:21];
				                    regbAddr = inst[20:16];
								    regcAddr = inst[15:11];
				                    imm = `Zero;
			                    end
	
							`Inst_or:
								begin
								    op = `Or;
								    regaRead = `Valid;
								    regbRead = `Valid;
								    regcWrite = `Valid;
								    regaAddr = inst[25:21];
								            regbAddr = inst[20:16];
								            regcAddr = inst[15:11];
								            imm = `Zero;
								        end
	
								`Inst_sub:
								        begin
								            op = `Sub;
								            regaRead = `Valid;
								            regbRead = `Valid;
								            regcWrite = `Valid;
								            regaAddr = inst[25:21];
								            regbAddr = inst[20:16];
								            regcAddr = inst[15:11];
								            imm = `Zero;
								        end
	
								`Inst_and:
								        begin
								            op = `And;
								            regaRead = `Valid;
								            regbRead = `Valid;
								            regcWrite = `Valid;
								            regaAddr = inst[25:21];
								            regbAddr = inst[20:16];
								            regcAddr = inst[15:11];
								            imm = `Zero;
								        end
	
	
								`Inst_xor:
								        begin
								            op = `Xor;
								            regaRead = `Valid;
								            regbRead = `Valid;
								            regcWrite = `Valid;
								            regaAddr = inst[25:21];
								            regbAddr = inst[20:16];
								            regcAddr = inst[15:11];
								            imm = `Zero;
								        end
	
	
								`Inst_sll:
								        begin
								            op = `Sll;
								            regaRead = `Invalid;
								            regbRead = `Valid;
								            regcWrite = `Valid;
								            regaAddr = `Zero;
								            regbAddr = inst[20:16];
								            regcAddr = inst[15:11];
								            imm = {27'b0,inst[10:6]};//移位复用imm
								        end
	
								`Inst_srl:
								        begin
								            op = `Srl;
								            regaRead = `Invalid;
								            regbRead = `Valid;
								            regcWrite = `Valid;
								            regaAddr = `Zero;
								            regbAddr = inst[20:16];
								            regcAddr = inst[15:11];
								            imm = {27'b0,inst[10:6]};//移位复用imm
								        end
	
								`Inst_sra:
								        begin
								            op = `Sra;
								            regaRead = `Invalid;
								            regbRead = `Valid;
								            regcWrite = `Valid;
								            regaAddr = `Zero;
								            regbAddr = inst[20:16];
								            regcAddr = inst[15:11];
								            imm = {27'b0,inst[10:6]};//移位复用imm
								        end
	
	
								//JR型指令
								`Inst_jr:
					 					begin
					   						op = `J;
					   						regaRead = `Valid;//需要读rs
					   						regbRead = `Invalid;
					   						regcWrite = `Invalid;
				   							regaAddr = inst[25:21];
					  	 					regbAddr = `Zero;
					 	 					regcAddr = `Zero;
				   							jAddr = regaData;//regaData=(regaAddr)
			        	        			jCe = `Valid;
				   							imm = `Zero;
				 						end
	
								`Inst_jalr:
					 					begin
					   						op = `Jal;
					   						regaRead = `Valid;
					   						regbRead = `Invalid;
					   						regcWrite = `Valid;
				   							regaAddr = inst[25:21];
					   						regbAddr = `Zero;
					  						regcAddr = 5'b11111;
				   							jAddr = regaData;
			                				jCe = `Valid;
				   							imm = npc;//regbData中存imm npc
				 						end
						
									//12条整数指令
									`Inst_slt:
						 				begin
							 				op = `Slt;
						      				regaRead = `Valid;
							  				regbRead = `Valid;
							  				regcWrite = `Valid;
							  				regaAddr = inst[25:21];
							  				regbAddr = inst[20:16];
							  				regcAddr = inst[15:11];
							  				imm = `Zero;
						 				end		
									//乘除指令
									`Inst_mult:
						 				begin
							 				op = `Mult;
						      				regaRead = `Valid;
							  				regbRead = `Valid;
							  				regcWrite = `Invalid;//写到HILO寄存器中，而不是通用寄存器中
							  				regaAddr = inst[25:21];
							  				regbAddr = inst[20:16];
							  				regcAddr = `Zero;
							  				imm = `Zero;
						 				end		
									`Inst_multu:
						 				begin
							 				op = `Multu;
						      				regaRead = `Valid;
							  				regbRead = `Valid;
							  				regcWrite = `Invalid;//写到HILO寄存器中，而不是通用寄存器中
							  				regaAddr = inst[25:21];
							  				regbAddr = inst[20:16];
							  				regcAddr = `Zero;
							  				imm = `Zero;
						 				end		
									`Inst_div:
						 				begin
							 				op = `Div;
						      				regaRead = `Valid;
							  				regbRead = `Valid;
							  				regcWrite = `Invalid;//写到HILO寄存器中，而不是通用寄存器中
							  				regaAddr = inst[25:21];
							  				regbAddr = inst[20:16];
							  				regcAddr = `Zero;
							  				imm = `Zero;
						 				end		
									`Inst_divu:
						 				begin
							 				op = `Divu;
						      				regaRead = `Valid;
							  				regbRead = `Valid;
							  				regcWrite = `Invalid;//写到HILO寄存器中，而不是通用寄存器中
							  				regaAddr = inst[25:21];
							  				regbAddr = inst[20:16];
							  				regcAddr = `Zero;
							  				imm = `Zero;
						 				end		
									//后4条指令
									`Inst_mfhi:
						 				begin
							 				op = `Mfhi;
						      				regaRead = `Invalid;
							  				regbRead = `Invalid;
							  				regcWrite = `Valid;//从HILO寄存器中，写到通用寄存器中
							  				regaAddr = `Zero;
							  				regbAddr = `Zero;
							  				regcAddr = inst[15:11];
							  				imm = `Zero;//HiLo的数据在EX中得到
						 				end		
									`Inst_mflo:
						 				begin
							 				op = `Mflo;
						      				regaRead = `Invalid;
							  				regbRead = `Invalid;
							  				regcWrite = `Valid;//从HILO寄存器中，写到通用寄存器中
							  				regaAddr = `Zero;
							  				regbAddr = `Zero;
							  				regcAddr = inst[15:11];
							  				imm = `Zero;//HiLo的数据在EX中得到
						 				end		
									`Inst_mthi:
						 				begin
							 				op = `Mthi;
						      				regaRead = `Valid;//从通用寄存器读出
							  				regbRead = `Invalid;
							  				regcWrite = `Invalid;//写到HILO寄存器中，而不是通用寄存器中
							  				regaAddr = inst[25:21];	
							  				regbAddr = `Zero;
							  				regcAddr = `Zero;
							  				imm = `Zero;
						 				end		
									`Inst_mtlo:
						 				begin
							 				op = `Mtlo;
						      				regaRead = `Valid;//从通用寄存器读出
							  				regbRead = `Invalid;
							  				regcWrite = `Invalid;//写到HILO寄存器中，而不是通用寄存器中			
							  				regaAddr = inst[25:21];
							  				regbAddr = `Zero;
							  				regcAddr = `Zero;
							  				imm = `Zero;
						 				end		
								default:
								        begin
								            regaRead = `Invalid;
								            regbRead = `Invalid;
								            regcWrite = `Invalid;
								            regaAddr = `Zero;
								            regbAddr = `Zero;
								 		    regcAddr = `Zero;
								            imm = `Zero;
											
								        end
							endcase
	
					//J型指令
					`Inst_j:
						begin
					   		op = `J;
					   		regaRead = `Invalid;
					   		regbRead = `Invalid;
					   		regcWrite = `Invalid;//不需要写
				   			regaAddr = `Zero;
					   		regbAddr = `Zero;
					  		regcAddr = `Zero;
				   			jAddr = {npc[31:28], inst[25:0], 2'b00};
			                jCe = `Valid;
				   			imm = `Zero;
				 		end				
					`Inst_jal:
					 	begin
					   		op = `Jal;
					   		regaRead = `Invalid;
					   		regbRead = `Invalid;
					   		regcWrite = `Valid;//需要把npc写入R31中
				   			regaAddr = `Zero;
					   		regbAddr = `Zero;
					  		regcAddr = 5'b11111;
				   			jAddr = {npc[31:28], inst[25:0], 2'b00};
			               	jCe = `Valid;
				   			imm = npc;
				 			end
					//J+型指令	
					`Inst_beq:
						begin
							op = `Beq;
							regaRead = `Valid;
							regbRead = `Valid;
							regcWrite = `Invalid;
						   	regaAddr = inst[25:21];
							regbAddr = inst[20:16];
							regcAddr = `Zero;
						   	jAddr = npc+{{14{inst[15]}},inst[15:0], 2'b00};
										
							if(regaData==regbData)
					            jCe = `Valid;//等于有效
							else
								jCe = `Invalid;
						   	imm = `Zero;
					 	end		
					`Inst_bne:
						begin
						   	op = `Beq;
						   	regaRead = `Valid;
						   	regbRead = `Valid;
						   	regcWrite = `Invalid;
					   		regaAddr = inst[25:21];
						   	regbAddr = inst[20:16];
						  	regcAddr = `Zero;
					   		jAddr = npc+{{14{inst[15]}},inst[15:0], 2'b00};
									
							if(regaData!=regbData)
				                jCe = `Valid;//等于有效
							else
								jCe = `Invalid;
					   		imm = `Zero;
					 	end		
					`Inst_bltz:
						begin
						   	op = `Bltz;
						   	regaRead = `Valid;
						   	regbRead = `Valid;//若regbRead无效，则regbData=imm=0
						   	regcWrite = `Invalid;
					   		regaAddr = inst[25:21];
						   	regbAddr = inst[20:16];
						  	regcAddr = `Zero;
					   		jAddr = npc+{{14{inst[15]}},inst[15:0], 2'b00};
									
							if(regaData<regbData)
				                jCe = `Valid;//小于有效
							else
								jCe = `Invalid;
					   		imm = 32'b0;
					 	end		
		
					`Inst_bgtz:
						begin
						   	op = `Bgtz;
						   	regaRead = `Valid;
						   	//regbRead = `Valid;//若regbRead有效，则regbData=(regbAddr)
							regbRead = `Invalid;//若regbRead无效，则regbData=imm=0
						   	regcWrite = `Invalid;
					   		regaAddr = inst[25:21];
						   	regbAddr = inst[20:16];
						  	regcAddr = `Zero;
					   		jAddr = npc+{{14{inst[15]}},inst[15:0], 2'b00};
									
							if(regaData>regbData)
				               	jCe = `Valid;//大于有效
							else
								jCe = `Invalid;
					   		imm = 32'b0;
					 	end		
				 	//Load Store指令
				    `Inst_lw:
				        begin
						    op = `Lw;
						    regaRead = `Valid;
						    regbRead = `Invalid;
						    regcWrite = `Valid;
						    regaAddr = inst[25:21];
						    regbAddr = `Zero;
						    regcAddr = inst[20:16];
						    imm = {{16{inst[15]}},inst[15:0]};
						 end
					
				    `Inst_sw:
						 begin
							 op = `Sw;
						      regaRead = `Valid;
							  regbRead = `Valid;
							  regcWrite = `Invalid;
							  regaAddr = inst[25:21];
							  regbAddr = inst[20:16];
							  regcAddr = `Zero;
							  imm = {{16{inst[15]}},inst[15:0]};
						end		
					//ll sc
				    `Inst_ll:
						 begin
							  op = `Ll;
						      regaRead = `Valid;
							  regbRead = `Invalid;
							  regcWrite = `Valid;
							  regaAddr = inst[25:21];
							  regbAddr = `Zero;
							  regcAddr = inst[20:16];
							  imm = {{16{inst[15]}},inst[15:0]};
						end						
				    `Inst_sc:
						 begin
							 op = `Sc;
						      regaRead = `Valid;
							  regbRead = `Valid;
							  regcWrite = `Valid;//还需给rt赋值为1
							  regaAddr = inst[25:21];
							  regbAddr = inst[20:16];
							  regcAddr = inst[20:16];//还需给rt赋值为1
							  imm = {{16{inst[15]}},inst[15:0]};
						end		
					default:
	                  	begin
		                    op = `Nop;                    
		                    regaRead = `Invalid;
		                    regbRead = `Invalid;
		                    regcWrite = `Invalid;
		                    regaAddr = `Zero;
		                    regbAddr = `Zero;
		                    regcAddr = `Zero;
		                    imm = `Zero;
		                end
            	endcase 
			end
   
	/*
	//二选一 regaData= regaData_i : imm
	always@(*)
      if(rst == `RstEnable)
          regaData = `Zero;
      else if(regaRead == `Valid)
          regaData = regaData_i;
      else	
          regaData = imm;
	
   //二选一 regbData= regbData_i : imm
    always@(*)
      if(rst == `RstEnable)
          regbData = `Zero;      
      else if(regbRead == `Valid)
          regbData = regbData_i;
      else
          regbData = imm; 
	*/	
	/*
	always@(*)      
	    if(rst == `RstEnable)          
	        regaData = `Zero;      
	    else if(op == `Lw || op == `Sw)               
	        regaData = regaData_i + imm;      
	    else if(regaRead == `Valid)          
	        regaData = regaData_i;      
	    else          
	        regaData = imm;    
	*/
/*
	//原子-修改
	always@(*)      
	    if(rst == `RstEnable)          
	        regaData = `Zero;      
	    else if(op == `Lw || op == `Sw || op==`Ll || op==`Sc)               
	        regaData = regaData_i + imm;      
	    else if(regaRead == `Valid)          
	        regaData = regaData_i;      
	    else          
	        regaData = imm;    
	always@(*)      
	    if(rst == `RstEnable)          
	        regbData = `Zero;      
	    else if(regbRead == `Valid)          
	        regbData = regbData_i;      
	    else          
	    	regbData = imm;
*/
/*
	//原子-修改
	always@(*)      
	    if(rst == `RstEnable)          
	        regaData = `Zero;      
	    else if(op == `Lw || op == `Sw || op==`Ll || op==`Sc)               
	        regaData = regaData_i + imm;      
	    else if(regaRead == `Valid)          
	        regaData = regaData_i;      
	    else          
	        regaData = imm;    
	always@(*)      
	    if(rst == `RstEnable)          
	        regbData = `Zero;      
	    else if(regbRead == `Valid)          
	        regbData = regbData_i;      
	    else          
	    	regbData = imm;	
*/
	//原子-修改
	//流水线需要有反馈数据的输入 选择器
	always@(*)    
		begin
			stall_for_rega_loadreleate=`NoStop;  
		if(rst == `RstEnable)          
		        regaData = `Zero;      
		//load		上一条指令是load	load要写入的寄存器是当前指令的源寄存器
		else if(pre_inst_is_load==1'b1 && ex_wd_to_id_i==regaAddr &&regaRead==`Valid)
			stall_for_rega_loadreleate =`Stop;
		//相邻指令的冲突WAR
         	else if(regaRead==`Valid&&ex_wreg_to_id_i==`Valid&&ex_wd_to_id_i==regaAddr)
			regaData=ex_wdata_to_id_i;		
		//相隔一条指令的冲突WAR
		else if(regaRead==`Valid&&mem_wreg_to_id_i==`Valid&&mem_wd_to_id_i==regaAddr)
			regaData=mem_wdata_to_id_i;		
		else if(op == `Lw || op == `Sw || op==`Ll || op==`Sc)               
		        regaData = regaData_i + imm;      
		else if(regaRead == `Valid)          
		        regaData = regaData_i;      
		else          
		        regaData = imm;    
		end
 
	always@(*) 
		begin     
			stall_for_regb_loadreleate=`NoStop;  
		    if(rst == `RstEnable)          
		        regbData = `Zero;    
		    //load相关 如果上一条指令是load 结果寄存器 == 当前指令源寄存器
		    else if(pre_inst_is_load==1'b1 && ex_wd_to_id_i==regbAddr &&regbRead==`Valid)
				stall_for_regb_loadreleate =`Stop;
		   //相邻指令的冲突WAR
		    else if(regbRead==`Valid&&ex_wreg_to_id_i==`Valid&&ex_wd_to_id_i==regbAddr)
				regbData=ex_wdata_to_id_i;		
	           //相隔一条指令的冲突WAR
		   else if(regbRead==`Valid&&mem_wreg_to_id_i==`Valid&&mem_wd_to_id_i==regbAddr)  
				regbData=mem_wdata_to_id_i;		
		    else if(regbRead == `Valid)          
		        regbData = regbData_i;      
		    else          
		    	regbData = imm;	
		end
endmodule