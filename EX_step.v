`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/30 14:12:32
// Design Name: 
// Module Name: EX_step
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module EX_step(
    input [1:0] forwarda, forwardb,
    input [31:0] mem_bypass, wb_bypass,
    input [4:0] inst10_6,
    input  alusrca, alusrcb, 
    input [3:0] aluop,
    input [31:0] signimm, da1, da2,
    input [1:0] forward_hi, forward_lo,
    input [31:0] id_ex_hi, id_ex_lo,
    input [31:0] ex_mem_hi, ex_mem_lo,
    input [31:0] wb_hi, wb_lo,
    input [2:0] writetype,
    input [31:0] cp0_readdata,
    
    output is_overflow,
    output [31:0] aluout, da2_out,
    output [31:0] alu_hi, alu_lo,
    output [31:0] hi_rd, lo_rd,
    output [31:0] bypass_data
    );

    wire [4:0] aluctl;
    wire [31:0] alua, alub;
    wire [31:0] alua_sel;
    wire [31:0] wb_bypass_final, mem_bypass_final;


    //bypass raw, load-use 旁路
    assign alua_sel = (forwarda == 2'b00) ? da1 :
                    (forwarda == 2'b01) ? wb_bypass :
                    (forwarda == 2'b10) ? mem_bypass : 32'b0;


    assign da2_out = (forwardb == 2'b00) ? da2 :
                    (forwardb == 2'b01) ? wb_bypass :
                    (forwardb == 2'b10) ? mem_bypass : 32'b0;

    //hi lo寄存器旁路
    assign hi_rd = (forward_hi == 2'b10) ? ex_mem_hi : (forward_hi == 2'b01) ? wb_hi : id_ex_hi;
    assign lo_rd = (forward_lo == 2'b10) ? ex_mem_lo : (forward_lo == 2'b01) ? wb_lo : id_ex_lo;

    //选择src来自寄存器还是inst
    // ALU 源 A 的选择逻辑
    assign alua = alusrca ? {27'b0, inst10_6} : alua_sel;
    // ALU 源 B 的选择逻辑
    assign alub = alusrcb ? signimm : da2_out;

    aludec dec1(.aluop(aluop), .funct(signimm[5:0]), .aluctl(aluctl));
    alu my_alu(.aluctl(aluctl), .a(alua), .b(alub), .aluout(aluout),
                .hi(alu_hi), .lo(alu_lo), .is_overflow(is_overflow));

    // 数据旁路选择
    assign bypass_data =
    (writetype == 3'b000) ? aluout :
    (writetype == 3'b010) ? lo_rd :
    (writetype == 3'b011) ? hi_rd :
    (writetype == 3'b100) ? cp0_readdata :
    32'b0;
endmodule
