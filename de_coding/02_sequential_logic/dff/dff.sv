module dff_async (
    input  logic clk,
    input  logic rst_n,
    input  logic d,
    output logic q
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= 1'b0;
        end
        else begin
            q <= d;
        end
    end

endmodule


module dff_sync_en (
    input  logic clk,
    input  logic rst,
    input  logic en,
    input  logic d,
    output logic q
);

    always_ff @(posedge clk) begin
        if (rst) begin
            q <= 1'b0;
        end
        else if (en) begin
            q <= d;
        end
    end

endmodule
