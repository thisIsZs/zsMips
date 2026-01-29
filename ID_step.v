`timescale 1ns / 1ps
`include "ZsMips.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/30 14:08:42
// Design Name: 
// Module Name: ID_step
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


`timescale 1ns / 1ps
`include "ZsMips.vh"

module ID_step(
    input clk,
    input [31:0] pc_adder_in, inst, 
    input regwrite_in,
    input [4:0] wa_in,
    input [31:0] wd,
    input  forwarda, forwardb,
    input [31:0] mem_bypass,
    
    input [31:0] hi_wd, lo_wd,
    input hiwrite_in, lowrite_in, 

    output delay_slot, cp0_write,
    output is_ri_excp, is_break, is_syscall,
    output [31:0] rd1, rd2,
    output alusrca, alusrcb,
    output memwrite, memread,
    output regwrite,
    output jump, link, branch,
    output [3:0] aluop,
    output [31:0] signimm,
    output [31:0] branch_ad, jump_ad,
    output [31:0] pc_add8,
    output [4:0] wa_out,
    output [2:0] mem_type,
    output hiwrite, lowrite,
    output [2:0] writetype,
    output [31:0] hi_rd, lo_rd,
    output is_eret_excp
);

    wire [31:0] reg1, reg2;
    wire regdst, link_31reg, jump_ad_src;
    wire sign_type, sign;

    // 1. 寄存器堆实例化
    regfile my_regfile(
        .clk(!clk), .we3(regwrite_in), .ra1(inst[25:21]),
        .ra2(inst[20:16]), .wa3(wa_in), .wd3(wd), .rd1(rd1), .rd2(rd2)
    );

    // 2. 旁路处理 (获取分支判断所需的最新数据)
    assign reg1 = forwarda ? mem_bypass : rd1;
    assign reg2 = forwardb ? mem_bypass : rd2;

    // 3. 统一译码器实例化
    mips_decoder decoder(
        .opcode(inst[31:26]), .func(inst[5:0]), .rt(inst[20:16]), .rs(inst[25:21]),
        .reg1_data(reg1), .reg2_data(reg2), .sign(sign), .sign_type(sign_type),
        .alusrca(alusrca), .alusrcb(alusrcb), .regwrite(regwrite), .regdst(regdst),
        .memwrite(memwrite), .memread(memread), .aluop(aluop), .mem_type(mem_type),
        .writetype(writetype), .hiwrite(hiwrite), .lowrite(lowrite), .cp0_write(cp0_write),
        .jump(jump), .branch(branch), .link(link), .link_31reg(link_31reg),
        .jump_ad_src(jump_ad_src), .delay_slot(delay_slot),
        .is_syscall(is_syscall), .is_break(is_break), .is_ri_excp(is_ri_excp)
    );

    // 4. 地址计算逻辑
    assign branch_ad   = {{14{inst[15]}}, inst[15:0], 2'b00} + pc_adder_in;
    assign jump_ad     = jump_ad_src ? {pc_adder_in[31:28], inst[25:0], 2'b00} : reg1;
    assign pc_add8     = pc_adder_in + 4;
    assign is_eret_excp = (inst == `ERET_INST);

    // 5. 写回寄存器地址选择
    assign wa_out = link_31reg ? 5'd31 : (regdst ? inst[15:11] : inst[20:16]);

    // 6. 立即数扩展
    signext my_signext(.a(inst[15:0]), .b(signimm), .sign_type(sign_type), .sign(sign));

    // 7. HI/LO 寄存器
    hilo_reg my_hilo_reg(
        .clk(!clk), .hiwrite(hiwrite_in), .lowrite(lowrite_in), 
        .hi_in(hi_wd), .lo_in(lo_wd), .hi_out(hi_rd), .lo_out(lo_rd)
    );

endmodule