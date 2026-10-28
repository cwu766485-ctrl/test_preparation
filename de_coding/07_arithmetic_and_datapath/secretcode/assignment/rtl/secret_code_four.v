// Four independent modulo-8 M blocks enumerate all 8^4 candidate codes.
// The fastest digit is v4; carry propagates v4 -> v3 -> v2 -> v1.
// Secret-code comparison is kept in this logic block, outside every M block.
module secret_code_four (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        activate,
    input  wire [11:0] secret_code,
    output wire [11:0] candidate,
    output reg         busy,
    output reg         relay_open
);
    reg [11:0] target_reg;
    wire [2:0] v1, v2, v3, v4;
    wire carry4, carry3, carry2;
    // Each Mi reports only its generated digit. The comparison logic stays
    // outside the generators, as required by the assignment architecture.
    wire [3:0] digit_match;
    wire all_match = &digit_match;
    wire advance = busy && !all_match;

    assign candidate = {v1, v2, v3, v4};
    assign digit_match[3] = (v1 == target_reg[11:9]);
    assign digit_match[2] = (v2 == target_reg[8:6]);
    assign digit_match[1] = (v3 == target_reg[5:3]);
    assign digit_match[0] = (v4 == target_reg[2:0]);

    secret_code_m m4 (
        .clk(clk), .rst_n(rst_n), .clear(activate), .enable(advance),
        .value(v4), .carry_out(carry4)
    );
    secret_code_m m3 (
        .clk(clk), .rst_n(rst_n), .clear(activate), .enable(carry4),
        .value(v3), .carry_out(carry3)
    );
    secret_code_m m2 (
        .clk(clk), .rst_n(rst_n), .clear(activate), .enable(carry3),
        .value(v2), .carry_out(carry2)
    );
    secret_code_m m1 (
        .clk(clk), .rst_n(rst_n), .clear(activate), .enable(carry2),
        .value(v1), .carry_out()
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            target_reg <= 12'b0;
            busy       <= 1'b0;
            relay_open <= 1'b0;
        end else if (activate) begin
            target_reg <= secret_code;
            busy       <= 1'b1;
            relay_open <= 1'b0;
        end else if (busy && all_match) begin
            busy       <= 1'b0;
            relay_open <= 1'b1;
        end
    end
endmodule
