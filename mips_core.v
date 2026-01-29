`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/30 13:55:03
// Design Name: 
// Module Name: datapath
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


module mips_core(
    input clk, rst,
    input [5:0] ext_int, // 外部中断

    //BaseMem
    input [31:0] inst,
    output [31:0] inst_add,

    //ExtMem
    output sign,
    input  [31:0] data_read,
    output [31:0] data_addr,
    output [31:0] data_write,
    output        data_wen,  //写使能
	output  [3:0] sel_bytes , // * 字节选择信号
	output        data_ren,   //读使能

    //debug 
    output  [31:0] debug_wb_pc,
    output  [3:0]  debug_wb_rf_wen,
    output  [4:0]  debug_wb_rf_wnum,
    output  [31:0] debug_wb_rf_wdata,
    output  [31:0] debug_inst_out
    );
    //IF层输出
    wire [31:0] if_pc_adder;
    wire if_is_pc_excp;

    //IF_ID输出
    wire [31:0] if_id_pc_adder;
    wire [31:0] if_id_inst;
    wire if_id_is_pc_excp;
    wire if_id_in_delayslot;

    //ID层输出
    wire [31:0] id_rd1, id_rd2;
    wire id_jump, id_branch;
    wire [31:0] id_branch_ad, id_jump_ad;
    /*控制信号*/
    wire id_alusrca, id_alusrcb;//EX层
    wire [3:0] id_aluop;//EX层
    wire id_memwrite, id_memread; //MEM层
    wire [2:0] id_mem_type; //MEM层(片选信号控制)
    wire id_is_break, id_is_syscall, id_is_ri_excp;    //MEM层(异常处理)
    wire id_eret_excp, id_cp0_write, id_delay_slot; //MEM层(异常处理)
    wire id_link, id_regwrite, id_hiwrite, id_lowrite; //WB层
    wire [2:0] id_writetype; //WB层
    /*控制信号*/
    wire [31:0] id_signimm, id_pcadd8;
    wire [4:0] id_wa;
    wire [31:0] id_hi_rd, id_lo_rd;

    //ID_EX输出
    wire [6:0] id_ex_wb;
    wire [5:0] id_ex_mem;
    wire [5:0] id_ex_ex;
    wire [31:0] id_ex_rd1, id_ex_rd2, id_ex_signimm;
    wire [4:0] id_ex_inst25_21, id_ex_inst20_16, id_ex_inst15_11, id_ex_inst10_6;
    wire id_ex_jump, id_ex_branch;
    wire [31:0] id_ex_jump_ad, id_ex_branch_ad;
    wire [31:0] id_ex_pcadd8;
    wire [4:0] id_ex_wa;
    wire [31:0] id_ex_hi_rd, id_ex_lo_rd;
    wire id_ex_is_syscall, id_ex_is_break;
    wire id_ex_is_pc_excp, id_ex_is_ri_excp;
    wire id_ex_cp0_write, id_ex_in_delayslot;
    wire id_ex_eret_excp;
    //debug
    wire [31:0] id_ex_inst;

    //EX输出
    wire [31:0] ex_aluout, ex_da2;
    wire [31:0] ex_alu_hi, ex_alu_lo;
    wire [31:0] ex_hi_rd, ex_lo_rd; 
    wire [31:0] ex_bypass_data;
    wire ex_is_overflow;

    //EX_MEM输出
    wire [6:0] ex_mem_wb;
    wire [5:0] ex_mem_mem;
    wire [4:0] ex_mem_wa, ex_mem_rt;
    wire [31:0] ex_mem_aluout, ex_mem_da2;
    wire [31:0] ex_mem_pcadd8, ex_mem_cp0_readdata;
    wire [31:0] ex_mem_alu_hi, ex_mem_alu_lo;
    wire [31:0] ex_mem_hi_rd, ex_mem_lo_rd;
    wire ex_mem_is_overflow;
    wire ex_mem_is_break, ex_mem_is_syscall;
    wire ex_mem_is_pc_excp, ex_mem_is_ri_excp;
    wire ex_mem_cp0_write, ex_mem_in_delayslot;
    wire ex_mem_eret_excp;
    wire [31:0] ex_mem_cp0_cause, ex_mem_cp0_status;
    wire [31:0] ex_mem_inst, ex_mem_bypass_data;

    //MEM输出
    wire [6:0]  mem_wb;
    
    //Exception Unit, CP0输出
    wire excp_is_exc;
    wire [31:0] cp0_readdata;
    wire [31:0] cp0_epc;
    wire [31:0] cp0_status, cp0_cause;

    //MEM_WB输出
    wire [6:0] mem_wb_wb;
    wire [31:0] mem_wb_rd, mem_wb_aluout;
    wire [4:0] mem_wb_wa;
    wire [31:0] mem_wb_pcadd8, mem_wb_cp0_readdata;
    wire [31:0] mem_wb_alu_hi, mem_wb_alu_lo;
    wire [31:0] mem_wb_hi_rd, mem_wb_lo_rd;

    //WB输出
    wire [31:0] wb_wd;
    
    //旁路信号
    wire [1:0] fwa_alu, fwb_alu;
    wire  fwa_jb, fwb_jb;
    wire [1:0] fw_hi, fw_lo; 

    //阻塞控制信号
    wire stall;
    
    //debug
    wire [47:0] ascii; 

    //IF层
    IF_step if_step (.clk(clk), .rst(rst), .pc_branch(id_ex_branch_ad), .pc_jump(id_ex_jump_ad), .jump(id_ex_jump), 
                   .branch(id_ex_branch), .stall(stall && !excp_is_exc && !ex_mem_eret_excp), .pc(inst_add),
                   .pcadder_out(if_pc_adder), .is_exc(excp_is_exc),.is_pc_excp(if_is_pc_excp), .epc(cp0_epc),
                   .is_eret_excp(ex_mem_eret_excp));

    //debug
    instdec instdec(.instr(inst), .ascii(ascii));

    //IF_ID
    IF_ID if_id (.pc_adder_in(if_pc_adder), .inst_in(inst), .pc_adder_out(if_id_pc_adder), .inst_out(if_id_inst),
                .clk(clk), .rst(rst), .stall(stall && !excp_is_exc && !ex_mem_eret_excp), .is_pc_excp_in(if_is_pc_excp),
                .is_pc_excp_out(if_id_is_pc_excp), .in_delayslot_in(id_delay_slot && !excp_is_exc && !ex_mem_eret_excp),
                .in_delayslot_out(if_id_in_delayslot));

    //ID层
    ID_step id (.clk(clk), .pc_adder_in(if_id_pc_adder), .inst(if_id_inst), .regwrite_in(mem_wb_wb[0]),
                .wa_in(mem_wb_wa), .wd(wb_wd), .forwarda(fwa_jb), .forwardb(fwb_jb), .mem_bypass(ex_mem_bypass_data), 
                .rd1(id_rd1), .rd2(id_rd2), .alusrca(id_alusrca), .alusrcb(id_alusrcb), .writetype(id_writetype),
                .memwrite(id_memwrite), .memread(id_memread), .regwrite(id_regwrite), .is_break(id_is_break),
                .is_syscall(id_is_syscall), .jump(id_jump), .link(id_link), .branch(id_branch), .delay_slot(id_delay_slot),
                .signimm(id_signimm), .branch_ad(id_branch_ad), .jump_ad(id_jump_ad), .pc_add8(id_pcadd8),
                .wa_out(id_wa), .mem_type(id_mem_type), .hi_wd(mem_wb_alu_hi), .lo_wd(mem_wb_alu_lo), .aluop(id_aluop), 
                .hiwrite_in(mem_wb_wb[6]), .lowrite_in(mem_wb_wb[5]), .hiwrite(id_hiwrite), .lowrite(id_lowrite),
                .hi_rd(id_hi_rd), .lo_rd(id_lo_rd), .is_ri_excp(id_is_ri_excp), .cp0_write(id_cp0_write),
                .is_eret_excp(id_eret_excp));

    //ID_EX   
    ID_EX id_ex (.clk(clk), .rst(rst), .wb_in({id_hiwrite, id_lowrite, id_link, id_writetype, id_regwrite}),
                .mem_in({id_mem_type, id_memwrite, id_memread}), .ex_in({id_alusrca, id_alusrcb, id_aluop}),
                .rd1_in(id_rd1), .rd2_in(id_rd2), .signimm_in(id_signimm), .inst25_21_in(if_id_inst[25:21]),
                .inst20_16_in(if_id_inst[20:16]), .inst15_11_in(if_id_inst[15:11]), .inst10_6_in(if_id_inst[10:6]),
                .jump_in(id_jump), .branch_in(id_branch), .jump_ad_in(id_jump_ad), .branch_ad_in(id_branch_ad),    
                .pc_add8_in(id_pcadd8), .wa_in(id_wa), .wb_out(id_ex_wb), .mem_out(id_ex_mem), .ex_out(id_ex_ex), 
                .rd1_out(id_ex_rd1), .rd2_out(id_ex_rd2), .signimm_out(id_ex_signimm),.inst25_21_out(id_ex_inst25_21), 
                .inst20_16_out(id_ex_inst20_16), .inst15_11_out(id_ex_inst15_11), .inst10_6_out(id_ex_inst10_6),
                .jump_out(id_ex_jump), .branch_out(id_ex_branch), .jump_ad_out(id_ex_jump_ad),
                .branch_ad_out(id_ex_branch_ad),  .pc_add8_out(id_ex_pcadd8), .wa_out(id_ex_wa), .hi_rd_in(id_hi_rd),
                .lo_rd_in(id_lo_rd),.hi_rd_out(id_ex_hi_rd), .lo_rd_out(id_ex_lo_rd), .is_syscall_in(id_is_syscall),
                .is_break_in(id_is_break),.is_syscall_out(id_ex_is_syscall), .is_break_out(id_ex_is_break),
                .is_pc_excp_in(if_id_is_pc_excp), .is_pc_excp_out(id_ex_is_pc_excp), .is_ri_excp_in(id_is_ri_excp),
                .is_ri_excp_out(id_ex_is_ri_excp), .cp0_write_in(id_cp0_write), .cp0_write_out(id_ex_cp0_write),
                .in_delayslot_in(if_id_in_delayslot), .in_delayslot_out(id_ex_in_delayslot),
                .is_eret_excp_in(id_eret_excp), .is_eret_excp_out(id_ex_eret_excp), .inst_out(id_ex_inst),
                .inst_in(if_id_inst), .flush(excp_is_exc || stall || ex_mem_eret_excp ));

    //EX层
    EX_step ex (.forwarda(fwa_alu), .forwardb(fwb_alu), .mem_bypass(ex_mem_bypass_data), .wb_bypass(wb_wd),
                .inst10_6(id_ex_inst10_6), .alusrca(id_ex_ex[5]), .alusrcb(id_ex_ex[4]), .aluop(id_ex_ex[3:0]),
                .signimm(id_ex_signimm), .da1(id_ex_rd1), .da2(id_ex_rd2), .aluout(ex_aluout), .da2_out(ex_da2),
                .alu_hi(ex_alu_hi), .alu_lo(ex_alu_lo), .id_ex_hi(id_ex_hi_rd), .id_ex_lo(id_ex_lo_rd),
                .ex_mem_hi(ex_mem_alu_hi), .ex_mem_lo(ex_mem_alu_lo), .hi_rd(ex_hi_rd), .lo_rd(ex_lo_rd),
                .is_overflow(ex_is_overflow), .forward_hi(fw_hi), .forward_lo(fw_lo), .wb_hi(mem_wb_alu_hi),
                .wb_lo(mem_wb_alu_lo), .writetype(id_ex_wb[3:1]), .bypass_data(ex_bypass_data), .cp0_readdata(cp0_readdata)); 


    //EX_MEM
    EX_MEM ex_mem (.clk(clk), .rst(rst), .wb_in(id_ex_wb), .mem_in(id_ex_mem), .wa_in(id_ex_wa), .aluout_in(ex_aluout),
                    .da2_in(ex_da2), .pc_add8_in(id_ex_pcadd8), .rt_in(id_ex_inst20_16), .wb_out(ex_mem_wb),
                    .mem_out(ex_mem_mem), .wa_out(ex_mem_wa), .aluout_out(ex_mem_aluout), .da2_out(ex_mem_da2),
                    .pc_add8_out(ex_mem_pcadd8), .rt_out(ex_mem_rt), .alu_hi_out(ex_mem_alu_hi), .alu_lo_out(ex_mem_alu_lo),
                    .alu_hi_in(ex_alu_hi), .alu_lo_in(ex_alu_lo), .hi_rd_in(ex_hi_rd), .lo_rd_in(ex_lo_rd),
                    .hi_rd_out(ex_mem_hi_rd), .lo_rd_out(ex_mem_lo_rd), .is_overflow_in(ex_is_overflow),
                    .is_overflow_out(ex_mem_is_overflow), .is_break_in(id_ex_is_break), .is_syscall_in(id_ex_is_syscall),
                    .is_break_out(ex_mem_is_break), .is_syscall_out(ex_mem_is_syscall), .is_pc_excp_in(id_ex_is_pc_excp),
                    .is_pc_excp_out(ex_mem_is_pc_excp), .is_ri_excp_in(id_ex_is_ri_excp), .is_ri_excp_out(ex_mem_is_ri_excp),
                    .cp0_write_in(id_ex_cp0_write), .cp0_write_out(ex_mem_cp0_write), .in_delayslot_in(id_ex_in_delayslot),
                    .in_delayslot_out(ex_mem_in_delayslot), .cp0_readdata_in(cp0_readdata), .cp0_cause_in(cp0_cause),
                    .cp0_readdata_out(ex_mem_cp0_readdata), .is_eret_excp_in(id_ex_eret_excp), .inst_in(id_ex_inst), 
                    .is_eret_excp_out(ex_mem_eret_excp), .cp0_cause_out(ex_mem_cp0_cause), .cp0_status_in(cp0_status),
                    .cp0_status_out(ex_mem_cp0_status), .inst_out(ex_mem_inst), .flush(excp_is_exc || ex_mem_eret_excp),
                    .bypass_data_in(ex_bypass_data), .bypass_data_out(ex_mem_bypass_data));


    //MEM层
    MEM_step mem(.clk(clk), .rst(rst), .aluout(ex_mem_aluout), .da2(ex_mem_da2), .pc_add8(ex_mem_pcadd8),
                .mem_ctl(ex_mem_mem), .is_pc_excp(ex_mem_is_pc_excp), .is_overflow(ex_mem_is_overflow),
                .is_ri_excp(ex_mem_is_ri_excp), .is_syscall(ex_mem_is_syscall), .is_break(ex_mem_is_break),
                .status(ex_mem_cp0_status), .cause(ex_mem_cp0_cause), .ext_int(ext_int), .cp0_write(ex_mem_cp0_write),
                .indelayslot(ex_mem_in_delayslot), .rd(id_ex_inst15_11), .wa(ex_mem_wa), .wb_in(ex_mem_wb),
                .wb_out(mem_wb), .cp0_readdata(cp0_readdata), .cp0_epc(cp0_epc), .cp0_status(cp0_status),
                .cp0_cause(cp0_cause), .isexc(excp_is_exc), .data_addr(data_addr), .data_write(data_write),
                .is_eret_excp(ex_mem_eret_excp),  .sign(sign), .data_wen(data_wen), .data_ren(data_ren),
                .sel_bytes(sel_bytes));


    //MEM_WB
    MEM_WB mem_wb_step (.clk(clk), .rst(rst), .wb_in(mem_wb), .wa_in(ex_mem_wa), .readdata_in(data_read), 
                    .aluout_in(ex_mem_aluout), .pc_add8_in(ex_mem_pcadd8), .wb_out(mem_wb_wb), .wa_out(mem_wb_wa),
                    .readdata_out(mem_wb_rd), .aluout_out(mem_wb_aluout), .pc_add8_out(mem_wb_pcadd8), 
                    .alu_hi_in(ex_mem_alu_hi), .alu_lo_in(ex_mem_alu_lo), .alu_hi_out(mem_wb_alu_hi),
                    .alu_lo_out(mem_wb_alu_lo), .lo_rd_in(ex_mem_lo_rd), .hi_rd_in(ex_mem_hi_rd),
                    .lo_rd_out(mem_wb_lo_rd), .hi_rd_out(mem_wb_hi_rd), .cp0_readdata_in(ex_mem_cp0_readdata),
                    .cp0_readdata_out(mem_wb_cp0_readdata), .inst_in(ex_mem_inst), .inst_out(debug_inst_out));


    //WB层
    assign wb_wd =
    mem_wb_wb[4] ? mem_wb_pcadd8 :
    (mem_wb_wb[3:1] == 3'b000) ? mem_wb_aluout :
    (mem_wb_wb[3:1] == 3'b001) ? mem_wb_rd :
    (mem_wb_wb[3:1] == 3'b010) ? mem_wb_lo_rd :
    (mem_wb_wb[3:1] == 3'b011) ? mem_wb_hi_rd :
                            mem_wb_cp0_readdata;

    //debug输出
    assign debug_wb_pc = mem_wb_pcadd8 - 8;
    assign debug_wb_rf_wen = {4{mem_wb_wb[0]}};
    assign debug_wb_rf_wnum = mem_wb_wa;
    assign debug_wb_rf_wdata = wb_wd;


    //旁路判断
    bypass_ctl bypass_ctl (.id_ex_rs(id_ex_inst25_21), .id_ex_rt(id_ex_inst20_16), .if_id_rs(if_id_inst[25:21]),
                            .if_id_rt(if_id_inst[20:16]), .ex_mem_wa(ex_mem_wa), .mem_wb_wa(mem_wb_wa),
                            .ex_mem_regwrite(ex_mem_wb[0]), .mem_wb_regwrite(mem_wb_wb[0]), .writetype(id_ex_wb[3:1]),
                            .ex_mem_hiwrite(ex_mem_wb[6]), .ex_mem_lowrite(ex_mem_wb[5]), .mem_wb_hiwrite(mem_wb_wb[6]), 
                            .mem_wb_lowrite(mem_wb_wb[5]),.forwarda_jb(fwa_jb), .forwardb_jb(fwb_jb), .forwarda_alu(fwa_alu),
                            .forwardb_alu(fwb_alu), .forward_hi(fw_hi), .forward_lo(fw_lo));

    //阻塞控制单元
    stall_ctl stall_ctl (.id_ex_memread(id_ex_mem[0]), .id_ex_regwrite(id_ex_wb[0]), .ex_mem_memread(ex_mem_mem[0]),
                         .ex_mem_regwrite(ex_mem_wb[0]), .id_ex_wa(id_ex_wa), .ex_mem_wa(ex_mem_wa), .if_id_rs(if_id_inst[25:21]),
                         .if_id_rt(if_id_inst[20:16]),.if_id_opcode(if_id_inst[31:26]), .if_id_func(if_id_inst[5:0]), .stall(stall));

endmodule



