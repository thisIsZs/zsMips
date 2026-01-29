`include "ZSMips.vh"
//////////////////////////////////////////////////////////////////////////////////

module exception_unit(
    input  is_pc_excp, is_load_excp,
    input  is_store_excp, is_overflow,
    input  is_ri_excp, is_eret_excp,
    input  is_syscall, is_break,
    input  [31:0] status,
    input  [31:0] cause,
    input  [5:0]  ext_int,      // 外部中断

    output        isexc,
    output [4:0]  exctype       // 异常类型编码
);

    reg interrupt;
    reg [4:0] exctype_r;

    // 地址错误判断
    always @(*) begin

        // 中断判断
        if(status[0] && ~status[1] && ((|(status[9:8] & cause[9:8])) || (|(status[15:10] & ext_int))))
            interrupt = 1'b1;
        else
            interrupt = 1'b0;

        // 异常类型判断（优先级）
        if(interrupt)
            exctype_r = `EXC_CODE_INT;
        else if(is_load_excp || is_pc_excp)
            exctype_r = `EXC_CODE_ADEL;
        else if(is_store_excp)
            exctype_r = `EXC_CODE_ADES;
        else if(is_syscall)
            exctype_r = `EXC_CODE_SYS;
        else if(is_break)
            exctype_r = `EXC_CODE_BP;
        else if(is_overflow)
            exctype_r = `EXC_CODE_OV;
        else if(is_eret_excp)
            exctype_r = `EXC_CODE_ERET;
        else if(is_ri_excp)
            exctype_r = `EXC_CODE_RI;
        else
            exctype_r = `EXC_CODE_NONE;
    end

    assign exctype  = exctype_r;
    assign isexc    = (exctype_r == `EXC_CODE_NONE || exctype_r == `EXC_CODE_ERET) ? 1'b0 : 1'b1;

endmodule
