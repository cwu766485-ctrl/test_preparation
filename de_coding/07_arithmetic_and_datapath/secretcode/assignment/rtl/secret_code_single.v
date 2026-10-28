// Single-counter alternative to the four-M-block implementation.
// It scans the same 12-bit space in the same order for an apples-to-apples
// synthesis and timing comparison.
module secret_code_single (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        activate,
    input  wire [11:0] secret_code,
    output reg  [11:0] candidate,
    output reg         busy,
    output reg         relay_open
);
    reg [11:0] target_reg;
    wire advance = busy && (candidate != target_reg);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            candidate  <= 12'b0;
            target_reg <= 12'b0;
            busy       <= 1'b0;
            relay_open <= 1'b0;
        end else if (activate) begin
            candidate  <= 12'b0;
            target_reg <= secret_code;
            busy       <= 1'b1;
            relay_open <= 1'b0;
        end else if (busy) begin
            if (candidate == target_reg) begin
                busy       <= 1'b0;
                relay_open <= 1'b1;
            end else if (advance) begin
                candidate <= candidate + 12'b1;
            end
        end
    end
endmodule
