`timescale 1ns / 1ps
`include "ZsMips.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/30 14:01:43
// Design Name: 
// Module Name: maindec
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


/*
1'b  alusrca: 0选reg； 1选inst
1'b  hiwrite: 1写hi
1'b  lowrite: 1写lo

3'b  memtype: load store mode(具体见.vh)
1'b  sign_type: 0立即数低位扩展（lui）； 1立即数高位扩展
1'b  memread: 1读mem
1'b  sign: 0零扩展; 1符号扩展
1'b  regwrite: 1写reg
1'b  regdst:  0选rt; 1选rd
1'b  alusrcb: 0选reg； 1选立即数
1'b  memwrite：1写mem 
3'b  writetype: 3'b001reg写入mem读取数据；3'b000reg写入alu数据; 3'b010reg写入lo; 3'b011reg写入hi; 3'b100reg写入cp0
*/
module maindec(
    input  [5:0] opcode,
    input  [5:0] func,
    input  [4:0] cp0_rs,

    output reg        cp0_write,
    output            is_break, is_syscall,
    output reg        is_ri_excp, //reserved instruction exception
    output reg        hiwrite,
    output reg        lowrite,
    output            alusrca,
    output reg        regdst,
    output reg        sign_type,
    output reg [2:0]  writetype,
    output reg        memwrite,
    output reg        alusrcb,
    output reg        regwrite,
    output reg        sign,
    output reg        memread,
    output reg [3:0]  aluop,
    output reg [2:0]  mem_type
);

    assign is_syscall = (opcode == `R_OP) && (func == `SYSCALL_FUNC);
    assign is_break   = (opcode == `R_OP) && (func == `BREAK_FUNC);
    assign alusrca = (opcode == `R_OP) && (func == `SLL_FUNC || func == `SRL_FUNC || func == `SRA_FUNC);

    always @(*) begin
        hiwrite   = 1'b0;  lowrite  = 1'b0;  memread  = 1'b0;
        memwrite = 1'b0;   regwrite = 1'b0;  regdst   = 1'b0;
        alusrcb  = 1'b0;   sign     = 1'b1;  sign_type= 1'b0;
        writetype= 3'b000;  aluop    = 4'b1111; mem_type = 3'b000;
        is_ri_excp = 1'b0; cp0_write = 1'b0;

        case (opcode)
        //R type
        `R_OP: begin
            regdst   = 1'b1;
            regwrite = 1'b1;
            aluop    = `R_ALUOP;
            
            case (func)
                // 普通算术逻辑 
                `ADD_FUNC, `ADDU_FUNC,
                `SUB_FUNC, `SUBU_FUNC,
                `AND_FUNC, `OR_FUNC,
                `XOR_FUNC, `NOR_FUNC,
                `SLT_FUNC, `SLTU_FUNC,
                `SLL_FUNC, `SRL_FUNC, `SRA_FUNC: ;

                // mult,div 
                `MULT_FUNC, `MULTU_FUNC,
                `DIV_FUNC,  `DIVU_FUNC: begin
                    hiwrite   = 1'b1;
                    lowrite  = 1'b1;
                    regwrite = 1'b0;
                end

                //mfhi, mflo 
                `MFHI_FUNC: begin
                    writetype = 3'b011; // HI → reg
                end
                `MFLO_FUNC: begin
                    writetype = 3'b010; // LO → reg
                end

                // mthi, mtlo 
                `MTHI_FUNC: begin
                    hiwrite   = 1'b1;
                    regwrite = 1'b0;
                end
                `MTLO_FUNC: begin
                    lowrite  = 1'b1;
                    regwrite = 1'b0;
                end

                // jr
                `JR_FUNC: begin
                    regwrite = 1'b0;
                end

                default: is_ri_excp = 1'b1; // 保留指令异常
            endcase
        end

        // I type 
        `ADDI_OP: begin
            alusrcb  = 1'b1;
            regwrite = 1'b1;
            aluop    = `ADD_ALUOP;
        end

        `ADDIU_OP: begin
            alusrcb  = 1'b1;
            regwrite = 1'b1;
            aluop    = `ADDU_ALUOP;
        end

        `SLTI_OP: begin
            alusrcb  = 1'b1;
            regwrite = 1'b1;
            aluop    = `SLTI_ALUOP;
        end
        `SLTIU_OP: begin
            alusrcb  = 1'b1;
            regwrite = 1'b1;
            aluop    = `SLTIU_ALUOP;
        end

        `ANDI_OP: begin
            alusrcb  = 1'b1;
            regwrite = 1'b1;
            aluop    = `AND_ALUOP;
            sign     = 1'b0;
        end

        `ORI_OP: begin
            alusrcb  = 1'b1;
            regwrite = 1'b1;
            aluop    = `OR_ALUOP;
            sign     = 1'b0;
        end

        `XORI_OP: begin
            alusrcb  = 1'b1;
            regwrite = 1'b1;
            aluop    = `XOR_ALUOP;
            sign     = 1'b0;
        end

        `LUI_OP: begin
            aluop   = `ADDU_ALUOP;
            alusrcb  = 1'b1;
            regwrite = 1'b1;
            sign_type= 1'b1;
        end

        // Load
        `LB_OP, `LBU_OP, `LH_OP, `LHU_OP, `LW_OP: begin
            alusrcb  = 1'b1;
            memread  = 1'b1;
            regwrite = 1'b1;
            writetype= 3'b001;
            aluop    = `ADD_ALUOP;
            mem_type = (opcode == `LB_OP)  ? `LB_TYPE :
                       (opcode == `LBU_OP) ? `LBU_TYPE :
                       (opcode == `LH_OP)  ? `LH_TYPE :
                       (opcode == `LHU_OP) ? `LHU_TYPE :
                                             `LW_TYPE;
        end

        // Store
        `SB_OP, `SH_OP, `SW_OP: begin
            alusrcb  = 1'b1;
            memwrite = 1'b1;
            aluop    = `ADD_ALUOP;
            mem_type = (opcode == `SB_OP) ? `SB_TYPE :
                       (opcode == `SH_OP) ? `SH_TYPE :
                                            `SW_TYPE;
        end

        // MFC0, MTC0
        `MFTC0_OP: begin
           case(cp0_rs)
               `MFC0_TYPE: begin
                   regwrite = 1'b1;
                   writetype= 3'b100; // CP0 → reg
               end
               `MTC0_TYPE: begin
                   cp0_write = 1'b1;
                   regdst  = 1'b1;
               end
               default: is_ri_excp = 1'b1; // 保留指令异常
           endcase  
        end


        default: is_ri_excp = 1'b1; // 保留指令异常
        endcase
    end

endmodule

