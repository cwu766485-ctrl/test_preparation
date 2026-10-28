

module dff_async (
    input wire clk,
    input wire rst_n,
    input wire d,
    output reg q
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= 1'b0;
        end
        else begin
            q <= d;
        end
    end

endmodule

module dff_sync_en (
    input wire clk,
    input wire rst,
    input wire en,
    input wire d,
    output reg q
);

    always @(posedge clk) begin
        if (rst) begin
            q <= 1'b0;
        end
        else if (en) begin
            q <= d;
        end
    end

endmodule