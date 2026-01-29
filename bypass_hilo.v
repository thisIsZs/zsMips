module bypass_hilo(
    input [2:0] writetype,
    input hiwrite, lowrite,
    output  forwardhi, forwardlo
    );

    assign forwardlo = (writetype == 3'b010 && lowrite) ? 1'b1 : 1'b0;
    assign forwardhi = (writetype == 3'b011 && hiwrite) ? 1'b1 : 1'b0;

endmodule