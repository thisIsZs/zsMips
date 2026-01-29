`timescale 1ns / 1ps
`include "ZsMips.vh"

module stall_ctl(
    input id_ex_memread,    // 前指令 (EXE级) 是 Load
    input id_ex_regwrite,   // 前指令 (EXE级) 写寄存器
    input ex_mem_memread,   // 前前指令 (MEM级) 是 Load
    input ex_mem_regwrite,  // 前前指令 (MEM级) 写寄存器
    
    input [4:0] id_ex_wa,   // EXE级目标地址
    input [4:0] ex_mem_wa,  // MEM级目标地址
    
    input [4:0] if_id_rs,   
    input [4:0] if_id_rt,   
    input [5:0] if_id_opcode,
    input [5:0] if_id_func,

    output stall            
);

    // id层时branch/jump指令识别
    wire is_bj;
    assign is_bj = (if_id_opcode == `BEQ_OP) || (if_id_opcode == `BNE_OP) || 
                   (if_id_opcode == `BGTZ_OP) || (if_id_opcode == `BLEZ_OP) || 
                   (if_id_opcode == `BZ_OP) || 
                   (if_id_opcode == `R_OP && (if_id_func == `JR_FUNC || if_id_func == `JALR_FUNC));

    // --- 2. 冲突逻辑 ---

    // (A) 标准 Load-Use (Load 后紧跟 ALU 计算)
    // 阻塞 1 周期，靠 MEM -> EXE 旁路解决
    wire stall_load_use;
    assign stall_load_use = id_ex_memread && (id_ex_wa != 5'b0) && 
                            ((id_ex_wa == if_id_rs) || (id_ex_wa == if_id_rt));

    // (B) ALU-to-Branch/Jump
    // 阻塞 1 周期。例如: addu $t1, $t2, $t3; beq $t1, $zero, label
    wire stall_alu_bj;
    assign stall_alu_bj = is_bj && id_ex_regwrite && (id_ex_wa != 5'b0) &&
                          ((id_ex_wa == if_id_rs) || (id_ex_wa == if_id_rt));

    // (C) Load-to-Branch/Jump (最严苛的情况)
    // 需要阻塞 2 周期。
    // 第 1 周期: Load 在 EXE，BJ 在 ID (由 stall_load_bj_1 触发)
    // 第 2 周期: Load 在 MEM，BJ 在 ID (由 stall_load_bj_2 触发)
    wire stall_load_bj_1;
    assign stall_load_bj_1 = is_bj && id_ex_memread && (id_ex_wa != 5'b0) &&
                             ((id_ex_wa == if_id_rs) || (id_ex_wa == if_id_rt));

    wire stall_load_bj_2;
    assign stall_load_bj_2 = is_bj && ex_mem_memread && (ex_mem_wa != 5'b0) &&
                             ((ex_mem_wa == if_id_rs) || (ex_mem_wa == if_id_rt));

    // --- 3. 汇总 ---
    assign stall = stall_load_use || stall_alu_bj || stall_load_bj_1 || stall_load_bj_2;

endmodule