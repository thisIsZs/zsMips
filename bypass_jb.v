`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/16 10:36:23
// Design Name: 
// Module Name: bypass_jb
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


module bypass_jb(
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] ex_mem_rd,
    input  ex_mem_regwrite,
    output  forwarda,
    output  forwardb
    );

    assign forwarda = ( ex_mem_regwrite &&  ex_mem_rd != 5'b0 && rs == ex_mem_rd) ? 1'b1 : 1'b0;
    assign forwardb =  ( ex_mem_regwrite &&  ex_mem_rd != 5'b0 && rt == ex_mem_rd) ? 1'b1 : 1'b0;

endmodule
