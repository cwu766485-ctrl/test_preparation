// Iterative unsigned shift-and-add multiplier.
// Advantage: small hardware; one add/shift step per cycle.
// Disadvantage: latency is WIDTH cycles and throughput is low.
module shift_add_multiplier #(
    parameter integer WIDTH = 8
) (
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 start,
    input  wire [WIDTH-1:0]     multiplicand,
    input  wire [WIDTH-1:0]     multiplier,
    output reg  [2*WIDTH-1:0]   product,
    output reg                  busy,
    output reg                  done
);
    localparam integer COUNT_WIDTH = (WIDTH <= 1) ? 1 : $clog2(WIDTH);
    localparam [COUNT_WIDTH-1:0] LAST_COUNT = WIDTH[COUNT_WIDTH-1:0] - 1'b1;

    reg [2*WIDTH-1:0] multiplicand_reg;
    reg [WIDTH-1:0]   multiplier_reg;
    reg [COUNT_WIDTH-1:0] count;
    reg [2*WIDTH-1:0] accumulator;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            multiplicand_reg <= 0;
            multiplier_reg   <= 0;
            count            <= 0;
            accumulator      <= 0;
            product          <= 0;
            busy             <= 1'b0;
            done             <= 1'b0;
        end
        else begin
            done <= 1'b0;

            if (start && !busy) begin
                multiplicand_reg <= {{WIDTH{1'b0}}, multiplicand};
                multiplier_reg   <= multiplier;
                count            <= 0;
                accumulator      <= 0;
                busy             <= 1'b1;
            end
            else if (busy) begin
                if (multiplier_reg[0]) begin
                    accumulator <= accumulator + multiplicand_reg;
                end

                multiplicand_reg <= multiplicand_reg << 1;
                multiplier_reg   <= multiplier_reg >> 1;

                if (count == LAST_COUNT) begin
                    product <= accumulator +
                               (multiplier_reg[0] ? multiplicand_reg : 0);
                    busy    <= 1'b0;
                    done    <= 1'b1;
                end
                else begin
                    count <= count + 1'b1;
                end
            end
        end
    end
endmodule
