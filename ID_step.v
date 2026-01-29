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


module ID_step(
    input clk,
    input [31:0] pc_adder_in, inst, 
    input regwrite_in,
    input [4:0] wa_in,
    input [31:0] wd,
    input  forwarda, forwardb,
    input [31:0] mem_bypass, mem_pc_add8, 
    input mem_link,
    input [31:0] hi_wd, lo_wd,
    input hiwrite_in, lowrite_in, 

    output delay_slot,
    output cp0_write,
    output is_ri_excp,
    output is_break, is_syscall,
    output [31:0] rd1, rd2,
    output alusrca, alusrcb,
    output memwrite, memread,
    output regwrite,
    output jump, link, 
    output branch,
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

    wire regwrite_temp;
    wire regdst, link_31reg;
    wire jump_ad_sel;
    wire [27:0] jump_temp;
    wire [31:0] pc_jump1;
    wire [31:0] cp1, cp2;
    wire sign, sign_type;
    wire [31:0] branch_signext, jump_signext;
    wire [31:0] reg1, reg2;
    wire branch_link_31reg, jump_link_31reg;
    wire branch_link, jump_link;
    wire [31:0] rd_bypass;
    wire main_ri_excp, branch_ri_excp, jump_ri_excp;
    wire branch_delay_slot, jump_delay_slot;    

    assign is_ri_excp = main_ri_excp && branch_ri_excp && jump_ri_excp ;
    assign delay_slot = branch_delay_slot || jump_delay_slot;


    maindec dec0(.opcode(inst[31:26]), .func(inst[5:0]), .hiwrite(hiwrite), .is_ri_excp(main_ri_excp),
                 .lowrite(lowrite), .alusrca(alusrca), .regdst(regdst),.sign_type(sign_type),
                 .writetype(writetype), .mem_type(mem_type),.memwrite(memwrite), .cp0_write(cp0_write),
                 .alusrcb(alusrcb), .regwrite(regwrite_temp), .sign(sign), .memread(memread),
                 .aluop(aluop), .is_break(is_break), .is_syscall(is_syscall), .cp0_rs(inst[25:21]));

    assign is_eret_excp = inst == `ERET_INST;

    //beq地址
    branch_dec dec1(.opcode(inst[31:26]), .bz_special(inst[20:16]), .link(branch_link),
                    .a(reg1), .b(reg2), .branch(branch), .link_31reg(branch_link_31reg),
                    .is_ri_excp(branch_ri_excp), .delay_slot(branch_delay_slot));
    assign branch_signext = {{14{inst[15:15]}}, inst[15:0], 2'b00};
    assign branch_ad = branch_signext + pc_adder_in;

    //jump地址
    jump_dec dec2(.opcode(inst[31:26]), .func(inst[5:0]), .jump_ad_sel(jump_ad_sel),
                  .jump(jump), .link_31reg(jump_link_31reg), .link(jump_link),
                  .is_ri_excp(jump_ri_excp), .delay_slot(jump_delay_slot));
    assign jump_signext = {pc_adder_in[31:28], inst[25:0], 2'b00};
    assign jump_ad = jump_ad_sel ? jump_signext : reg1;

    //32个通用寄存器
    regfile my_regfile(.clk(!clk), .we3(regwrite_in), .ra1(inst[25:21]),
                       .ra2(inst[20:16]), .wa3(wa_in), .wd3(wd),
                       .rd1(rd1), .rd2(rd2));
    //hi lo寄存器
    hilo_reg my_hilo_reg(.clk(!clk), .hiwrite(hiwrite_in), .lowrite(lowrite_in), 
                         .hi_in(hi_wd), .lo_in(lo_wd), .hi_out(hi_rd), .lo_out(lo_rd));

    assign link = branch_link || jump_link;
    assign regwrite = link ? 1'b1 : regwrite_temp;
    assign pc_add8 = pc_adder_in + 3'b100;
    // assign flush = branch || jump;
    assign link_31reg = branch_link_31reg || jump_link_31reg;
    assign wa_out = link_31reg ? 5'h1f : (regdst ? inst[15:11] : inst[20:16]);

    //旁路选择
    // assign rd_bypass = link ? mem_pc_add8 : mem_bypass;
    assign reg1 = forwarda ? mem_bypass : rd1;
    assign reg2 = forwardb ? mem_bypass : rd2;

    //立即数扩展
    signext my_branch_signext(.a(inst[15:0]), .b(signimm), .sign_type(sign_type),
                              .sign(sign));


endmodule
