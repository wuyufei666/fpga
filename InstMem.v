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

/*	
		instmem [0] = 32'h34011100;   //ori r1,r0,1100h         r1--32'h0000 1100
        	instmem [1] = 32'h34020020;   //ori r2,r0,0020h		r2--32'h0000 0020
        	instmem [2] = 32'h3403ff00;   //ori r3,r0,ff00h		r3--32'h0000 ff00
		instmem [3] = 32'h3404ffff;   //ori r4,r0,ffffh		r4--32'h0000 ffff
		instmem [4] = 32'b000000_00001_00010_00101_00000_100000;//add,R5,R1,R2  00001120
        	instmem [5] = 32'b000000_00001_00010_00110_00000_100101;//or,R6,R1,R2   00001120
		//syscall   00000040
		instmem[6]=32'h0000000c;//syscall instruction
		instmem[7]=32'h3407ffff;//ori r7,r0,ffffh
		instmem[8]=32'h3408ffff;//ori r8,r0,ffffh
		//syscall except program
		instmem [16]=32'h340affff;//ori r10,ffffh
		instmem [17]=32'h340bffff;//ori r11,r0,ffffh
		instmem [18]=32'h42000018;//eret inatruction
*/


		//mtco、mfco
		instmem[0] =32'h34020000; 	//ori r2, r0,0
		instmem[1]= 32'h34010014; 	//ori r1, r0,20
		instmem[2]= 32'h40815800; 	//mtc0 r1,11 set compare=20
		instmem[3]=32'h3c011000;	//lui r1, 0x1000
		instmem[4]=32'h34210401;	//ori r1, $1,0x0401
		instmem[5]= 32'h40816000; 	//mtc0 r1,12 set status,enable int    
		instmem[6]= 32'h08000006; 	//lpt: j lpt      pc<-18h
		//interproc first addr Ox0050
		instmem[20]= 32'h34030001; 	//ori r3,r0,1
		instmem[21]= 32'h34040014;	//ori r4, r0,20
		instmem[22]= 32'h00431020;	//add r2,r2,r3
		instmem[23]= 32'h40015800;	//mfc r1,11 read compare
		instmem[24]=32'h00240820; 	//add r1,r1,r4
		instmem[25]= 32'h40815800;	//mtc0 r1,11 set compare
		instmem[26]= 32'h42000018;	//eret


/*	instmem [0] = 32'h34011100;   //ori r1,r0,1100h         r1--32'h0000 1100
        instmem [1] = 32'h34020020;   //ori r2,r0,0020h		r2--32'h0000 0020
        instmem [2] = 32'h3403ff00;   //ori r3,r0,ff00h		r3--32'h0000 ff00
        instmem [3] = 32'h3404ffff;   //ori r4,r0,ffffh		r4--32'h0000 ffff
*/
/*
	
	//Lpt: 	LL r5,0x10(r1)		//读取程序里的信号量，LLibt=1
	//ll r5,0x10(r1) --(r5)=mem[68]=0
	instmem [4] = 32'b110000_00001_00101_0000_0000_0001_0000;//ll r5,0x10(r1)
	//if(r5 == clearFlag)	//判断信号是否被占用，为clearFlag表示没占用
	//pc=jaddr=npc+S14 offset(16) 00(2)
	//bne,r5,r0,else(+4)
	instmem [5] = 32'b000101_00101_00000_0000_0000_0000_0100;//bne,r5,r0,else(+4)
	//{
	//	MOV r5, setFlag			//设置本程序的占用标志
	//ori R5,ffff -- R5 --0000ffff
        instmem [6] = 32'h3405ffff;	//ori  R5 ffff
	//	SC r5, 0x20(r1)			//设置到信号量里
	instmem [7] = 32'b111000_00001_00101_0000_0000_0001_0000;//sc r5,0x10(r1)
	//	if(r5 == 1) goto Success//如果信号量设置成功,r1就会为1
	//pc=jaddr=npc+S14 offset(16) 00(2)
	//bne,r1,r0,Success(+2)
	instmem [8] = 32'b000101_00101_00000_0000_0000_0000_0010;//bne,r5,r0,Success(+2)
	//	//如果信号量没有设置成功,重新读信号量，即重新执行LL指令
	//	else goto Lpt
	//j Lpt(6)
	//pc=jaddr=npc(4) offset(26) 00(2)	
	instmem [9] = 32'h08000006;//j 4
	//}
	//else goto Lpt
	//j Lpt(6)
	//pc=jaddr=npc(4) offset(26) 00(2)	
	instmem [10] =  32'h08000006;//j 4

	//Success:
	//	访问指定的存储区域
	//	set r5,clearFlag
	//andi R5,0000 -- R5--00000000
        instmem [11] = 32'h30050000;	//andi R5,0000
	//	lw r5,(0x10)r1
	instmem[12]=32'b100011_00001_00101_0000_0000_0001_0000; //lw r5,0x10(r1)
*/

