// Corrected four-bit shift register used by the code-debug exercise.
module code_debug_shift_reg (
    input wire clk,
    input wire rst_n,
    input wire serial_in,
    output reg [3:0] q
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 4'b0000;
        else
            q <= {q[2:0], serial_in};
    end
endmodule
