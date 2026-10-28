// Variable-width unsigned serial subtractor computing A-B, least-significant
// bit first. BORROW_OUT is the final borrow flag.
module serial_subtractor #(
    parameter integer WIDTH = 8,
    parameter integer COUNT_WIDTH = (WIDTH <= 1) ? 1 : $clog2(WIDTH)
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire             start,
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output reg  [WIDTH-1:0] difference,
    output reg              borrow_out,
    output reg              busy,
    output reg              done
);
    reg [WIDTH-1:0] a_shift, b_shift;
    reg borrow;
    reg [COUNT_WIDTH-1:0] bit_index;
    wire diff_bit = a_shift[0] ^ b_shift[0] ^ borrow;
    wire borrow_next = (~a_shift[0] & (b_shift[0] | borrow)) |
                       (b_shift[0] & borrow);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_shift<=0; b_shift<=0; borrow<=0; bit_index<=0;
            difference<=0; borrow_out<=0; busy<=0; done<=0;
        end else begin
            done <= 1'b0;
            if (!busy && start) begin
                a_shift<=a; b_shift<=b; borrow<=0; bit_index<=0;
                difference<=0; borrow_out<=0; busy<=1'b1;
            end else if (busy) begin
                difference[bit_index] <= diff_bit;
                borrow <= borrow_next;
                a_shift <= a_shift >> 1;
                b_shift <= b_shift >> 1;
                if (bit_index == WIDTH-1) begin
                    borrow_out <= borrow_next; busy<=1'b0; done<=1'b1;
                end else bit_index <= bit_index + 1'b1;
            end
        end
    end
endmodule
