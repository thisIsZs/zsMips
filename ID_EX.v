`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/30 14:09:29
// Design Name: 
// Module Name: ID_EX
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


module ID_EX(
    //控制信号
    input clk, 
    input rst, //高电位有效
    input flush,
    //输入
    input [6:0] wb_in,
    input [5:0] mem_in,
    input [5:0] ex_in,
    input [31:0] rd1_in, rd2_in, signimm_in,
    input [4:0] inst25_21_in, inst20_16_in, inst15_11_in, inst10_6_in,
    input jump_in, branch_in,
    input [31:0] jump_ad_in, branch_ad_in,
    input [31:0] pc_add8_in, 
    input [4:0] wa_in,
    input [31:0] hi_rd_in, lo_rd_in,
    input is_syscall_in, is_break_in,
    input is_ri_excp_in, is_pc_excp_in,
    input cp0_write_in, in_delayslot_in,
    input is_eret_excp_in,
    input [31:0] inst_in,

    //输出
    output reg [6:0] wb_out,
    output reg [5:0] mem_out,
    output reg [5:0] ex_out,
    output reg [31:0] rd1_out, rd2_out, signimm_out,
    output reg [4:0] inst25_21_out, inst20_16_out, inst15_11_out, inst10_6_out,
    output reg jump_out, branch_out,
    output reg [31:0] jump_ad_out, branch_ad_out,
    output reg [31:0] pc_add8_out,
    output reg [4:0] wa_out,
    output reg [31:0] hi_rd_out, lo_rd_out,
    output reg is_syscall_out, is_break_out, 
    output reg is_ri_excp_out, is_pc_excp_out,
    output reg cp0_write_out, in_delayslot_out,
    output reg is_eret_excp_out,
    output reg [31:0] inst_out
    );

        always @(posedge clk) begin
            if (rst) begin // 情况 1：复位 (Reset)
                // 将所有输出信号清零，初始化 CPU 状态
                wb_out           <= 7'b0;
                mem_out          <= 6'b0;
                ex_out           <= 6'b0;
                rd1_out          <= 32'b0;
                rd2_out          <= 32'b0;
                signimm_out      <= 32'b0;
                inst25_21_out    <= 5'b0;
                inst20_16_out    <= 5'b0;
                inst15_11_out    <= 5'b0;
                inst10_6_out     <= 5'b0;
                jump_out         <= 1'b0;
                branch_out       <= 1'b0;
                jump_ad_out      <= 32'b0;
                branch_ad_out    <= 32'b0;
                pc_add8_out      <= 32'b0;
                wa_out           <= 5'b0;
                hi_rd_out        <= 32'b0;
                lo_rd_out        <= 32'b0;
                is_break_out     <= 1'b0;
                is_syscall_out   <= 1'b0;
                is_ri_excp_out   <= 1'b0;
                is_pc_excp_out   <= 1'b0;
                cp0_write_out    <= 1'b0;
                in_delayslot_out <= 1'b0;
                is_eret_excp_out <= 1'b0;
                inst_out         <= 32'b0;
            end 
            else if (flush) begin // 情况 2：冲刷 (Flush)
                // 优先级仅次于复位。发生例外或分支预测失败，清空当前指令（插入 NOP）
                wb_out           <= 7'b0;
                mem_out          <= 6'b0;
                ex_out           <= 6'b0;
                rd1_out          <= 32'b0;
                rd2_out          <= 32'b0;
                signimm_out      <= 32'b0;
                inst25_21_out    <= 5'b0;
                inst20_16_out    <= 5'b0;
                inst15_11_out    <= 5'b0;
                inst10_6_out     <= 5'b0;
                jump_out         <= 1'b0;
                branch_out       <= 1'b0;
                jump_ad_out      <= 32'b0;
                branch_ad_out    <= 32'b0;
                wa_out           <= 5'b0;
                hi_rd_out        <= 32'b0;
                lo_rd_out        <= 32'b0;
                is_break_out     <= 1'b0;
                is_syscall_out   <= 1'b0;
                is_ri_excp_out   <= 1'b0;
                is_pc_excp_out   <= 1'b0;
                cp0_write_out    <= 1'b0;
                in_delayslot_out <= 1'b0;
                is_eret_excp_out <= 1'b0;
            end 
            else begin // 情况 4：正常流动 (Normal)
                // 每一个时钟上升沿将上一级的输入传递给下一级
                wb_out           <= wb_in;
                mem_out          <= mem_in;
                ex_out           <= ex_in;
                rd1_out          <= rd1_in;
                rd2_out          <= rd2_in;
                signimm_out      <= signimm_in;
                inst25_21_out    <= inst25_21_in;
                inst20_16_out    <= inst20_16_in;
                inst15_11_out    <= inst15_11_in;
                inst10_6_out     <= inst10_6_in;
                jump_out         <= jump_in;
                branch_out       <= branch_in;
                jump_ad_out      <= jump_ad_in;
                branch_ad_out    <= branch_ad_in;
                pc_add8_out      <= pc_add8_in;
                wa_out           <= wa_in;
                hi_rd_out        <= hi_rd_in;
                lo_rd_out        <= lo_rd_in;
                is_break_out     <= is_break_in;
                is_syscall_out   <= is_syscall_in;
                is_ri_excp_out   <= is_ri_excp_in;
                is_pc_excp_out   <= is_pc_excp_in;
                cp0_write_out    <= cp0_write_in;
                in_delayslot_out <= in_delayslot_in;
                is_eret_excp_out <= is_eret_excp_in;
                inst_out         <= inst_in;
            end
        end
endmodule
