`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/22 11:43:12
// Design Name: 
// Module Name: signext
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


module signext(
    input [15:0] a,
    input sign, 
    input sign_type, //0高位扩展， 1低位扩展
    output [31:0] b
    );
    wire [31:0] b1, b2;
    assign b1 = sign ? {{16{a[15]}}, a}:{16'b0, a};
    assign b2 = {a, 16'b0};
    assign b = sign_type ? b2 : b1;

endmodule
