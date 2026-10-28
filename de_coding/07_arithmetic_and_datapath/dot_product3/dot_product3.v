// Signed three-term dot product. START samples term zero; the next two
// clock edges sample terms one and two. DONE is a one-cycle pulse.
module dot_product3 #(
    parameter integer WIDTH = 8,
    parameter integer ACC_WIDTH = 2 * WIDTH + 2
) (
    input  wire                        clk,
    input  wire                        rst_n,
    input  wire                        start,
    input  wire signed [WIDTH-1:0]     a,
    input  wire signed [WIDTH-1:0]     b,
    output reg  signed [ACC_WIDTH-1:0] result,
    output reg                         busy,
    output reg                         done
);
    reg signed [ACC_WIDTH-1:0] accum;
    reg [1:0] term_count;
    wire signed [2*WIDTH-1:0] product = $signed(a) * $signed(b);
    wire signed [ACC_WIDTH-1:0] product_ext = product;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            accum <= 0; result <= 0; term_count <= 0; busy <= 1'b0; done <= 1'b0;
        end else begin
            done <= 1'b0;
            if (!busy && start) begin
                accum <= product_ext;
                term_count <= 2'd1;
                busy <= 1'b1;
            end else if (busy) begin
                if (term_count == 2'd2) begin
                    result <= accum + product_ext;
                    accum <= 0;
                    term_count <= 0;
                    busy <= 1'b0;
                    done <= 1'b1;
                end else begin
                    accum <= accum + product_ext;
                    term_count <= term_count + 1'b1;
                end
            end
        end
    end
endmodule