/*

	instmem [4] = 32'hc0250020; 					//ll r5,0x20(r1)
	instmem [5] = 32'b000101_00101_00000_0000_0000_0000_0100; 	//bne r5,r0,4
	instmem [6] = 32'h3405ffff; 					//ori r5,r0,ffffh   r6--32'h0000 ffff
	instmem [7] = 32'h02500020;					//sc r5,0x20(r1)
	instmem [8] = 32'b000101_00101_00000_0000_0000_0000_0010; 	//bne r5,r0,2
	instmem [9] = 32'h08000004; 					//j  4   pc--10
	instmem [10] = 32'h08000004; 					//j  4   pc--10
	instmem [11] = 32'h30050000; 					//andi r5,0000
	instmem [12]=32'h8c250020; 					//lw r5,0x20(r1)
*/
	
/*
	instmem [4] = 32'b000000_00001_00000_00000_00000_010001; //mthi r1
	instmem [5] = 32'b000000_00010_00000_00000_00000_010011; //mtlo r2
	instmem [6] = 32'b000000_00000_00000_00101_00000_010000; //mfhi r5
	instmem [7] = 32'b000000_00000_00000_00110_00000_010010; //mflo r6
*/

/*
	instmem [4] = 32'b000000_00001_00010_00000_00000_011001;//multu,r1,r2         22000
	instmem [5] = 32'b000000_00001_00010_00000_00000_011011;//divu,r1,r2         88
	instmem [6] = 32'h2005fffc;	//addi r5,r0,fffc	r5--32'hffff fffc
	instmem [7] = 32'h34060002;   //ori r6,r0,0002h         r6--32'h0000 0002
	instmem [8] = 32'h3c071234;     //lui r7,1234		r7--32'h1234 0000
	instmem [9] = 32'b000000_00101_00110_00000_00000_011000; //mult r5,r6
	instmem [10] = 32'b000000_00101_00110_00000_00000_011010; //div r5,r6

*/
	

/*
	instmem [4] = 32'h2005ffff;	//addi r5,r0,ffff	r5--32'hffff ffff
	instmem [5] =32'b000000_00101_00100_00110_00000_101010;	  //slt r6,r5,r4
	instmem [6] =32'b000000_00100_00011_00110_00000_101010;	  //slt r6,r4,r3
*/

/*
	instmem [4] = 32'h3005ffff;	//andi r5,r0,ffff	r5--32'h0000 0000
	instmem [5] = 32'h3806ffff;	//xori r6,r0,ffff	r6--32'h0000 ffff
	instmem [6] = 32'h2007ffff;	//addi r7,r0,ffff	r7--32'hffff ffff
	instmem [7] = 32'h3c081234;     //lui r8,1234		r8--32'h1234 0000
		
	instmem [8] = 32'h35095679;     //ori r9,r8,5678	r9--32'h1234 5679
	instmem [9] = 32'h212aa011;     //addi r10,r9,a011	r10--32'h1233 f68a
	instmem [10] = 32'h306b1111;	//andi r11,r3,1111	r10--32'h0000 1100
	instmem [11] = 32'h254C1111;    //subi r12,r10,1111     r12--32'h1234 e579
*/
/*
	instmem [4] = 32'h00222820;     //add r5,r1,r2		r5--32'h0000 1120
	instmem [5] = 32'h00223025;	//or r6,r1,r2		r6--32'h0000 1120
	instmem [6] = 32'h00223822;	//sub r7,r1,r2		r7--32'h0000 10e0
	instmem [7] = 32'h00224024;	//and r8,r1,r2		r8--32'h0000 0000
	instmem [8] = 32'h00224826;	//xor r9,r1,r2		r9--32'h0000 1120

	instmem [9] =32'h3c0affff;	//lui r10,ffff		r10--32'hffff 0000
	instmem [10] = 32'h000a5840;	//sll r11,ra,r10	r11--32'hfffe 0000
	instmem [11] = 32'h000a6042;	//srl,r12,ra,r10	r12--32'h7fff 8000
	instmem [12] = 32'h000a6843;	//sra r13,ra,r10	r13--32'hffff 8000

*/	

