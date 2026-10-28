// Three independent counter behaviors for study and simulation.
//
// cnt_up and cnt_down wrap naturally at the selected bit width (2**WIDTH).
// cnt_modN wraps at N-1, so its range is exactly 0 through N-1.

module cnt_up #(
    parameter integer WIDTH = 4
) (
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 en,
    output reg  [WIDTH-1:0]     cnt
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cnt <= {WIDTH{1'b0}};
        else if (en)
            cnt <= cnt + 1'b1;
    end

endmodule

module cnt_down #(
    parameter integer WIDTH = 4
) (
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 en,
    output reg  [WIDTH-1:0]     cnt
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cnt <= {WIDTH{1'b0}};
        else if (en)
            cnt <= cnt - 1'b1;
    end

endmodule

module cnt_modN #(
    parameter integer N = 10,
    parameter integer WIDTH = (N <= 1) ? 1 : $clog2(N)
) (
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 en,
    output reg  [WIDTH-1:0]     cnt,
    output wire                 tc
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cnt <= {WIDTH{1'b0}};
        else if (en) begin
            if (cnt == N - 1)
                cnt <= {WIDTH{1'b0}};
            else
                cnt <= cnt + 1'b1;
        end
    end

    // tc describes the current count; it is high while cnt is N-1.
    assign tc = (cnt == N - 1);

endmodule
