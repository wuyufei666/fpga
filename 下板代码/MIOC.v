
`include "define.v"

module MIOC(
	input wire memCe,
	input wire memWr,
	input wire [31:0] memAddr,
	input wire [31:0] wtData,
	input wire[31:0] ramRdData,
	input wire[31:0] ioRdData,
	output reg[31:0] rdData,
	output reg ramCe,
	output reg ramWe,
	output reg [31:0] ramAddr,
	output reg[31:0] ramWtData,
	output reg ioCe,
	output reg ioWe,
	output reg[31:0] ioAddr,
	output reg [31:0] ioWtData
);


	always@(*)
		if(memCe == `RamEnable)
//			if(memAddr & 32'hF000_0000 == 32'h7000_0000) //按位与结果不对
			if(memAddr >= 32'h7000_0000 && memAddr<32'h8000_0000)
				begin
					ioCe= `RamEnable;
					ioWe = memWr;
					ioAddr = memAddr;
					ramCe= `RamDisable;
					ramWe = `RamUnWrite;
					ramAddr = `Zero;
				end
			else
				begin
					ioCe = `RamDisable;
					ioWe= `RamUnWrite;
					ioAddr = `Zero;
					ramCe= `RamEnable;
					ramWe = memWr;
					ramAddr = memAddr;
				end
		else
			begin
				ioCe= `RamDisable;
				ioWe= `RamUnWrite;
				ioAddr = `Zero;
				ramCe= `RamDisable;
				ramWe = `RamUnWrite;
				ramAddr = `Zero;
			end
		
	always@(*)
		if(memCe == `RamEnable)
			if(ramCe ==`RamEnable)
				begin
					rdData= ramRdData;
					ramWtData = wtData;
					ioWtData= `Zero;
				end
			else
				begin
					rdData = ioRdData;
					ramWtData= `Zero;
					ioWtData=wtData;
				end
		else
			begin
				rdData= `Zero;
				ramWtData= `Zero;
				ioWtData= `Zero;
			end
endmodule
