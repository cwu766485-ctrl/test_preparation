// Fixed eight-bit unsigned serial adder with active-high synchronous reset.
module serial_adder_8_sync_reset (
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire [7:0] a,
    input  wire [7:0] b,
    output reg  [8:0] sum,
    output reg        busy,
    output reg        done
);
    reg [7:0] a_shift, b_shift;
    reg carry;
    reg [3:0] bit_index;
    wire sum_bit = a_shift[0] ^ b_shift[0] ^ carry;
    wire carry_next = (a_shift[0] & b_shift[0]) |
                      (a_shift[0] & carry) | (b_shift[0] & carry);

    always @(posedge clk) begin
        if (rst) begin
            a_shift<=0; b_shift<=0; carry<=0; bit_index<=0;
            sum<=0; busy<=0; done<=0;
        end else begin
            done<=1'b0;
            if (!busy && start) begin
                a_shift<=a; b_shift<=b; carry<=0; bit_index<=0; sum<=0; busy<=1'b1;
            end else if (busy) begin
                sum[bit_index]<=sum_bit;
                carry<=carry_next;
                a_shift<=a_shift>>1;
                b_shift<=b_shift>>1;
                if (bit_index==4'd7) begin
                    sum[8]<=carry_next; busy<=1'b0; done<=1'b1;
                end else bit_index<=bit_index+1'b1;
            end
        end
    end
endmodule
