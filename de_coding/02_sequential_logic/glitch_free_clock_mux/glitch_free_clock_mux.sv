module glitch_free_clk_mux (
    input  logic clk0,
    input  logic clk1,
    input  logic sel,
    input  logic rst_n,
    output logic clk_out
);

    logic enable_clk0;
    logic enable_clk1;

    always_ff @(negedge clk0 or negedge rst_n) begin
        if (!rst_n) begin
            enable_clk0 <= 1'b0;
        end
        else begin
            enable_clk0 <= ~sel & ~enable_clk1;
        end
    end

    always_ff @(negedge clk1 or negedge rst_n) begin
        if (!rst_n) begin
            enable_clk1 <= 1'b0;
        end
        else begin
            enable_clk1 <= sel & ~enable_clk0;
        end
    end

    assign clk_out = (clk0 & enable_clk0) |
                     (clk1 & enable_clk1);

endmodule
