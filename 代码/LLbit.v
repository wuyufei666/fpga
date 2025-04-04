
`include "define.v"
//LLbit寄存器
module LLbit(
	input wire clk,
	input wire rst,
	input wire excpt,
	input wire wbit, 	//写信号
	input wire wLLbit,	//写数据
	output reg rLLbit	//读数据
);
 
	reg LLbit;//内部存储 
 
	always@(*)
        if(rst == `RstEnable)
            rLLbit = `Zero;
        else
            rLLbit = LLbit;
 
    
    always@(posedge clk)
        if(rst ==`RstDisable && wbit==`Valid)
            LLbit=wLLbit;
        else ;
 
endmodule