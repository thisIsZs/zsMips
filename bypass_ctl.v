`timescale 1ns / 1ps

module bypass_ctl(
    // 通用寄存器转发输入 
    input [4:0] id_ex_rs,
    input [4:0] id_ex_rt,
    input [4:0] if_id_rs,  
    input [4:0] if_id_rt,       
    input [4:0] ex_mem_wa,
    input [4:0] mem_wb_wa,
    input ex_mem_regwrite,
    input mem_wb_regwrite,

    // HI/LO 转发输入 (来自 bypass_hilo)
    input [2:0] writetype,
    input ex_mem_hiwrite,
    input ex_mem_lowrite,
    input mem_wb_hiwrite,
    input mem_wb_lowrite,

    // ALU 转发输出
    output [1:0] forwarda_alu,
    output [1:0] forwardb_alu,

    // 跳转指令转发输出
    output forwarda_jb,
    output forwardb_jb,

    // HI/LO 转发输出
    output [1:0] forward_hi,
    output [1:0] forward_lo
);

    // 1. ALU 通用寄存器转发逻辑 
    // 优先级：EX 阶段数据 > MEM 阶段数据 > 寄存器堆数据
    assign forwarda_alu = (ex_mem_regwrite && (ex_mem_wa != 5'b0) && (id_ex_rs == ex_mem_wa)) ? 2'b10 :
                          ((mem_wb_regwrite && (mem_wb_wa != 5'b0) && (id_ex_rs == mem_wb_wa)) ? 2'b01 : 2'b00); 

    assign forwardb_alu = (ex_mem_regwrite && (ex_mem_wa != 5'b0) && (id_ex_rt == ex_mem_wa)) ? 2'b10 :
                          ((mem_wb_regwrite && (mem_wb_wa != 5'b0) && (id_ex_rt == mem_wb_wa)) ? 2'b01 : 2'b00); 
    // 2. 跳转/分支指令 (Jump/Branch) 转发逻辑 
    // 通常用于 ID 阶段的提前分支判断，仅检测 EX 阶段的冲突
    assign forwarda_jb = (ex_mem_regwrite && (ex_mem_wa != 5'b0) && (if_id_rs == ex_mem_wa)) ? 1'b1 : 1'b0; 
    assign forwardb_jb = (ex_mem_regwrite && (ex_mem_wa != 5'b0) && (if_id_rt == ex_mem_wa)) ? 1'b1 : 1'b0; 

    // 3. HI/LO 特殊寄存器转发逻辑 
    // 根据写入类型 (writetype) 判断是否需要转发
    assign forward_lo = (writetype == 3'b010) ? (ex_mem_lowrite ? 2'b10 : 
                                               (mem_wb_lowrite ? 2'b01 : 2'b00)) : 2'b00;

    assign forward_hi = (writetype == 3'b011) ? (ex_mem_hiwrite ? 2'b10 : 
                                               (mem_wb_hiwrite ? 2'b01 : 2'b00)) : 2'b00;
endmodule