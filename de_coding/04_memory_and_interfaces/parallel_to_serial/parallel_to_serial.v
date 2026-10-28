

module parallel_to_serial #(
    parameter integer W = 8
) (
    input wire clk,
    input wire rst_n,
    input wire load,
    input wire en,
    input wire [W-1:0] parallel_i,
    output reg serial_o,
    output reg busy
);

    localparam integer CW = $clog2(W + 1);
    reg [W-1:0] shift_data;
    reg [CW-1:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_data <= 0;
            count      <= 0;
            serial_o   <= 1'b0;
            busy       <= 1'b0;
        end
        else if (load && !busy) begin
            shift_data <= parallel_i;
            count      <= W;
            busy       <= 1'b1;
        end
        else if (en && busy) begin
            serial_o   <= shift_data[W-1];
            shift_data <= {shift_data[W-2:0], 1'b0};
            count      <= count - 1'b1;

            if (count == 1) begin
                busy <= 1'b0;
            end
        end
    end

endmodule