`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/30 14:13:12
// Design Name: 
// Module Name: EX_MEM
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


module EX_MEM(
    //控制
    input clk,
    input rst,//高电位有效
    input flush,
    //输入
    input [6:0] wb_in,
    input [5:0] mem_in,
    input [4:0] wa_in,
    input [31:0] aluout_in, da2_in,
    input [31:0] pc_add8_in,
    input [4:0] rt_in,
    input [31:0] alu_hi_in, alu_lo_in,
    input [31:0] lo_rd_in, hi_rd_in,
    input [31:0] cp0_readdata_in,
    input is_overflow_in,
    input is_break_in, is_syscall_in,
    input is_pc_excp_in, is_ri_excp_in,
    input cp0_write_in,
    input in_delayslot_in, is_eret_excp_in,
    input [31:0] cp0_cause_in, cp0_status_in,
    input [31:0] inst_in,
    input [31:0] bypass_data_in,

    //输出
    output reg [6:0] wb_out,
    output reg [5:0] mem_out,
    output reg [4:0] wa_out,
    output reg [31:0] aluout_out, da2_out,
    output reg [31:0] pc_add8_out,
    output reg [4:0] rt_out,
    output reg [31:0] alu_hi_out, alu_lo_out,
    output reg [31:0] lo_rd_out, hi_rd_out,
    output reg [31:0] cp0_readdata_out,
    output reg is_overflow_out,
    output reg is_break_out, is_syscall_out,
    output reg is_pc_excp_out, is_ri_excp_out,
    output reg cp0_write_out,
    output reg in_delayslot_out, is_eret_excp_out,
    output reg [31:0] cp0_cause_out, cp0_status_out,
    output reg [31:0] inst_out,
    output reg [31:0] bypass_data_out
    );
    
    always @(posedge clk) begin
        if (rst) begin // 假设你的代码中 rst 为高电平复位
            wb_out <= 7'b0;
            mem_out <= 6'b0;
            wa_out <= 5'b0;
            aluout_out <= 32'b0;
            da2_out <= 32'b0;
            pc_add8_out <= 32'b0;
            rt_out <= 5'b0;
            alu_hi_out <= 32'b0;
            alu_lo_out <= 32'b0;
            lo_rd_out <= 32'b0;
            hi_rd_out <= 32'b0;
            is_overflow_out <= 1'b0;
            is_break_out <= 1'b0;
            is_syscall_out <= 1'b0;
            is_pc_excp_out <= 1'b0;
            is_ri_excp_out <= 1'b0;
            cp0_write_out <= 1'b0;
            in_delayslot_out <= 1'b0;
            cp0_readdata_out <= 32'b0;
            is_eret_excp_out <= 1'b0;
            cp0_cause_out <= 32'b0;
            cp0_status_out <= 32'b0;
            inst_out <= 32'b0;
            bypass_data_out <= 32'b0;
        end
        else if (flush) begin // 添加 flush 分支
            wb_out <= 7'b0;
            mem_out <= 6'b0;
            cp0_write_out <= 1'b0;
            wa_out <= 5'b0;
            aluout_out <= 32'b0;
            da2_out <= 32'b0;
            rt_out <= 5'b0;
            alu_hi_out <= 32'b0;
            alu_lo_out <= 32'b0;
            lo_rd_out <= 32'b0;
            hi_rd_out <= 32'b0;
            is_overflow_out <= 1'b0;
            is_break_out <= 1'b0;
            is_syscall_out <= 1'b0;
            is_pc_excp_out <= 1'b0;
            is_ri_excp_out <= 1'b0;
            in_delayslot_out <= 1'b0;
            cp0_readdata_out <= 32'b0;
            is_eret_excp_out <= 1'b0;
            cp0_cause_out <= 32'b0;
            cp0_status_out <= 32'b0;
        end
        else begin // 正常流动
            wb_out <= wb_in;
            mem_out <= mem_in;
            wa_out <= wa_in;
            aluout_out <= aluout_in;
            pc_add8_out <= pc_add8_in;
            da2_out <= da2_in;
            rt_out <= rt_in;
            alu_hi_out <= alu_hi_in;
            alu_lo_out <= alu_lo_in;
            lo_rd_out <= lo_rd_in;
            hi_rd_out <= hi_rd_in;
            is_overflow_out <= is_overflow_in;
            is_break_out <= is_break_in;
            is_syscall_out <= is_syscall_in;
            is_pc_excp_out <= is_pc_excp_in;
            is_ri_excp_out <= is_ri_excp_in;
            cp0_write_out <= cp0_write_in;
            in_delayslot_out <= in_delayslot_in;
            cp0_readdata_out <= cp0_readdata_in;
            is_eret_excp_out <= is_eret_excp_in;
            cp0_cause_out <= cp0_cause_in;
            cp0_status_out <= cp0_status_in;
            inst_out <= inst_in;
            bypass_data_out <= bypass_data_in;
        end
    end
endmodule
