`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/30 14:01:04
// Design Name: 
// Module Name: IF_ID
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


module IF_ID(
    input clk, 
    input rst,            // 高电平有效
    input stall,          // 阻塞信号
    input [31:0] pc_adder_in,
    input [31:0] inst_in,
    input is_pc_excp_in,
    input in_delayslot_in,

    output reg [31:0] pc_adder_out,
    output reg [31:0] inst_out,
    output reg is_pc_excp_out,
    output reg in_delayslot_out
);

    always @(posedge clk) begin
        if(rst) begin
            pc_adder_out     <= 32'b0;
            inst_out         <= 32'b0;
            is_pc_excp_out   <= 1'b0;
            in_delayslot_out <= 1'b0;
        end
        else if (!stall) begin
            // 正常工作或不阻塞时，更新流水线寄存器
            pc_adder_out     <= pc_adder_in;
            inst_out         <= inst_in;
            is_pc_excp_out   <= is_pc_excp_in;
            in_delayslot_out <= in_delayslot_in;
        end
        // 如果 stall == 1，不执行赋值动作，寄存器将自动保持上一周期的值
    end

endmodule