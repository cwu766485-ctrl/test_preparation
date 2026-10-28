// M5 datapath and top module. A and B are loaded in parallel and then shifted
// through a one-bit full adder for WIDTH cycles. SUM includes carry-out.
module modular_serial_adder #(
    parameter integer WIDTH = 16,
    parameter integer INDEX_WIDTH = (WIDTH <= 1) ? 1 : $clog2(WIDTH)
) (
    input wire clk, input wire rst_n, input wire start,
    input wire [WIDTH-1:0] a, input wire [WIDTH-1:0] b,
    output reg [WIDTH:0] sum, output wire busy, output wire done
);
    wire load, step, last;
    wire [INDEX_WIDTH-1:0] bit_index;
    reg [WIDTH-1:0] a_shift, b_shift;
    reg carry;
    wire sum_bit, carry_next;

    serial_adder_controller #(.WIDTH(WIDTH)) controller (
        .clk(clk), .rst_n(rst_n), .start(start), .load(load), .step(step),
        .last(last), .bit_index(bit_index), .busy(busy), .done(done)
    );
    full_adder u_full_adder (
        .a(a_shift[0]), .b(b_shift[0]), .cin(carry), .sum(sum_bit), .cout(carry_next)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin a_shift<=0; b_shift<=0; carry<=0; sum<=0; end
        else if (load) begin a_shift<=a; b_shift<=b; carry<=0; sum<=0; end
        else if (step) begin
            sum[bit_index] <= sum_bit;
            carry <= carry_next;
            a_shift <= a_shift >> 1;
            b_shift <= b_shift >> 1;
            if (last) sum[WIDTH] <= carry_next;
        end
    end
endmodule
