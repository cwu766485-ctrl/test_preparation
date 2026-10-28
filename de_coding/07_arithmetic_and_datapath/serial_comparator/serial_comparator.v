// Unsigned bit-serial comparator. The most-significant bit is examined first;
// comparison completes as soon as a differing bit is found.
module serial_comparator #(
    parameter integer WIDTH = 8,
    parameter integer INDEX_WIDTH = (WIDTH <= 1) ? 1 : $clog2(WIDTH)
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire             start,
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output reg              greater,
    output reg              equal,
    output reg              less,
    output reg              busy,
    output reg              done
);
    reg [WIDTH-1:0] a_reg, b_reg;
    reg [INDEX_WIDTH-1:0] bit_index;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_reg <= 0; b_reg <= 0; bit_index <= WIDTH-1;
            greater <= 0; equal <= 0; less <= 0; busy <= 0; done <= 0;
        end else begin
            done <= 1'b0;
            if (!busy && start) begin
                a_reg <= a; b_reg <= b; bit_index <= WIDTH-1;
                greater <= 0; equal <= 0; less <= 0; busy <= 1'b1;
            end else if (busy) begin
                if (a_reg[bit_index] != b_reg[bit_index]) begin
                    greater <= a_reg[bit_index];
                    less <= b_reg[bit_index];
                    equal <= 1'b0;
                    busy <= 1'b0;
                    done <= 1'b1;
                end else if (bit_index == 0) begin
                    greater <= 1'b0; less <= 1'b0; equal <= 1'b1;
                    busy <= 1'b0;
                    done <= 1'b1;
                end else bit_index <= bit_index - 1'b1;
            end
        end
    end
endmodule
