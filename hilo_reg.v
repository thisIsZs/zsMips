module hilo_reg(
    input  wire        clk,

    input  wire        hiwrite, lowrite,
    input  wire [31:0] hi_in,
    input  wire [31:0] lo_in,

    output wire [31:0] hi_out,
    output wire [31:0] lo_out
);

    reg [31:0] hi;
    reg [31:0] lo;

    initial begin
        hi <= 32'b0;
        lo <= 32'b0;
    end
    
    always @(posedge clk) begin
        if(hiwrite) 
            hi <= hi_in;
        if(lowrite)
            lo <= lo_in;
    end

    // 组合读（和 regfile rd1/rd2 一样）
    assign hi_out = hi;
    assign lo_out = lo;

endmodule
