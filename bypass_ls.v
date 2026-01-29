`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/29 14:38:57
// Design Name: 
// Module Name: bypass_ls
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


module bypass_ls(
    input [4:0] ex_mem_rt, mem_wb_ra,
    input mem_wb_regwrite, ex_mem_memwrite,
    input [2:0] mem_wb_writetype,
    output forward
    );

     assign forward = (ex_mem_memwrite && mem_wb_regwrite && mem_wb_writetype==3'b001 && mem_wb_ra != 5'b0
                         && mem_wb_ra == ex_mem_rt) ? 1'b1 : 1'b0;

endmodule
