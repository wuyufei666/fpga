
`include "define.v";
//6、指令存储器
module InstMem(
    input wire ce,
    input wire [31:0] addr,
    output reg [31:0] data
);
    reg [31:0] instmem [1023 : 0];    
    always@(*)      
        if(ce == `RomDisable)
          data = `Zero;
        else
          data = instmem[addr[11 : 2]];   
    initial
      begin
 

        	
		instmem [0] = 32'h34011100; //ori r1,r0,1100
        	instmem [1] = 32'h34020020; //ori r2,r0,0020
        	instmem [2] = 32'h3403ff00; //ori r3,r0,ff00
        	instmem [3] = 32'h3404ffff; //ori r4,r0,ffff
		//相邻 	
        	instmem [4] = 32'h34850000;	//ori r5,r4,0000
		//相隔一条指令	
       		instmem [5] = 32'h34860000;	//ori r6,r4,0000
		//相隔两条指令	
		instmem [6] = 32'h34870000;	//ori r7,r4,0000
		//load 相关
		//datamem[0]=(r1)
		instmem[7]=32'b101011_00000_00001_0000_0000_0000_0000; //sw r1,0x0(r0)
		//(r8)=datamem[0]
		instmem[8]=32'b100011_00000_01000_0000_0000_0000_0000; //lw r8,0x0(r0)
		instmem[9]=32'b001101_01000_01001_0000_0000_0000_0000; // ori r9 r8,0000	
		instmem[10]=32'b001100_01001_01010_1111_1111_1111_1111; // andi r10 r9,ffff	
    
 
	  end
endmodule