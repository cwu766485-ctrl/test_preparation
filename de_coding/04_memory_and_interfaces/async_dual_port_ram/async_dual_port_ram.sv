module async_dp_ram #(
    parameter int W = 8,
    parameter int D = 16
) (
    input  logic             a_clk,
    input  logic             b_clk,
    input  logic             a_we,
    input  logic             b_we,
    input  logic [$clog2(D)-1:0] a_addr,
    input  logic [$clog2(D)-1:0] b_addr,
    input  logic [W-1:0]     a_wdata,
    input  logic [W-1:0]     b_wdata,
    output logic [W-1:0]     a_rdata,
    output logic [W-1:0]     b_rdata
);

    logic [W-1:0] mem [0:D-1];

    // A dual-clock memory has one write process per port. Use always here:
    // always_ff forbids the shared memory from having multiple writers.
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
