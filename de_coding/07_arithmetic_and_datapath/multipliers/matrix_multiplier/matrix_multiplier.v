// Iterative signed NxN matrix multiplier using one shared multiply-accumulate datapath.
// Advantage: hardware area is low because one product is computed per cycle.
// Disadvantage: a full result takes N^3 multiply-accumulate cycles.
// Matrices use row-major packed elements; element [0][0] occupies the least-significant slice.
// Pulse start for one cycle while idle; matrix_c is complete when done is asserted.
// ACC_WIDTH defaults to a conservative full-precision width and should not be reduced.
module matrix_multiplier #(
    parameter integer N         = 4,
    parameter integer WIDTH     = 8,
    parameter integer ACC_WIDTH = 2 * WIDTH + ((N <= 1) ? 0 : $clog2(N))
) (
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         start,
    input  wire [N*N*WIDTH-1:0]         matrix_a,
    input  wire [N*N*WIDTH-1:0]         matrix_b,
    output reg  [N*N*ACC_WIDTH-1:0]     matrix_c,
    output reg                          busy,
    output reg                          done
);
    localparam integer INDEX_WIDTH = (N <= 1) ? 1 : $clog2(N);

    reg [N*N*WIDTH-1:0] matrix_a_reg;
    reg [N*N*WIDTH-1:0] matrix_b_reg;
    reg [INDEX_WIDTH-1:0] row_idx;
    reg [INDEX_WIDTH-1:0] col_idx;
    reg [INDEX_WIDTH-1:0] inner_idx;

    localparam integer INDEX_EXT_WIDTH = (INDEX_WIDTH < 32) ? 32 : INDEX_WIDTH;
    wire [INDEX_EXT_WIDTH-1:0] row_idx_ext =
        {{(INDEX_EXT_WIDTH-INDEX_WIDTH){1'b0}}, row_idx};
    wire [INDEX_EXT_WIDTH-1:0] col_idx_ext =
        {{(INDEX_EXT_WIDTH-INDEX_WIDTH){1'b0}}, col_idx};
    wire [INDEX_EXT_WIDTH-1:0] inner_idx_ext =
        {{(INDEX_EXT_WIDTH-INDEX_WIDTH){1'b0}}, inner_idx};

    wire signed [WIDTH-1:0] operand_a =
        matrix_a_reg[((row_idx_ext * N + inner_idx_ext) * WIDTH) +: WIDTH];
    wire signed [WIDTH-1:0] operand_b =
        matrix_b_reg[((inner_idx_ext * N + col_idx_ext) * WIDTH) +: WIDTH];
    wire signed [2*WIDTH-1:0] operand_a_extended =
        {{WIDTH{operand_a[WIDTH-1]}}, operand_a};
    wire signed [2*WIDTH-1:0] operand_b_extended =
        {{WIDTH{operand_b[WIDTH-1]}}, operand_b};
    wire signed [2*WIDTH-1:0] product =
        operand_a_extended * operand_b_extended;
    wire signed [ACC_WIDTH-1:0] product_extended;
    generate
        if (ACC_WIDTH >= 2 * WIDTH) begin : EXTEND_PRODUCT
            assign product_extended =
                {{(ACC_WIDTH-2*WIDTH){product[2*WIDTH-1]}}, product};
        end
        else begin : TRUNCATE_PRODUCT
            assign product_extended = product[ACC_WIDTH-1:0];
        end
    endgenerate
    wire signed [ACC_WIDTH-1:0] current_accumulator =
        matrix_c[((row_idx_ext * N + col_idx_ext) * ACC_WIDTH) +: ACC_WIDTH];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            matrix_a_reg <= {N*N*WIDTH{1'b0}};
            matrix_b_reg <= {N*N*WIDTH{1'b0}};
            matrix_c     <= {N*N*ACC_WIDTH{1'b0}};
            row_idx      <= {INDEX_WIDTH{1'b0}};
            col_idx      <= {INDEX_WIDTH{1'b0}};
            inner_idx    <= {INDEX_WIDTH{1'b0}};
            busy         <= 1'b0;
            done         <= 1'b0;
        end
        else begin
            done <= 1'b0;

            if (start && !busy) begin
                matrix_a_reg <= matrix_a;
                matrix_b_reg <= matrix_b;
                matrix_c     <= {N*N*ACC_WIDTH{1'b0}};
                row_idx      <= {INDEX_WIDTH{1'b0}};
                col_idx      <= {INDEX_WIDTH{1'b0}};
                inner_idx    <= {INDEX_WIDTH{1'b0}};
                busy         <= 1'b1;
            end
            else if (busy) begin
                if (inner_idx == 0) begin
                    matrix_c[((row_idx_ext * N + col_idx_ext) * ACC_WIDTH) +: ACC_WIDTH]
                        <= product_extended;
                end
                else begin
                    matrix_c[((row_idx_ext * N + col_idx_ext) * ACC_WIDTH) +: ACC_WIDTH]
                        <= current_accumulator + product_extended;
                end

                if (inner_idx_ext == N - 1) begin
                    inner_idx <= {INDEX_WIDTH{1'b0}};
                    if (col_idx_ext == N - 1) begin
                        col_idx <= {INDEX_WIDTH{1'b0}};
                        if (row_idx_ext == N - 1) begin
                            row_idx <= {INDEX_WIDTH{1'b0}};
                            busy    <= 1'b0;
                            done    <= 1'b1;
                        end
                        else begin
                            row_idx <= row_idx + 1'b1;
                        end
                    end
                    else begin
                        col_idx <= col_idx + 1'b1;
                    end
                end
                else begin
                    inner_idx <= inner_idx + 1'b1;
                end
            end
        end
    end
endmodule
