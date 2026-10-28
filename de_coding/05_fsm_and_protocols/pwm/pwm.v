

module pwm #(
    parameter integer N = 8
) (
    input wire clk,
    input wire rst_n,
    input wire [N-1:0] duty,
    output wire pwm_out
);

    reg [N-1:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
        end
        else begin
            count <= count + 1'b1;
        end
    end

    assign pwm_out = (count < duty);

endmodule