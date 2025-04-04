`include "define.v";
module  ID (
    input wire rst,    
    //input wire [31:0] pc,   //J
    input wire [31:0] pc_i,   //interupt
    output wire [31:0] pc,    //interupt
    output wire [31:0] excptype,   //interupt

    input wire [31:0] inst,
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
    output reg [31:0] jAddr,   //J
    output reg jCe//J

);

    wire [5:0] inst_op = inst[31:26];   
  
    reg [31:0] imm;
   //R
    wire[5:0] func = inst[5:0]; 
   //J
   wire [31:0] npc = pc + 4;
    //interupt
    reg is_syscall;
    reg is_eret;
    assign pc = pc_i;
    assign excptype = {22'b0,is_eret,is_syscall,8'b0};

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
               jCe = `Invalid;//J
               jAddr = `Zero;//J
		is_eret = `Invalid;    //interupt
		is_syscall = `Invalid; //interupt
             end
	//interupt
      else if(inst == `Inst_eret)
	begin
		op = `Eret;
		regaRead = `Invalid;
		regbRead = `Invalid;
		regcWrite = `Invalid;
		regaAddr = `Zero;
		regbAddr = `Zero;
		regcAddr = `Zero;
		imm = `Zero;
		jCe = `Invalid;
		jAddr = `Zero;
		is_eret = `Valid;
		is_syscall = `Invalid;
	end	
      else if(inst == `Inst_syscall)
	begin
		op = `Syscall;
		regaRead = `Invalid;
		regbRead = `Invalid;
		regcWrite = `Invalid;
		regaAddr = `Zero;
		regbAddr = `Zero;
		regcAddr = `Zero;
		imm = `Zero;
		jCe = `Invalid;
		jAddr = `Zero;
		is_eret = `Invalid;
		is_syscall = `Valid;
	end	
	//	
	//
      else 
         begin
             jCe = `Invalid;//J
              jAddr = `Zero;//J
		is_eret = `Invalid;   //interupt
		is_syscall = `Invalid;//interupt
               case(inst_op)
		//interupt
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
					imm = {27'h0,inst[15:11]};
				end
				`Inst_mtc0:
				begin
					op = `Mtc0;
					regaRead = `Invalid;
					regbRead = `Valid;
					regcWrite = `Invalid;
					regaAddr = `Zero;
					regbAddr = inst[20:16];
					regcAddr = `Zero;
					imm = {27'h0,inst[15:11]};
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
               				imm    = `Zero;
				end
			endcase
			//
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
               `Inst_subi:
                  begin
                          op = `Sub;                    
                          regaRead = `Valid;
                          regbRead = `Invalid;
                          regcWrite = `Valid;
                          regaAddr = inst[25:21];
                          regbAddr = `Zero;
                          regcAddr = inst[20:16];
                          imm = {{16{inst[15]}}, inst[15:0]};
                       end
                `Inst_lui:
                  begin
                          op = `Lui;                    
                          regaRead = `Invalid;
                          regbRead = `Invalid;
                          regcWrite = `Valid;
                          regaAddr = `Zero;
                          regbAddr = `Zero;
                          regcAddr = inst[20:16];
                          imm = {inst[15:0],16'h0};
                        end

               `Inst_r:
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
                                    imm = {27'b0,inst[10:6]};
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
                                    imm = {27'b0,inst[10:6]};
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
                                    imm = {27'b0,inst[10:6]};
                                end
   
   
                        
                        `Inst_jr:
                              begin
                                    op = `Jr;
                                    regaRead = `Valid;//rs
                                    regbRead = `Invalid;
                                    regcWrite = `Invalid;
                                    regaAddr = inst[25:21];
                                    regbAddr = `Zero;
                                    regcAddr = 5'b11111;
                                    jAddr = regaData;
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
                                    regcAddr = inst[15:11];  //
                                    jAddr = regaData;
                                    jCe = `Valid;
                                    imm = npc;
                              end

			`Inst_slt:
                              begin
                                    op = `Slt;
                                    regaRead = `Valid;
                                    regbRead = `Invalid;
                                    regcWrite = `Valid;
                                    regaAddr = inst[25:21];
                                    regbAddr = inst[20:16];
                                    regcAddr = inst[15:11];  
                                    imm = `Zero;
                              end
   			`Inst_mult:
			      begin
					op = `Mult;
					regaRead = `Valid;
					regbRead = `Valid;
					regcWrite = `Invalid;
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
					regcWrite = `Invalid;							  				regaAddr = inst[25:21];
					regbAddr = inst[20:16];
					regcAddr = `Zero;
					imm = `Zero;
				end		
			`Inst_div:
				begin
					op = `Div;
					regaRead = `Valid;
					regbRead = `Valid;
					regcWrite = `Invalid;
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
					regcWrite = `Invalid;
					regaAddr = inst[25:21];
					regbAddr = inst[20:16];
					regcAddr = `Zero;
					imm = `Zero;
				end		

			`Inst_mfhi:
				begin
					op=`Mfhi;
					regaRead = `Invalid;
					regbRead = `Invalid;
					regcWrite = `Valid;
					regaAddr = `Zero;
					regbAddr = `Zero;
					regcAddr = inst[15:11];
					imm =	`Zero;
				end
			`Inst_mflo:
				begin
					op=`Mflo;
					regaRead = `Invalid;
					regbRead = `Invalid;
					regcWrite = `Valid;
					regaAddr = `Zero;
					regbAddr = `Zero;
					regcAddr = inst[15:11];
					imm =	`Zero;
				end
			`Inst_mthi:
				begin
					op=`Mthi;
					regaRead = `Valid;
					regbRead = `Invalid;
					regcWrite = `Invalid;
					regaAddr = inst[25:21];
					regbAddr = `Zero;
					regcAddr = `Zero;
					imm = `Zero;
				end
			`Inst_mtlo:
				begin
					op=`Mtlo;
					regaRead = `Valid;
					regbRead = `Invalid;
					regcWrite = `Invalid;
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
   
               //J
               `Inst_j:
                  begin
                        op = `J;
                        regaRead = `Invalid;
                        regbRead = `Invalid;
                        regcWrite = `Invalid;
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
                        regcWrite = `Valid;
                        regaAddr = `Zero;
                        regbAddr = `Zero;
                     	regcAddr = 5'b11111;
                        jAddr = {npc[31:28], inst[25:0], 2'b00};
                           jCe = `Valid;
                        imm = npc;
                     end
                //J 
               `Inst_beq:
                  begin
                     op = `Beq;
                     regaRead = `Valid;
                     regbRead = `Valid;
                     regcWrite = `Invalid;
                     regaAddr = inst[25:21];
                     regbAddr = inst[20:16];
                     regcAddr = `Zero;
                     jAddr = npc+{{14{inst[15]}},inst[15:0],2'b00};
                     jCe=(regaData==regbData)?`Valid:`Invalid; 
                    /* if(regaData==regbData)
                           jCe = `Valid;
                     else
                        jCe = `Invalid;*/
                        imm = `Zero;
                  end      
               `Inst_bne:
                  begin
                        op = `Bne;
                        regaRead = `Valid;
                        regbRead = `Valid;
                        regcWrite = `Invalid;
                        regaAddr = inst[25:21];
                        regbAddr = inst[20:16];
                     	regcAddr = `Zero;
                        jAddr = npc+{{14{inst[15]}},inst[15:0],2'b00};
                        jCe=(regaData!=regbData)?`Valid:`Invalid;   
                    /* if(regaData!=regbData)
                            jCe = `Valid;
                     else
                        jCe = `Invalid;
			*/
                        imm = `Zero;
                  end      
		
		`Inst_bgtz:
			begin
			op = `Bgtz;
			regaRead = `Valid;
			regbRead = `Valid;//
			regcWrite = `Invalid;
			regaAddr = inst[25:21];
			regbAddr = inst[20:16];
			regcAddr = `Zero;
			jAddr = npc+{{14{inst[15]}},inst[15:0],2'b00};
			jCe = (regaData[31]==0)?`Valid:`Invalid;
			imm = 32'b0;  //
			end

		`Inst_bltz:
			begin
			op = `Bgtz;
			regaRead = `Valid;
			regbRead = `Valid;//
			regcWrite = `Invalid;
			regaAddr = inst[25:21];
			regbAddr = inst[20:16];
			regcAddr = `Zero;
			jAddr = npc+{{14{inst[15]}},inst[15:0],2'b00};

			jCe = (regaData[31]==1)?`Valid:`Invalid;  //
			imm = 32'b0;  //
			end

			
     
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
      		`Inst_ll:
			begin
			op=`Ll;
			regaRead = `Valid;
			regbRead = `Invalid;
			regcWrite = `Valid;
			regaAddr = inst[25:21];
			regbAddr = `Zero;
			regcAddr = inst[20:16];
			imm ={{16{inst[15]}},inst[15:0]};
			end
		`Inst_sc:
			begin
			op = `Sc;
			regaRead = `Valid;
			regbRead = `Valid;
			regcWrite = `Valid;
			regaAddr = inst[25:21];
			regbAddr = inst[20:16];
			regcAddr = inst[20:16];
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
   always@(*)
      if(rst == `RstEnable)
          regaData = `Zero;
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
always@(*)      
	    if(rst == `RstEnable)          
	        regaData = `Zero;      
	    else if(op == `Lw || op == `Sw || op ==`Ll || op ==`Sc)               
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

   
endmodule
                                                                