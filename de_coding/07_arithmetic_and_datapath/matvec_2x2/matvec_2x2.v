// Signed 2x2 matrix times 2x1 vector, scheduled as four multiply-accumulate
// steps. Inputs are captured at START; DONE pulses after the fourth step.
module matvec_2x2 #(
    parameter integer WIDTH = 8,
    parameter integer OUT_WIDTH = 2 * WIDTH + 1
) (
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         start,
    input  wire signed [WIDTH-1:0]      m00,
    input  wire signed [WIDTH-1:0]      m01,
    input  wire signed [WIDTH-1:0]      m10,
    input  wire signed [WIDTH-1:0]      m11,
    input  wire signed [WIDTH-1:0]      x0,
    input  wire signed [WIDTH-1:0]      x1,
    output reg  signed [OUT_WIDTH-1:0]  y0,
    output reg  signed [OUT_WIDTH-1:0]  y1,
    output reg                          busy,
    output reg                          done
);
    reg signed [WIDTH-1:0] m00_r, m01_r, m10_r, m11_r, x0_r, x1_r;
    reg signed [OUT_WIDTH-1:0] accum;
    reg [1:0] step_count;
    wire signed [2*WIDTH-1:0] p00 = $signed(m00_r) * $signed(x0_r);
    wire signed [2*WIDTH-1:0] p01 = $signed(m01_r) * $signed(x1_r);
    wire signed [2*WIDTH-1:0] p10 = $signed(m10_r) * $signed(x0_r);
    wire signed [2*WIDTH-1:0] p11 = $signed(m11_r) * $signed(x1_r);
    wire signed [OUT_WIDTH-1:0] p00_ext = p00, p01_ext = p01;
    wire signed [OUT_WIDTH-1:0] p10_ext = p10, p11_ext = p11;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            m00_r <= 0; m01_r <= 0; m10_r <= 0; m11_r <= 0; x0_r <= 0; x1_r <= 0;
            accum <= 0; step_count <= 0; y0 <= 0; y1 <= 0; busy <= 0; done <= 0;
        end else begin
            done <= 1'b0;
            if (!busy && start) begin
                m00_r <= m00; m01_r <= m01; m10_r <= m10; m11_r <= m11; x0_r <= x0; x1_r <= x1;
                step_count <= 0; accum <= 0; busy <= 1'b1;
            end else if (busy) begin
                case (step_count)
                    2'd0: begin accum <= p00_ext; step_count <= 2'd1; end
                    2'd1: begin accum <= accum + p01_ext; y0 <= accum + p01_ext; step_count <= 2'd2; end
                    2'd2: begin accum <= p10_ext; step_count <= 2'd3; end
                    2'd3: begin
                        y1 <= accum + p11_ext;
                        step_count <= 0;
                        busy <= 1'b0;
                        done <= 1'b1;
                    end
                    default: begin step_count <= 0; accum <= 0; end
                endcase
            end
        end
    end
endmodule
