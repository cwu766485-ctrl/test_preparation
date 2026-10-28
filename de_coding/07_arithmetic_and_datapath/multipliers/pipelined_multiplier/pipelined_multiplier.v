// Two-stage unsigned multiplier: register partial products, then a balanced adder-tree result.
// Advantage: accepts one input per cycle and shortens the final addition path.
// Disadvantage: uses WIDTH partial-product registers and adds a cycle of latency.
module pipelined_multiplier #(
    parameter integer WIDTH = 8
) (
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 valid_i,
    input  wire [WIDTH-1:0]     a,
    input  wire [WIDTH-1:0]     b,
    output reg                  valid_o,
    output reg  [2*WIDTH-1:0]   product
);
    localparam integer ROW_WIDTH   = 2 * WIDTH;
    localparam integer PAD_WIDTH   = (WIDTH <= 1) ? 1 : (1 << $clog2(WIDTH));

    reg [ROW_WIDTH-1:0] partial_product_stage1 [0:PAD_WIDTH-1];
    reg                 valid_stage1;
    wire [PAD_WIDTH*ROW_WIDTH-1:0] partial_products;
    wire [ROW_WIDTH-1:0] product_sum;

    genvar partial_index;
    generate
        for (partial_index = 0; partial_index < PAD_WIDTH; partial_index = partial_index + 1) begin : PARTIAL_PRODUCT_STAGE
            if (partial_index < WIDTH) begin : ACTIVE
                always @(posedge clk or negedge rst_n) begin
                    if (!rst_n) begin
                        partial_product_stage1[partial_index] <= {ROW_WIDTH{1'b0}};
                    end
                    else if (valid_i) begin
                        partial_product_stage1[partial_index] <=
                            {{WIDTH{1'b0}}, (a & {WIDTH{b[partial_index]}})} << partial_index;
                    end
                end
            end
            else begin : PADDED
                always @(posedge clk or negedge rst_n) begin
                    if (!rst_n) begin
                        partial_product_stage1[partial_index] <= {ROW_WIDTH{1'b0}};
                    end
                    else if (valid_i) begin
                        partial_product_stage1[partial_index] <= {ROW_WIDTH{1'b0}};
                    end
                end
            end

            assign partial_products[partial_index*ROW_WIDTH +: ROW_WIDTH] =
                partial_product_stage1[partial_index];
        end
    endgenerate

    multiplier_adder_tree #(
        .ROW_WIDTH (ROW_WIDTH),
        .ROWS      (PAD_WIDTH)
    ) u_multiplier_adder_tree (
        .rows (partial_products),
        .sum  (product_sum)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_stage1 <= 1'b0;
            valid_o      <= 1'b0;
            product      <= {ROW_WIDTH{1'b0}};
        end
        else begin
            valid_stage1 <= valid_i;
            valid_o      <= valid_stage1;
            if (valid_stage1) begin
                product <= product_sum;
            end
        end
    end
endmodule
