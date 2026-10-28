// Recursively pair rows into a balanced, combinational multiplier adder tree.
module multiplier_adder_tree #(
    parameter integer ROW_WIDTH = 16,
    parameter integer ROWS      = 1
) (
    input  wire [ROWS*ROW_WIDTH-1:0] rows,
    output wire [ROW_WIDTH-1:0]      sum
);
    generate
        if (ROWS <= 1) begin : BASE_CASE
            assign sum = rows[0 +: ROW_WIDTH];
        end
        else begin : REDUCE
            localparam integer PAIRS     = ROWS / 2;
            localparam integer NEXT_ROWS = (ROWS + 1) / 2;
            wire [NEXT_ROWS*ROW_WIDTH-1:0] next_rows;
            genvar pair_index;

            for (pair_index = 0; pair_index < PAIRS; pair_index = pair_index + 1) begin : ADD_PAIR
                assign next_rows[pair_index*ROW_WIDTH +: ROW_WIDTH] =
                    rows[(2*pair_index)*ROW_WIDTH +: ROW_WIDTH] +
                    rows[(2*pair_index+1)*ROW_WIDTH +: ROW_WIDTH];
            end

            if ((ROWS % 2) != 0) begin : PASS_LAST
                assign next_rows[(NEXT_ROWS-1)*ROW_WIDTH +: ROW_WIDTH] =
                    rows[(ROWS-1)*ROW_WIDTH +: ROW_WIDTH];
            end

            multiplier_adder_tree #(
                .ROW_WIDTH (ROW_WIDTH),
                .ROWS      (NEXT_ROWS)
            ) u_next_level (
                .rows (next_rows),
                .sum  (sum)
            );
        end
    endgenerate
endmodule
