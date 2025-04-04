`include "define.v"
module EX(
    //interupt
    output reg cp0we,
    output reg [4:0] cp0Addr,
    output reg [31:0] cp0wData,
    input wire[31:0] cp0rData,
    input wire[31:0] pc_i,	
    input wire [31:0] excptype_i,
    output reg [31:0] excptype,	
    output wire [31:0] epc,	
    output wire [31:0] pc,
    input wire [31:0] cause,
    input wire [31:0] status,

	
    input wire rst,
    //input wire [5:0] op,
    input wire [5:0] op_i,     
    input wire [31:0] regaData,
    input wire [31:0] regbData,
    input wire regcWrite_i,
    input wire [4:0]regcAddr_i,
    output reg [31:0] regcData,
    output wire regcWrite,
    output wire [4:0] regcAddr,

    output wire [5:0] op,
    output wire [31:0] memAddr,
    output wire [31:0] memData,
	
    input wire [31:0] rHiData,
    input wire [31:0] rLoData,
    output reg whi,	
    output reg wlo,	
    output reg [31:0] wHiData,	
    output reg [31:0] wLoData  

);    
    assign op = op_i;
//	assign op = (excptype == `ZeroWord) ? op_i : `Nop;
    assign memAddr = regaData;
    assign memData = regbData;
    //interupt
    assign pc = pc_i;
    
    assign regcWrite =(excptype == `ZeroWord) ?regcWrite_i : `Invalid;

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
		//?
		regcData = `Zero;
       		wHiData=`Zero;
		wLoData=`Zero;
		cp0we=`Invalid;
		cp0wData= `Zero;
		cp0Addr =`CP0_epc;  
            //case(op)
		case(op_i)
                `Or:
                    	regcData = regaData | regbData;
	     	`Add:
		    	regcData = regaData + regbData;
		`And:
		    	regcData = regaData & regbData;
		`Xor:
		    	regcData = regaData ^ regbData;
		`Lui:
		    	regcData = regaData;
		/*`Lui:
		    	regcData = regaData | regbData;
		*/
		`Sub:
		   	regcData = regaData - regbData;
		`Sll:
		    	regcData = regbData << regaData;
		`Srl:
		    	regcData = regbData >> regaData;
		`Sra:
		    	regcData = ($signed(regbData)) >>> regaData;
		`J:
                    	regcData = `Zero;
		`Jr:
                    	regcData = `Zero;
                `Jal:
                    	regcData = regbData;
		`Beq:
                    	regcData = `Zero;
                `Bne:
                    	regcData = `Zero;
		`Bltz:
		    	regcData = `Zero;
		`Bgtz:
		    	regcData = `Zero;
              
		`Slt:
		    	regcData = ($signed(regaData)<$signed(regbData))?1'b1:1'b0;

		`Mult:
			begin
				whi=`Valid;
				wlo=`Valid;
				{wHiData,wLoData}=$signed(regaData)*$signed(regbData);
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
		`Mfhi:
			regcData=rHiData;
		`Mflo:
			regcData=rLoData;
		`Mthi:	
			begin
			whi=`Valid;
			
			wHiData= regaData;
			end
		`Mtlo:
			begin
			wlo=`Valid;
			wLoData= regaData;
			end
		//interupt
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
    
	//interupt
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

