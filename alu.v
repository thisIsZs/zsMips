`timescale 1ns / 1ps
`include "ZsMips.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/18 15:34:28
// Design Name: 
// Module Name: alu
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

/*PWS 标志位定义
Z: Zero  
N: Negative  
C: Carry  
V: Overflow
*/
module alu(
    input  [4:0]  aluctl,
    input  [31:0] a, b,
    output reg [31:0] aluout,
    output reg [31:0] hi,
    output reg [31:0] lo,
    output reg is_overflow
);
    reg Z, N, C, V; // PSW 标志位
    reg [63:0] mult_result;
    reg [32:0] tmp;   // 用于加减法进位 / 借位

    always @(*) begin
        // 默认值
        aluout = 32'b0;
        hi = 32'b0;
        lo = 32'b0;
        C = 1'b0;
        V = 1'b0;
        is_overflow = 1'b0;

        case(aluctl)
            `AND_CTL: aluout = a & b;
            `OR_CTL:  aluout = a | b;
            `XOR_CTL: aluout = a ^ b;
            `NOR_CTL: aluout = ~(a | b);

            `ADD_CTL: begin
                aluout = a+b;
                V = (~(a[31] ^ b[31])) & (aluout[31] ^ a[31]);
                if(V)
                    is_overflow = 1'b1;
            end
            `ADDU_CTL: begin
                {C, aluout} = a + b;
            end

            `SUB_CTL: begin
                aluout = a - b;
                V = (a[31] ^ b[31]) & (aluout[31] ^ a[31]);
                if(V)
                    is_overflow = 1'b1;
            end

            `SUBU_CTL: begin
                {C, aluout} = {1'b0, a} - {1'b0, b};
            end

            `SLL_CTL: aluout = b << a[4:0];
            `SRL_CTL: aluout = b >> a[4:0];
            `SRA_CTL: aluout = $signed(b) >>> a[4:0];
            `SLT_CTL: aluout = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
            `SLTU_CTL: aluout = (a < b) ? 32'b1 : 32'b0;
            `SLLV_CTL: begin aluout = b << a[4:0]; end
            `SRLV_CTL: begin aluout = b >> a[4:0]; end
            `SRAV_CTL: begin aluout = $signed(b) >>> a[4:0]; end

            `MULT_CTL: begin
                mult_result = $signed(a) * $signed(b);
                lo = mult_result[31:0];
                hi = mult_result[63:32];
            end
            `MULTU_CTL: begin
                mult_result = a * b;
                lo = mult_result[31:0];
                hi = mult_result[63:32];
            end

            `DIV_CTL: begin
                if (b != 32'b0) begin
                    lo = $signed(a) / $signed(b);   // 商
                    hi = $signed(a) % $signed(b);   // 余数
                end else begin
                    lo = 32'b0;
                    hi = 32'b0;
                end
            end
            `DIVU_CTL: begin
                if (b != 32'b0) begin
                    lo = a / b;   // 无符号商
                    hi = a % b;   // 无符号余数
                end else begin
                    lo = 32'b0;
                    hi = 32'b0;
                end
            end

            `MTHI_CTL: begin
                hi = a;
            end

            `MTLO_CTL: begin
                lo = a;
            end

            default: aluout = 32'b0;
        endcase

        // PSW 标志
        Z = (aluout == 32'b0);
        N = aluout[31];

    end
endmodule


