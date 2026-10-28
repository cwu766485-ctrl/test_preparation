module pwm #(
    parameter int N = 8
) (
    input  logic         clk,
    input  logic         rst_n,
    input  logic [N-1:0] duty,
    output logic         pwm_out
);

    logic [N-1:0] count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
        end
        else begin
            count <= count + 1'b1;
        end
    end

    assign pwm_out = (count < duty);

endmodule
