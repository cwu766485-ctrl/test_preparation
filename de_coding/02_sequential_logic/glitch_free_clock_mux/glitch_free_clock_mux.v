

module glitch_free_clk_mux (
    input wire clk0,
    input wire clk1,
    input wire sel,
    input wire rst_n,
    output wire clk_out
);

    reg enable_clk0;
    reg enable_clk1;

    always @(negedge clk0 or negedge rst_n) begin
        if (!rst_n) begin
            enable_clk0 <= 1'b0;
        end
        else begin
            enable_clk0 <= ~sel & ~enable_clk1;
        end
    end

    always @(negedge clk1 or negedge rst_n) begin
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