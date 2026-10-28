

module async_dp_ram #(
    parameter integer W = 8,
    parameter integer D = 16
) (
    input wire a_clk,
    input wire b_clk,
    input wire a_we,
    input wire b_we,
    input wire [$clog2(D)-1:0] a_addr,
    input wire [$clog2(D)-1:0] b_addr,
    input wire [W-1:0]     a_wdata,
    input wire [W-1:0]     b_wdata,
    output reg [W-1:0]     a_rdata,
    output reg [W-1:0]     b_rdata
);

    reg [W-1:0] mem [0:D-1];

    always @(posedge a_clk) begin
        if (a_we) begin
            mem[a_addr] <= a_wdata;
        end
        a_rdata <= mem[a_addr];
    end

    always @(posedge b_clk) begin
        if (b_we) begin
            mem[b_addr] <= b_wdata;
        end
        b_rdata <= mem[b_addr];
    end

endmodule