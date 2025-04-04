`include "define.v"
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
		instmem[0] = 32'h3C017000;  //lui r1,7000h
		instmem[1] = 32'h3C027000;  //lui r2,7000h
		instmem[2]= 32'b001101_00001_00001_0000_0000_0001_0000;//ori r1,r1,0010 
		instmem[3]= 32'b001101_00010_00010_0000_0000_0100_0000;//ori r2,r2,0040
//¡˜ÀÆµ∆
		//exp3
		instmem[4] =32'h34040001;	//ori r4,r0,0x0001
		instmem[5] =32'h34058000;	//ori r5,r0,0x8000
		instmem[6] =32'h34060001;	//ori r6,r0,0x0001
		//exp1
		instmem[7] =32'h8c230000;	//lw r3,0x0(r1)
		instmem[8] =32'h10660001;	//beq r3,r6,exp2
		instmem[9] =32'h80000007;	//j exp1
		//exp2
		instmem[10] =32'h8c230000;	//lw r3,0x0(r1)
		instmem[11] =32'h1466fffe;	//bne r3,r6,exp2
		
		instmem[12] =32'hac440000;	//sw r4,0x0(r2)
		instmem[13] =32'h00042040;	//sll r4,r4,1
		instmem[14] =32'h1485fffb;	//bne r4,r5,exp2

		instmem[15] =32'hac440000;	//sw r4,0x0(r2)
		instmem[16] =32'h08000004;	//j exp3
		
	
/*		//exp3
		instmem[4] =32'h34040001;	//ori r4,r0,0x0001
		instmem[5] =32'h34054000;	//ori r5,r0,0x8000
		instmem[6] =32'h34060001;	//ori r6,r0,0x0001
		//exp1
		instmem[7] =32'h8c230000;	//lw r3,0x0(r1)
		instmem[8] =32'h10660001;	//beq r3,r6,exp2
		instmem[9] =32'h80000007;	//j exp1
		//exp2
		instmem[10] =32'hac440000;	//sw r4,0x0(r2)
		instmem[11] =32'h00042040;	//sll r4,r4,1
		instmem[12] =32'h1485fffd;	//bne r4,r5,exp2
		instmem[13] =32'hac440000;	//sw r4,0x0(r2)
	
		instmem[14] =32'h08000004;	//j exp3
*/
/*
		//exp3
		instmem[4] =32'h34040001;	//ori r4,r0,0x0001
		instmem[5] =32'h34058000;	//ori r5,r0,0x8000
		instmem[6] =32'h34060001;	//ori r6,r0,0x0001
		//exp1
		instmem[7] =32'h8c230000;	//lw r3,0x0(r1)
		instmem[8] =32'h10660001;	//beq r3,r6,exp2
		instmem[9] =32'h80000007;	//j exp1
		//exp2
		instmem[10] =32'h8c230000;	//lw r3,0x0(r1)
		instmem[11] =32'h1466fffe;	//bne r3,r6,exp2
		
		instmem[12] =32'hac440000;	//sw r4,0x0(r2)
		instmem[13] =32'h00042040;	//sll r4,r4,1
		instmem[14] =32'h1485fffb;	//bne r4,r5,exp2

		instmem[15] =32'hac440000;	//sw r4,0x0(r2)
		instmem[16] =32'h08000004;	//j exp3
		
*/
		
/*
		instmem[4]=32'b100011_00001_00011_0000_0000_0000_0000; //lw r3,0x0(r1)
		instmem[5]=32'b101011_00010_00011_0000_0000_0000_0000; //sw r3,0x0(r2)

		instmem[6]= 32'h08000004;  	//j 4		ÁºñÁ†Å000010  pc=0010
*/
      end
endmodule
