// Three independent counter behaviors for study and simulation.
// cnt_up/cnt_down wrap at 2**WIDTH; cnt_modN wraps at the configured N.

module cnt_up #(
    parameter int WIDTH = 4
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    output logic [WIDTH-1:0]  cnt
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cnt <= '0;
        else if (en)
            cnt <= cnt + 1'b1;
    end
endmodule

module cnt_down #(
    parameter int WIDTH = 4
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    output logic [WIDTH-1:0]  cnt
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cnt <= '0;
        else if (en)
            cnt <= cnt - 1'b1;
    end
endmodule

module cnt_modN #(
    parameter int N = 10,
    parameter int WIDTH = (N <= 1) ? 1 : $clog2(N)
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    output logic [WIDTH-1:0]  cnt,
    output logic             tc
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cnt <= '0;
        else if (en) begin
            if (cnt == N - 1)
                cnt <= '0;
            else
                cnt <= cnt + 1'b1;
        end
    end

    // tc describes the current count; it is high while cnt is N-1.
    assign tc = (cnt == N - 1);
endmodule
