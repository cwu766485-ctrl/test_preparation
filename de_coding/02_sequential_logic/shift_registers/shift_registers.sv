module shift_reg #(
    parameter int W = 8
) (
    input  logic clk,
    input  logic rst_n,
    input  logic din,
    output logic dout
);

    logic [W-1:0] shift_data;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_data <= '0;
        end
        else begin
            shift_data <= {shift_data[W-2:0], din};
        end
    end

    assign dout = shift_data[W-1];

endmodule


module universal_sr #(
    parameter int W = 8
) (
    input  logic         clk,
    input  logic         rst_n,
    input  logic [1:0]   op,
    input  logic         sin,
    input  logic [W-1:0] par_in,
    output logic [W-1:0] q
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= '0;
        end
        else begin
            case (op)
                2'b00: q <= q;
                2'b01: q <= {sin, q[W-1:1]};
                2'b10: q <= {q[W-2:0], sin};
                2'b11: q <= par_in;
                default: q <= q;
            endcase
        end
    end

endmodule
