`timescale 1ns / 1ps
`include "ZsMips.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/30 14:02:50
// Design Name: 
// Module Name: jump_dec
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


module jump_dec(
    input [5:0] opcode,
    input [5:0] func,
    output reg is_ri_excp,
    output reg jump,
    output reg jump_ad_sel,
    output reg link_31reg,
    output reg link,
    output reg delay_slot
    );
    always @(opcode, func) begin
        // 默认值，防止锁存器
        is_ri_excp = 1'b0;
        delay_slot = 1'b0;
        case(opcode)
        `R_OP:begin jump_ad_sel <= 1'b0;
                     link_31reg <= 1'b0;
                     jump <= (func == `JR_FUNC || func == `JALR_FUNC) ? 1'b1 : 1'b0;
                     link <= (func == `JALR_FUNC) ? 1'b1 : 1'b0;
                     delay_slot <= (func == `JR_FUNC || func==`JALR_FUNC ) ? 1'b1 : 1'b0;
                end     
        `J_OP: begin jump_ad_sel <= 1'b1; jump <= 1'b1; link_31reg <= 1'b0; link <= 1'b0; delay_slot <= 1'b1; end
        `JAL_OP: begin jump_ad_sel <= 1'b1; jump <= 1'b1; link_31reg <= 1'b1; link <= 1'b1; delay_slot <= 1'b1; end
        default: begin jump <= 1'b0; jump_ad_sel <= 1'b0; is_ri_excp <= 1'b1;
                     link_31reg <= 1'b0; link <= 1'b0; delay_slot <= 1'b0; end
        endcase
    end
endmodule
