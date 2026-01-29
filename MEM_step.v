`timescale 1ns / 1ps
`include "ZsMips.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/30 14:13:46
// Design Name: 
// Module Name: MEM_step
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


module MEM_step(
    input clk, rst,
    input [31:0] aluout, da2, pc_add8,
    input [4:0] mem_ctl,
    input  is_pc_excp, 
    input  is_overflow,
    input  is_ri_excp, is_eret_excp,
    input  is_syscall, is_break,
    input  [31:0] status,
    input  [31:0] cause,
    input  [5:0]  ext_int,      // 外部中断
    input  cp0_write, indelayslot,
    input  [4:0] rd,
    input  [4:0] wa,
    input  [6:0] wb_in,
    
    output isexc,
    output [6:0] wb_out,
    output [31:0] cp0_readdata, cp0_epc, cp0_status, cp0_cause,
    output [31:0] data_addr, 
    output reg sign,
    output reg [31:0] data_write,
    output data_wen, data_ren,
    output reg [3:0] sel_bytes
    );

    wire [31:0] excp_badvaddr;
    wire excp_is_exc;
    wire [4:0] excp_exctype;
    reg is_load_excp, is_store_excp;
 
    assign data_addr = {aluout[31:2], 2'b00};
    assign data_wen = mem_ctl[1] && !is_store_excp;
    assign data_ren = mem_ctl[0] && !is_load_excp;

    //异常处理单元
    exception_unit exception_unit ( .is_pc_excp(is_pc_excp), .is_load_excp(is_load_excp), .is_store_excp(is_store_excp),
                                    .is_overflow(is_overflow), .is_ri_excp(is_ri_excp), .status(status), .cause(cause),
                                    .ext_int(ext_int), .is_eret_excp(is_eret_excp), .is_syscall(is_syscall), .is_break(is_break),
                                    .isexc(excp_is_exc), .exctype(excp_exctype));
    assign isexc = excp_is_exc;
    // BadVddr 计算
    assign excp_badvaddr = is_pc_excp ? pc_add8-4'h8: 
                            (is_load_excp | is_store_excp) ? aluout : 31'b0;
    
    //cp0寄存器
    cp0_reg my_cp0_reg (.clk(!clk), .rst(rst), .en(excp_is_exc), .enw(cp0_write), .indelayslot(indelayslot), .pc(pc_add8-8),
                .badvaddr(excp_badvaddr), .exctype(excp_exctype), .raddr(rd), .waddr(wa), .writedata(da2),
                .readdata(cp0_readdata), .epc(cp0_epc), .status(cp0_status), .cause(cp0_cause));

    //异常不写回
    assign wb_out= {wb_in[6:1], wb_in[0] && !excp_is_exc}; 


    //访存处理
    always @(*) begin
        // 默认值
        is_load_excp  = 1'b0;
        is_store_excp = 1'b0;
        data_write = da2;
        sel_bytes  = 4'b0000;
        sign       = 1'b0;   

        case (mem_ctl[4:2])

        `LW_TYPE: begin
            if(aluout[1:0] != 2'b00) 
                is_load_excp = 1'b1;
            else begin
                sel_bytes = 4'b1111;
                sign      = 1'b1;
            end
        end

        `LB_TYPE: begin
            sign = 1'b1;
            case (aluout[1:0])
                2'b00: sel_bytes = 4'b0001;
                2'b01: sel_bytes = 4'b0010;
                2'b10: sel_bytes = 4'b0100;
                2'b11: sel_bytes = 4'b1000;
            endcase
        end

        `LBU_TYPE: begin
            sign = 1'b0;
            case (aluout[1:0])
                2'b00: sel_bytes = 4'b0001;
                2'b01: sel_bytes = 4'b0010;
                2'b10: sel_bytes = 4'b0100;
                2'b11: sel_bytes = 4'b1000;
            endcase
        end

        `LH_TYPE: begin
            sign = 1'b1;
            case (aluout[1:0])
                2'b00: sel_bytes = 4'b0011;
                2'b10: sel_bytes = 4'b1100;
                default:  begin
                    is_load_excp = 1'b1;
                end
            endcase
        end

        `LHU_TYPE: begin
            sign = 1'b0;
            case (aluout[1:0])
                2'b00: sel_bytes = 4'b0011;
                2'b10: sel_bytes = 4'b1100;
                default:  begin
                    is_load_excp = 1'b1;
                end
            endcase
        end

        `SW_TYPE: begin
            if(aluout[1:0] != 2'b00) 
                is_store_excp = 1'b1;
            else begin 
                sel_bytes  = 4'b1111;
                data_write = da2;
            end
        end

        `SB_TYPE: begin
            data_write = {4{da2[7:0]}};
            case (aluout[1:0])
                2'b00: sel_bytes = 4'b0001;
                2'b01: sel_bytes = 4'b0010;
                2'b10: sel_bytes = 4'b0100;
                2'b11: sel_bytes = 4'b1000;
            endcase
        end

        `SH_TYPE: begin
            data_write = {2{da2[15:0]}};
            case (aluout[1:0])
                2'b00: sel_bytes = 4'b0011;
                2'b10: sel_bytes = 4'b1100;
                default:  begin
                    is_store_excp = 1'b1;
                end
            endcase
        end

        endcase
    end
    

endmodule

