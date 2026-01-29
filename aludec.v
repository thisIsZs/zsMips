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


module aludec(
    input [3:0] aluop,
    input [5:0] funct,
    output reg [4:0] aluctl
    );

    always @(aluop, funct) begin
       case(aluop)
        `R_ALUOP : 
         begin
            case(funct)
             `ADD_FUNC : aluctl <= `ADD_CTL;
             `ADDU_FUNC: aluctl <= `ADDU_CTL;
             `SUB_FUNC: aluctl <= `SUB_CTL;
             `SUBU_FUNC : aluctl <= `SUBU_CTL;

             `SLT_FUNC: aluctl <= `SLT_CTL;
             `SLTU_FUNC: aluctl <= `SLTU_CTL;

             `AND_FUNC : aluctl <= `AND_CTL;
             `OR_FUNC  : aluctl <= `OR_CTL;
             `XOR_FUNC : aluctl <= `XOR_CTL;
             `NOR_FUNC : aluctl <= `NOR_CTL;

             `SLL_FUNC, `SLLV_FUNC: aluctl <= `SLL_CTL;
             `SRL_FUNC, `SRLV_FUNC: aluctl <= `SRL_CTL;
             `SRA_FUNC, `SRAV_FUNC: aluctl <= `SRA_CTL;

            `DIV_FUNC:    aluctl <= `DIV_CTL;
            `DIVU_FUNC:   aluctl <= `DIVU_CTL;

            `MULT_FUNC:   aluctl <= `MULT_CTL;
            `MULTU_FUNC:  aluctl <= `MULTU_CTL;

            `MTHI_FUNC:   aluctl <= `MTHI_CTL;
            `MTLO_FUNC:   aluctl <= `MTLO_CTL;

             default: aluctl <= 5'b11111;
            endcase
         end

      `ADD_ALUOP: aluctl <= `ADD_CTL;
      `ADDU_ALUOP: aluctl <= `ADDU_CTL;
      `SUB_ALUOP: aluctl <= `SUB_CTL;
      
      `AND_ALUOP: aluctl <= `AND_CTL;
      `OR_ALUOP:  aluctl <= `OR_CTL;
      `XOR_ALUOP: aluctl <= `XOR_CTL;

      `SLTI_ALUOP: aluctl <= `SLT_CTL;
      `SLTIU_ALUOP: aluctl <= `SLTU_CTL;

      default: aluctl <= 5'b11111;
       endcase
    end

endmodule
