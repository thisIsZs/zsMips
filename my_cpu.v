module mycpu_top(
    input clk,
    input resetn,  //low active
    input [5:0] ext_int,  //interrupt,high active

    //cpu inst sram
    output        inst_sram_en   ,
    output [3 :0] inst_sram_wen  ,
    output [31:0] inst_sram_addr ,
    output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata,

    //cpu data sram
    output        data_sram_en   ,
    output [3 :0] data_sram_wen  ,
    output [31:0] data_sram_addr ,
    output [31:0] data_sram_wdata,
    input  [31:0] data_sram_rdata,

    //debug
    output [31:0] debug_wb_pc,
    output [3 :0] debug_wb_rf_wen,
    output [4 :0] debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata
);

    wire data_w, data_sram_r;
    wire [47:0] ascii;
    wire [3:0] sel_bytes;
    wire [31:0] mem_data_read;
    wire sign;
    wire [31:0] debug_inst_out;
    wire [31:0] data_sram_vaddr;
    wire data_kseg0, data_kseg1;

    // address mapping with KSEG0/KSEG1 mapping
    assign data_kseg0 = data_sram_vaddr[31:29] == 3'b100; // 0x80000000 ~ 0x9FFFFFFF
    assign data_kseg1 = data_sram_vaddr[31:29] == 3'b101; // 0xA0000000 ~ 0xBFFFFFFF
    assign data_sram_addr = (data_kseg0 || data_kseg1) ? {3'b0, data_sram_vaddr[28:0]} 
                                                        : data_sram_vaddr;

    mips_core mips_core(
        .clk(clk),
        .rst(~resetn), 
        .ext_int(ext_int),

        //inst sram
        .inst(inst_sram_rdata),
        .inst_add(inst_sram_addr), 

        //data sram
        .sign(sign),
        .data_read(mem_data_read),
        .data_addr(data_sram_vaddr),
        .data_write(data_sram_wdata),
        .data_wen(data_w),
        .sel_bytes (sel_bytes),
        .data_ren (data_sram_r),

        //debug
        .debug_wb_pc      (debug_wb_pc      ),
        .debug_wb_rf_wen  (debug_wb_rf_wen  ),
        .debug_wb_rf_wnum (debug_wb_rf_wnum ),
        .debug_wb_rf_wdata(debug_wb_rf_wdata),
        .debug_inst_out   (debug_inst_out   )
    );



    sram_interface zs_sram_interface(
        .resetn(resetn),
        .data_w(data_w),
        .data_sram_r(data_sram_r),
        .sel_bytes(sel_bytes),
        .data_sram_rdata(data_sram_rdata),
        .sign(sign),
        .inst_sram_en(inst_sram_en),     
        .inst_sram_wen(inst_sram_wen),
        .inst_sram_wdata(inst_sram_wdata),
        .data_sram_wen(data_sram_wen),
        .mem_data_read(mem_data_read),
        .data_sram_en(data_sram_en)
    );

    instdec instdec(
        .instr(debug_inst_out ),
        .ascii(ascii)
    );


endmodule