`timescale 1ns/1ps
// Four independent 3-bit M blocks in a cascaded base-8 counter.
// Secret value is compared ONLY by the external match logic; no M block
// has a secret input. Latched relay_open is not an insecure preset output.
module secret_code_four (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        activate,
    input  wire [11:0] secret_code,
    output wire [11:0] candidate,
    output wire [3:0]  match_bits,
    output reg         busy,
    output reg         relay_open
);
    wire [2:0] d1, d2, d3, d4;  // d1 = most significant digit
    wire       advance;
    wire       all_match;

    assign candidate = {d1, d2, d3, d4};

    // M_i themselves only generate digits, not read the secret.
    // Comparators reside in the external logic block.
    assign match_bits[3] = (d1 == secret_code[11:9]);
    assign match_bits[2] = (d2 == secret_code[8:6]);
    assign match_bits[1] = (d3 == secret_code[5:3]);
    assign match_bits[0] = (d4 == secret_code[2:0]);
    assign all_match = &match_bits;
    assign advance   = busy && !all_match && !activate;

    digit_counter M4 (.clk(clk), .rst_n(rst_n), .clear(activate),
                      .enable(advance), .digit(d4));
    digit_counter M3 (.clk(clk), .rst_n(rst_n), .clear(activate),
                      .enable(advance && (d4 == 3'd7)), .digit(d3));
    digit_counter M2 (.clk(clk), .rst_n(rst_n), .clear(activate),
                      .enable(advance && (d4 == 3'd7) && (d3 == 3'd7)),
                      .digit(d2));
    digit_counter M1 (.clk(clk), .rst_n(rst_n), .clear(activate),
                      .enable(advance && (d4 == 3'd7) && (d3 == 3'd7)
                              && (d2 == 3'd7)), .digit(d1));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy       <= 1'b0;
            relay_open <= 1'b0;
        end else if (activate) begin
            busy       <= 1'b1;
            relay_open <= 1'b0;
        end else if (busy && all_match) begin
            busy       <= 1'b0;
            relay_open <= 1'b1;
        end
    end
endmodule
