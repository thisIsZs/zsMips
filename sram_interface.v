module sram_interface(
    input        resetn,
    input        data_w,
    input        data_sram_r,
    input  [3:0] sel_bytes,
    input  [31:0] data_sram_rdata,
    input        sign,
    output       inst_sram_en,
    output [3:0] inst_sram_wen,
    output [31:0] inst_sram_wdata,
    output [3:0] data_sram_wen,
    output [31:0] mem_data_read,
    output       data_sram_en
);

    assign inst_sram_en = resetn;
    assign inst_sram_wen = 4'b0;
    assign inst_sram_wdata = 32'b0;
    assign data_sram_wen = data_w ? sel_bytes : 4'b0;

    wire [7:0]  byte_data;
    wire [15:0] half_data;

    assign byte_data =
        sel_bytes[0] ? data_sram_rdata[7:0]   :
        sel_bytes[1] ? data_sram_rdata[15:8]  :
        sel_bytes[2] ? data_sram_rdata[23:16] :
        sel_bytes[3] ? data_sram_rdata[31:24] :
        8'b0;

    assign half_data =
        (sel_bytes == 4'b0011) ? data_sram_rdata[15:0]  :
        (sel_bytes == 4'b1100) ? data_sram_rdata[31:16] :
        16'b0;

    assign mem_data_read =
        (sel_bytes == 4'b1111) ? data_sram_rdata :
        ((sel_bytes == 4'b0001) ||
         (sel_bytes == 4'b0010) ||
         (sel_bytes == 4'b0100) ||
         (sel_bytes == 4'b1000)) ?
            (sign ? {{24{byte_data[7]}}, byte_data} : {24'b0, byte_data}) :
        ((sel_bytes == 4'b0011) ||
         (sel_bytes == 4'b1100)) ?
            (sign ? {{16{half_data[15]}}, half_data} : {16'b0, half_data}) :
        32'b0;

    assign data_sram_en = data_w | data_sram_r;

endmodule