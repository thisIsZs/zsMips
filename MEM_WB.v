`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/30 14:15:05
// Design Name: 
// Module Name: MEM_WB
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


module MEM_WB(
    input clk,
    input rst, //高电位有效

    input [6:0] wb_in,
    input [4:0] wa_in,
    input [31:0] readdata_in, aluout_in, pc_add8_in,
    input [31:0] alu_hi_in, alu_lo_in,
    input [31:0] hi_rd_in, lo_rd_in,
    input [31:0] cp0_readdata_in,   
    input [3:0]  sel_bytes_in,
    input [31:0] inst_in,

    output reg [6:0] wb_out,
    output reg [4:0] wa_out,
    output reg [31:0] readdata_out, aluout_out, pc_add8_out,
    output reg [31:0] alu_hi_out, alu_lo_out,
    output reg [31:0] hi_rd_out, lo_rd_out,
    output reg [31:0] cp0_readdata_out,
    output reg [3:0]  sel_bytes_out,
    output reg [31:0] inst_out
    );

    always @(posedge clk) 
    begin
        if(!rst)
            begin
                wb_out <= wb_in;
                wa_out <= wa_in;
                readdata_out <= readdata_in;
                aluout_out <= aluout_in;
                pc_add8_out <= pc_add8_in;
                alu_hi_out <= alu_hi_in;
                alu_lo_out <= alu_lo_in;
                hi_rd_out <= hi_rd_in;
                lo_rd_out <= lo_rd_in;
                cp0_readdata_out <= cp0_readdata_in;
                sel_bytes_out <= sel_bytes_in;
                inst_out <= inst_in;
            end
        else
            begin
                wb_out <= 7'b0;
                wa_out <= 5'b0;
                aluout_out <= 32'b0;
                readdata_out <= 32'b0;
                pc_add8_out <= 32'b0;
                alu_hi_out <= 32'b0;
                alu_lo_out <= 32'b0;
                hi_rd_out <= 32'b0;
                lo_rd_out <= 32'b0;
                cp0_readdata_out <= 32'b0;
                sel_bytes_out <= 4'b0;
                inst_out <= 32'b0;
            end
    end
endmodule

