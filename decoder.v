`timescale 1ns / 1ps
`include "ZsMips.vh"
/*
// 控制信号
1'b  alusrca: 0选reg； 1选inst
1'b  alusrcb: 0选reg； 1选立即数
1'b  regwrite: 1写reg
1'b  regdst:  0选rt; 1选rd
1'b  memwrite：1写mem 
1'b  memread: 1读mem
3'b  memtype: load store mode(具体见.vh)
3'b  writetype: 3'b000reg写入alu数据;
                3'b001reg写入mem读取数据;
                3'b010reg写入lo;
                3'b011reg写入hi;
                3'b100reg写入cp0
1'b  hiwrite: 1写hi
1'b  lowrite: 1写lo
1'b  cp0_write: 1写cp0
1'b  sign_type: 0立即数低位扩展（lui）； 1立即数高位扩展
1'b  sign: 0零扩展; 1符号扩展

// 跳转与分支信号
1'b  jump: 1跳转
1'b  branch: 1分支
1'b  link: 1写返回地址
1'b  link_31reg: 1写返回地址到31寄存器
1'b  jump_ad_src: 0跳转地址来自寄存器, 1跳转地址来自指令；

*/

module mips_decoder(
    input  [31:26] opcode,
    input  [5:0]   func,
    input  [20:16] rt,
    input  [25:21] rs,
    input  [31:0]  reg1_data,   // 用于分支判断
    input  [31:0]  reg2_data,   // 用于分支判断

    // 控制信号
    output reg        alusrca, alusrcb,
    output reg        regwrite, regdst,
    output reg        memwrite, memread,
    output reg [3:0]  aluop,
    output reg [2:0]  mem_type,
    output reg [2:0]  writetype,
    output reg        hiwrite, lowrite,
    output reg        cp0_write,
    output reg        sign, sign_type,
    
    // 跳转与分支信号
    output reg        jump, branch,
    output reg        link, link_31reg,
    output reg        jump_ad_src,
    output reg        delay_slot,
    
    // 异常信号
    output            is_syscall, is_break,
    output reg        is_ri_excp
);

    // 静态逻辑判断
    assign is_syscall = (opcode == `R_OP) && (func == `SYSCALL_FUNC);
    assign is_break   = (opcode == `R_OP) && (func == `BREAK_FUNC);

    always @(*) begin
        // --- 默认缺省值 ---
        {alusrca, alusrcb, regwrite, regdst, memwrite, memread} = 6'b0;
        {hiwrite, lowrite, cp0_write, jump, branch, link, link_31reg} = 8'b0;
        {jump_ad_src, delay_slot} = 2'b0;
        {sign_type, sign} = 2'b1; // 默认符号扩展   
        aluop = 4'b1111;
        mem_type = 3'b000;
        writetype = 3'b000;
        is_ri_excp = 1'b0;

        case (opcode)
            `R_OP: begin
                regdst   = 1'b1;
                regwrite = (func == `JR_FUNC || func == `MTHI_FUNC || func == `MTLO_FUNC || 
                            func == `MULT_FUNC || func == `DIV_FUNC || func == `MULTU_FUNC ||
                            func == `DIVU_FUNC) ? 1'b0 : 1'b1;
                aluop    = `R_ALUOP;
                alusrca  = (func == `SLL_FUNC || func == `SRL_FUNC || func == `SRA_FUNC);
                
                case (func)
                    `MULT_FUNC, `MULTU_FUNC, `DIV_FUNC, `DIVU_FUNC: {hiwrite, lowrite} = 2'b11;
                    `MFHI_FUNC: writetype = 3'b011;
                    `MFLO_FUNC: writetype = 3'b010;
                    `MTHI_FUNC: hiwrite = 1'b1;
                    `MTLO_FUNC: lowrite = 1'b1;
                    `JR_FUNC:   begin jump = 1'b1; delay_slot = 1'b1; jump_ad_src = 1'b0; end
                    `JALR_FUNC: begin jump = 1'b1; delay_slot = 1'b1; jump_ad_src = 1'b0; link = 1'b1; end
                    default:    if (func > 6'h3F) is_ri_excp = 1'b1; // 简化的异常判断
                endcase
            end

            // I-Type 算术逻辑
            `ADDI_OP, `ADDIU_OP, `SLTI_OP, `SLTIU_OP, `ANDI_OP, `ORI_OP, `XORI_OP, `LUI_OP: begin
                regwrite = 1'b1; alusrcb = 1'b1;
                case(opcode)
                    `ADDI_OP:  aluop = `ADD_ALUOP;
                    `ADDIU_OP: aluop = `ADDU_ALUOP;
                    `SLTI_OP:  aluop = `SLTI_ALUOP;
                    `SLTIU_OP: aluop = `SLTIU_ALUOP;
                    `ANDI_OP: begin aluop = `AND_ALUOP; sign = 1'b0; end
                    `ORI_OP:  begin  aluop = `OR_ALUOP; sign = 1'b0; end
                    `XORI_OP: begin  aluop = `XOR_ALUOP; sign = 1'b0; end
                    `LUI_OP:  begin aluop = `ADDU_ALUOP; sign_type = 1'b1; end
                endcase
            end

            // 访存指令
            `LW_OP, `LB_OP, `LBU_OP, `LH_OP, `LHU_OP: begin
                regwrite = 1'b1; alusrcb = 1'b1; memread = 1'b1; writetype = 3'b001;
                aluop = `ADD_ALUOP;
                case(opcode)
                    `LB_OP:  mem_type = `LB_TYPE;
                    `LBU_OP: mem_type = `LBU_TYPE;
                    `LH_OP:  mem_type = `LH_TYPE;
                    `LHU_OP: mem_type = `LHU_TYPE;
                    default: mem_type = `LW_TYPE;
                endcase
            end
            `SW_OP, `SB_OP, `SH_OP: begin
                alusrcb = 1'b1; memwrite = 1'b1; aluop = `ADD_ALUOP;
                case(opcode)
                    `SB_OP:  mem_type = `SB_TYPE;
                    `SH_OP:  mem_type = `SH_TYPE;
                    default: mem_type = `SW_TYPE;
                endcase
            end

            // 分支指令
            `BEQ_OP:  begin branch = (reg1_data == reg2_data); delay_slot = 1'b1; end
            `BNE_OP:  begin branch = (reg1_data != reg2_data); delay_slot = 1'b1; end
            `BGTZ_OP: begin branch = (reg1_data[31] == 1'b0) && (reg1_data != 32'b0); delay_slot = 1'b1; end
            `BLEZ_OP: begin branch = (reg1_data[31] == 1'b1) || (reg1_data == 32'b0); delay_slot = 1'b1; end
            `BZ_OP:  begin
                delay_slot = 1'b1;
                case (rt)
                    `BLTZ_TYPE: branch = reg1_data[31];
                    `BGEZ_TYPE: branch = !reg1_data[31];
                    `BLTZAL_TYPE: begin
                        branch     = reg1_data[31];
                        link_31reg = 1'b1;
                        link = 1'b1;
                        regwrite = 1'b1;
                    end
                    `BGEZAL_TYPE: begin
                        branch     = !reg1_data[31];
                        link_31reg = 1'b1;
                        link = 1'b1;
                        regwrite = 1'b1;
                    end
                    default: is_ri_excp = 1'b1;
                endcase
            end
            
            // J-Type
            `J_OP:    begin jump = 1'b1; jump_ad_src = 1'b1; delay_slot = 1'b1; end
            `JAL_OP:  begin jump = 1'b1; jump_ad_src = 1'b1; delay_slot = 1'b1;
                            link = 1'b1; link_31reg = 1'b1; regwrite = 1'b1; 
                            regwrite = 1'b1; end

            // MFC0, MTC0
            `MFTC0_OP: begin
            case(rs)
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

            default: is_ri_excp = 1'b1;
        endcase
    end
endmodule