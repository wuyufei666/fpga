
`include "define.v";
module MEM(
	input wire rLLbit,//
	output reg wbit,//
	output reg wLLbit,//
	input wire rst,		
	input wire [5:0] op,
	input wire [31:0] regcData,
	input wire [4:0] regcAddr,
	input wire regcWr,
	input wire [31:0] memAddr_i,
	input wire [31:0] memData,	
	input  wire [31:0] rdData,
	output wire [4:0]  regAddr,
	output wire regWr,
	output wire [31:0] regData,	
	output wire [31:0] memAddr,
	output reg [31:0] wtData,
	output reg memWr,	
	output reg memCe
);

	assign regAddr = regcAddr;    
	assign regWr = regcWr;    

	wire[31:0] regDataLL = (rLLbit == `SetFlag) ?32'b1:32'b0;//
	wire[31:0] regcDataLL = (op == `Sc) ? regDataLL : regcData;//

	//assign regData = (op == `Lw) ? rdData : regcData;  
	assign regData = (op == `Lw) ? rdData : regcDataLL;     
	assign memAddr = memAddr_i;
	
	always @(*)        
	    if(rst == `RstEnable)          
	      begin            
	        wtData = `Zero;            
	        memWr = `RamUnWrite;            
	        memCe = `RamDisable;  
		wbit = `Invalid;       //
		wLLbit = `ClearFlag;   //     
	      end        
		else
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
				`Ll:
				begin
				wtData = `Zero;
				memWr = `RamUnWrite;
				memCe = `RamEnable;
				wbit = 	`Valid;
				wLLbit = `SetFlag;
				end
				`Sc:
				begin
				if(rLLbit == `SetFlag)
					begin
					wtData = memData;                    
			         	memWr = `RamWrite;                      
			         	memCe = `RamEnable; 
					wbit = `Valid;
					wLLbit = `ClearFlag;
					end
				else;
				end
				`Syscall:
				begin
					wbit = `Valid;
					wLLbit = `ClearFlag;
				end
				`Eret:
				begin
					wbit = `Valid;
					wLLbit =`ClearFlag;
				end
			default:                  
			    begin                    
			        wtData = `Zero;                    
			        memWr = `RamUnWrite;                    
			        memCe = `RamDisable;  
				wbit = `Invalid;       //
				wLLbit = `ClearFlag;   //                 
			    end            
			endcase
endmodule
