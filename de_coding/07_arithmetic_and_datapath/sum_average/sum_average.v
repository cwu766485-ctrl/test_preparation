// Sum COUNT unsigned streaming samples and report their integer average.
// START arms the block; samples are accepted on later cycles when VALID=1.
module sum_average #(
    parameter integer WIDTH = 8,
    parameter integer COUNT = 4,
    parameter integer SUM_WIDTH = WIDTH + ((COUNT <= 1) ? 0 : $clog2(COUNT)),
    parameter integer COUNT_WIDTH = (COUNT <= 1) ? 1 : $clog2(COUNT)
) (
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire                    start,
    input  wire                    valid,
    input  wire [WIDTH-1:0]        data_in,
    output reg  [SUM_WIDTH-1:0]    sum,
    output reg  [WIDTH-1:0]        average,
    output reg                     busy,
    output reg                     done
);
    reg [SUM_WIDTH-1:0] accum;
    reg [COUNT_WIDTH-1:0] sample_count;
    wire [SUM_WIDTH-1:0] sum_next = accum + data_in;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            accum <= 0; sample_count <= 0; sum <= 0; average <= 0; busy <= 0; done <= 0;
        end else begin
            done <= 1'b0;
            if (!busy && start) begin
                accum <= 0; sample_count <= 0; busy <= 1'b1;
            end else if (busy && valid) begin
                if (sample_count == COUNT-1) begin
                    sum <= sum_next;
                    average <= sum_next / COUNT;
                    accum <= 0; sample_count <= 0; busy <= 1'b0; done <= 1'b1;
                end else begin
                    accum <= sum_next;
                    sample_count <= sample_count + 1'b1;
                end
            end
        end
    end
endmodule
