// Find unsigned minimum/maximum values and their first positions in a stream.
module max_min_index #(
    parameter integer WIDTH = 8,
    parameter integer COUNT = 5,
    parameter integer INDEX_WIDTH = (COUNT <= 1) ? 1 : $clog2(COUNT)
) (
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire                  valid,
    input  wire [WIDTH-1:0]      data_in,
    output reg  [WIDTH-1:0]      min_value,
    output reg  [WIDTH-1:0]      max_value,
    output reg  [INDEX_WIDTH-1:0] min_index,
    output reg  [INDEX_WIDTH-1:0] max_index,
    output reg                   busy,
    output reg                   done
);
    reg [WIDTH-1:0] min_reg, max_reg;
    reg [INDEX_WIDTH-1:0] count;
    wire [INDEX_WIDTH-1:0] input_index = count;
    wire min_update = (count == 0) || (data_in < min_reg);
    wire max_update = (count == 0) || (data_in > max_reg);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            min_reg<=0; max_reg<=0; count<=0; min_value<=0; max_value<=0;
            min_index<=0; max_index<=0; busy<=0; done<=0;
        end else begin
            done <= 1'b0;
            if (!busy && start) begin
                count <= 0; busy <= 1'b1;
            end else if (busy && valid) begin
                if (min_update) begin min_reg <= data_in; min_index <= input_index; end
                if (max_update) begin max_reg <= data_in; max_index <= input_index; end
                if (count == COUNT-1) begin
                    min_value <= min_update ? data_in : min_reg;
                    max_value <= max_update ? data_in : max_reg;
                    min_index <= min_update ? input_index : min_index;
                    max_index <= max_update ? input_index : max_index;
                    busy <= 1'b0; done <= 1'b1; count <= 0;
                end else count <= count + 1'b1;
            end
        end
    end
endmodule
