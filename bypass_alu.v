`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/30 14:16:05
// Design Name: 
// Module Name: bypass_alu
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


module bypass_alu(
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] ex_mem_rd,
    input [4:0] mem_wb_rd,
    input ex_mem_regwrite, mem_wb_regwrite,
    output [1:0] forwarda,
    output [1:0] forwardb
    );

    assign forwarda = ( ex_mem_regwrite &&  ex_mem_rd != 5'b0 && rs == ex_mem_rd) ? 2'b10 : (
        ( mem_wb_regwrite && mem_wb_rd != 5'b0 && rs == mem_wb_rd) ? 2'b01 : 2'b00);

    assign forwardb =  ( ex_mem_regwrite &&  ex_mem_rd != 5'b0 && rt == ex_mem_rd) ? 2'b10 : (
        ( mem_wb_regwrite && mem_wb_rd != 5'b0 && rt == mem_wb_rd) ? 2'b01 : 2'b00);

endmodule
