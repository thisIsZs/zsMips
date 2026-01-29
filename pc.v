`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/30 13:57:06
// Design Name: 
// Module Name: pc
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


module pc
(
    input clk,
    input rst,
    input stall, //高电位有效
    input [31:0] pcin,
    output reg [31:0] pcout
    );

    
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            pcout <= 32'hbfc00000;
        end
        else 
            begin
             if(!stall)
                pcout <= pcin;
            end
    end
    

endmodule

