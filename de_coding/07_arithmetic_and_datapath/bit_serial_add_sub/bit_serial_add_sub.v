// Bit-serial unsigned adder/subtractor. SUB=0 adds; SUB=1 computes A-B.
// In subtract mode CARRY_OUT=1 means no borrow; 0 means borrow occurred.
module bit_serial_add_sub #(
    parameter integer WIDTH = 8,
    parameter integer COUNT_WIDTH = (WIDTH <= 1) ? 1 : $clog2(WIDTH)
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire             start,
    input  wire             sub,
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output reg  [WIDTH-1:0] result,
    output reg              carry_out,
    output reg              busy,
    output reg              done
);
    reg [WIDTH-1:0] a_shift, b_shift;
    reg sub_reg, carry;
    reg [COUNT_WIDTH-1:0] bit_index;
    wire b_bit = b_shift[0] ^ sub_reg;
    wire sum_bit = a_shift[0] ^ b_bit ^ carry;
    wire carry_next = (a_shift[0] & b_bit) |
                      (a_shift[0] & carry) | (b_bit & carry);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_shift <= 0; b_shift <= 0; sub_reg <= 0; carry <= 0;
            bit_index <= 0; result <= 0; carry_out <= 0; busy <= 0; done <= 0;
        end else begin
            done <= 1'b0;
            if (!busy && start) begin
                a_shift <= a; b_shift <= b; sub_reg <= sub;
                carry <= sub; bit_index <= 0; result <= 0;
                carry_out <= 0; busy <= 1'b1;
            end else if (busy) begin
                result[bit_index] <= sum_bit;
                carry <= carry_next;
                a_shift <= a_shift >> 1;
                b_shift <= b_shift >> 1;
                if (bit_index == WIDTH-1) begin
                    carry_out <= carry_next;
                    busy <= 1'b0;
                    done <= 1'b1;
                end else bit_index <= bit_index + 1'b1;
            end
        end
    end
endmodule
