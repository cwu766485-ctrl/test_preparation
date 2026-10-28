

module sin_lut (
    input wire [7:0]       addr,
    output wire signed [7:0] sin_out
);

    reg signed [7:0] rom [0:255];
    integer i;
    real pi;

    initial begin
        pi = 3.141592653589793;

        for (i = 0; i < 256; i = i + 1) begin
            rom[i] = $rtoi($sin(2.0 * pi * i / 256.0) * 127.0);
        end
    end

    assign sin_out = rom[addr];

endmodule