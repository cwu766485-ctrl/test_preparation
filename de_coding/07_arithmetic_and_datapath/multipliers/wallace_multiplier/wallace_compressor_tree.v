// Recursively compress partial-product rows three at a time to two rows.
module wallace_compressor_tree #(
    parameter integer ROW_WIDTH = 16,
    parameter integer ROWS      = 1
) (
    input  wire [ROWS*ROW_WIDTH-1:0] rows,
    output wire [ROW_WIDTH-1:0]      row_0,
    output wire [ROW_WIDTH-1:0]      row_1
);
    generate
        if (ROWS <= 2) begin : BASE_CASE
            assign row_0 = rows[0 +: ROW_WIDTH];
            if (ROWS == 2) begin : TWO_ROWS
                assign row_1 = rows[ROW_WIDTH +: ROW_WIDTH];
            end
            else begin : ONE_ROW
                assign row_1 = {ROW_WIDTH{1'b0}};
            end
        end
        else begin : COMPRESS
            localparam integer GROUPS      = ROWS / 3;
            localparam integer REMAINDER   = ROWS % 3;
            localparam integer NEXT_ROWS   = 2*GROUPS + REMAINDER;
            wire [NEXT_ROWS*ROW_WIDTH-1:0] next_rows;
            genvar group_index;
            genvar remainder_index;

            for (group_index = 0; group_index < GROUPS; group_index = group_index + 1) begin : CSA
                wire [ROW_WIDTH-1:0] operand_0;
                wire [ROW_WIDTH-1:0] operand_1;
                wire [ROW_WIDTH-1:0] operand_2;

                assign operand_0 = rows[(3*group_index)*ROW_WIDTH +: ROW_WIDTH];
                assign operand_1 = rows[(3*group_index+1)*ROW_WIDTH +: ROW_WIDTH];
                assign operand_2 = rows[(3*group_index+2)*ROW_WIDTH +: ROW_WIDTH];
                assign next_rows[(2*group_index)*ROW_WIDTH +: ROW_WIDTH] =
                    operand_0 ^ operand_1 ^ operand_2;
                assign next_rows[(2*group_index+1)*ROW_WIDTH +: ROW_WIDTH] =
                    ((operand_0 & operand_1) | (operand_0 & operand_2) |
                     (operand_1 & operand_2)) << 1;
            end

            for (remainder_index = 0; remainder_index < REMAINDER; remainder_index = remainder_index + 1) begin : PASS_REMAINDER
                assign next_rows[(2*GROUPS+remainder_index)*ROW_WIDTH +: ROW_WIDTH] =
                    rows[(3*GROUPS+remainder_index)*ROW_WIDTH +: ROW_WIDTH];
            end

            wallace_compressor_tree #(
                .ROW_WIDTH (ROW_WIDTH),
                .ROWS      (NEXT_ROWS)
            ) u_next_stage (
                .rows  (next_rows),
                .row_0 (row_0),
                .row_1 (row_1)
            );
        end
    endgenerate
endmodule