/*


	instmem [4] = 32'h3401001c;     //ori r1,r0,1ch
	instmem [5] = 32'b000000_00001_00000_11111_00000_001001;//jalr r31,r1
	instmem [6] = 32'h3405ffff;   //ori r5,r0,ffffh		
	instmem [7] = 32'b000000_00001_00010_00101_00000_100000;//add,R5,R1,R2  
	instmem [8] = 32'b000000_11111_00000_00000_00000_001000;//jr r31
*/
/*
	instmem [4] = 32'b000000_00001_00010_00101_00000_100000;//add,R5,R1,R2  
	instmem [5] = 32'h3405ffff;   //ori r5,r0,ffffh		
      

	instmem [6] = 32'b000000_00010_00011_00110_00000_100101;//or,R6,R2,R3   
	instmem [7] = 32'b000111_00101_00000_0000000000000001;//bgtz r5,1
	instmem [8] = 32'b000000_00001_00010_00110_00000_100101;//or,R6,R1,R2   00001120
	instmem [9] = 32'h2007ffff;	//addi r7,r0,ffff	r7--32'hffff ffff
	instmem [10] = 32'b000000_00011_00100_00110_00000_100101;//or,R6,R3,R4  
	

	//instmem [10] = 32'b000001_00111_00000_1111111111111101;//bltz r7,-3  
	instmem [11] = 32'b000001_00111_00000_1111111111111010;//bltz r7,-6
	
*/
	

/*
	instmem [4] = 32'b000000_00001_00010_00101_00000_100000;//add,R5,R1,R2  00001120
        instmem [5] = 32'b000000_00001_00010_00110_00000_100101;//or,R6,R1,R2   00001120

	
	//mem[68]=(r6)
	instmem[6]=32'hac260010; //sw r6,0x10(r1)
	
		
	instmem[7]=32'h8c270010; //lw r7,0x10(r1)
	
	//(r7)=mem[68]


*/


  	instmem [0] = 32'h34011100;   //ori r1,r0,1100h         r1--32'h0000 1100
        instmem [1] = 32'h34020020;   //ori r2,r0,0020h		r2--32'h0000 0020
        instmem [2] = 32'h3403ff00;   //ori r3,r0,ff00h		r3--32'h0000 ff00
        instmem [3] = 32'h3404ffff;   //ori r4,r0,ffffh		r4--32'h0000 ffff

	instmem [4] = 32'b000000_00001_00010_00101_00000_100000;	//add r5,r1,r2  00001120
        instmem [5] = 32'b000000_00001_00010_00110_00000_100101;	//or r6,r1,r2   00001120
        instmem [6] = 32'h34070001;	//ori r7,r0,0001h
        instmem [7] = 32'h34080001; 	//ori r8,r0,0001h
	//j
        instmem [8] = 32'h0800000A; 	//j 10     10*4  40--28H
        instmem [9] = 32'h20E70001;	//addi R7,R7,0001 
        instmem [10] = 32'h21080001;	//addi R8,R8,0001 
	//jal
        instmem [11] = 32'h0c00000D; //jal 13      13*4 52--34H
        instmem [12] = 32'h20E70001;
        instmem [13] = 32'h21080001;
    	//jr
        instmem [14] = 32'h34090044;//ori,R9,0044H     pc<--(rs)
        instmem [15] = 32'b000000_01001_00000_00000_00000_001000; //jr R9       17*4 68--44H
       
        instmem [16] = 32'h20E70001;
        instmem [17] = 32'h21080001;
	//beq
        instmem [18] = 32'b000100_00101_00110_0000_0000_0000_0100;  //beq r5,r6,04H      
        instmem [19] = 32'h20E70001;
        instmem [20] = 32'h21080001;
	//bne
        instmem [21] = 32'b000101_00001_00010_1111_1111_1111_1101;  //bne r1,r2,-3      
        instmem [22] = 32'h20E70001;
        instmem [23] = 32'h21080001;
	instmem [24] = 32'h08000014;   //j 20  

*/



      end
endmodule