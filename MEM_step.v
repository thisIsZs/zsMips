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
    input [31:0] aluout, da2, mem_wb_da,
    input [4:0] mem_ctl,
    input forward,

    output reg is_load_excp,
    output reg is_store_excp,
    output [31:0] data_addr, 
    output reg sign,
    output reg [31:0] data_write,
    output data_wen, data_ren,
    output reg [3:0] sel_bytes
    );


    wire [31:0] store_data;
    assign data_addr = {aluout[31:2], 2'b00};
    assign data_wen = mem_ctl[1] && !is_store_excp;
    assign data_ren = mem_ctl[0] && !is_load_excp;
    assign store_data = forward ? mem_wb_da : da2;
            
    
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
                data_write = store_data;
            end
        end

        `SB_TYPE: begin
            data_write = {4{store_data[7:0]}};
            case (aluout[1:0])
                2'b00: sel_bytes = 4'b0001;
                2'b01: sel_bytes = 4'b0010;
                2'b10: sel_bytes = 4'b0100;
                2'b11: sel_bytes = 4'b1000;
            endcase
        end

        `SH_TYPE: begin
            data_write = {2{store_data[15:0]}};
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

