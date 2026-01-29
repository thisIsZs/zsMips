`timescale 1ns / 1ps
`define EXC_ENTRY_ADDR      32'hbfc00380
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/30 14:00:15
// Design Name: 
// Module Name: IF_step
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



module IF_step(
    input clk,
    input rst,//高电位有效
    input [31:0] pc_branch, pc_jump, epc,
    input jump, branch,
    input stall,
    input is_eret_excp,
    input is_exc,

    output is_pc_excp,
    output [31:0] pc, pcadder_out
    );

    wire [31:0] pc_temp;
    wire [31:0] pcadder;

    assign pcadder_out = pc + 3'h4;
    assign is_pc_excp = (pc[1:0] != 2'b00) ? 1'b1 : 1'b0;

    pc  my_pc(.clk(clk), .rst(rst), .pcin(pcadder_out), 
              .stall(stall), .pcout(pc_temp));
    
    assign pc = is_exc        ? `EXC_ENTRY_ADDR : // 发生例外，强制跳转到入口地址(如0x80000080)
                is_eret_excp  ? epc             : // 执行eret指令，返回到EPC指向的地址
                jump          ? pc_jump         : // 正常跳转指令
                branch        ? pc_branch       : // 正常分支指令
                                pc_temp;          // 默认：PC + 4
    
endmodule
