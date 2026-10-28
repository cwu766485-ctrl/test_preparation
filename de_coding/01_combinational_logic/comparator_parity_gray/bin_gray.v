module bin_gray #(
    parameter W = 8
)(
    input [W-1:0] bin,
    output [W-1:0] gray,
    input [W-1:0] gray_in,
    output [W-1:0] bin_out
);

    assign gray = bin^(bin >> 1);

    genvar i;
    generate
        for (i = 0; i < W; i = i + 1) begin : gray2bin
            if (i == W-1) begin
                assign bin_out[i] = gray_in[i];
            end else begin
                assign bin_out[i] = gray_in[i] ^ bin_out[i+1];
            end
        end
    endgenerate

endmodule