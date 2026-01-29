`timescale 1ns / 1ps
`include "ZsMips.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/23 17:04:02
// Design Name: 
// Module Name: branch_dec
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


module branch_dec(
    input  [5:0]  opcode,
    input  [4:0]  bz_special, // rt field
    input  [31:0] a, b,

    output reg    delay_slot,
    output reg    is_ri_excp,
    output reg    branch,
    output reg    link_31reg,
    output reg    link
);

    always @(*) begin
        // 默认值，防止锁存器
        branch      = 1'b0;
        link_31reg  = 1'b0;
        link        = 1'b0;
        is_ri_excp  = 1'b0;
        delay_slot  = 1'b1;

        case(opcode)
            `BEQ_OP:  branch = (a == b);
            `BNE_OP:  branch = (a != b);
            `BGTZ_OP: branch = (!a[31] && (a != 32'b0)); // a > 0
            `BLEZ_OP: branch = (a[31] || (a == 32'b0));  // a <= 0

            `BZ_OP: begin
                case (bz_special)
                    `BLTZ_TYPE: branch = a[31];
                    `BGEZ_TYPE: branch = !a[31];
                    `BLTZAL_TYPE: begin
                        branch     = a[31];
                        link_31reg = 1'b1;
                        link = 1'b1;
                    end
                    `BGEZAL_TYPE: begin
                        branch     = !a[31];
                        link_31reg = 1'b1;
                        link = 1'b1;
                    end

                    default: is_ri_excp = 1'b1;
                endcase
            end

            default:begin  is_ri_excp = 1'b1; delay_slot = 1'b0; end
        endcase
    end
endmodule

