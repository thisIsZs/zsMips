`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/22 11:34:03
// Design Name: 
// Module Name: regfile
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


module regfile(
	input wire clk,
	input wire we3,
	input wire[4:0] ra1,ra2,wa3,
	input wire[31:0] wd3,
	output wire[31:0] rd1,rd2
    );

	reg [31:0] rf[31:0];

	integer i;
	initial begin
		for (i = 0; i < 32; i = i + 1) begin
                rf[i] <= 32'b0;
            end
	end

	always @(posedge clk) begin
			if(we3) begin
			 	rf[wa3] <= wd3;
			end
	end

	assign rd1 = (ra1 != 5'b0) ? rf[ra1] : 32'b0;
	assign rd2 = (ra2 != 5'b0) ? rf[ra2] : 32'b0;
endmodule
