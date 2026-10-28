// M4 controller for a WIDTH-cycle serial addition.
module serial_adder_controller #(
    parameter integer WIDTH = 16,
    parameter integer INDEX_WIDTH = (WIDTH <= 1) ? 1 : $clog2(WIDTH)
) (
    input wire clk, input wire rst_n, input wire start,
    output wire load, output wire step, output wire last,
    output reg [INDEX_WIDTH-1:0] bit_index,
    output reg busy, output reg done
);
    assign load = start && !busy;
    assign step = busy;
    assign last = busy && (bit_index == WIDTH-1);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin bit_index<=0; busy<=0; done<=0; end
        else begin
            done <= 1'b0;
            if (!busy && start) begin bit_index<=0; busy<=1'b1; end
            else if (busy) begin
                if (last) begin bit_index<=0; busy<=1'b0; done<=1'b1; end
                else bit_index<=bit_index+1'b1;
            end
        end
    end
endmodule
