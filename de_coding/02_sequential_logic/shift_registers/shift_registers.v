

module shift_reg #(
    parameter integer W = 8
) (
    input wire clk,
    input wire rst_n,
    input wire din,
    output wire dout
);

    reg [W-1:0] shift_data;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_data <= 0;
        end
        else begin
            shift_data <= {shift_data[W-2:0], din};
        end
    end

    assign dout = shift_data[W-1];

endmodule

module universal_sr #(
    parameter integer W = 8
) (
    input wire clk,
    input wire rst_n,
    input wire [1:0]   op,
    input wire sin,
    input wire [W-1:0] par_in,
    output reg [W-1:0] q
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= 0;
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