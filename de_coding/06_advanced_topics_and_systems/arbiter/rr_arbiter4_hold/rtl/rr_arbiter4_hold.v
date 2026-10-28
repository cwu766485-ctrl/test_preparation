`timescale 1ns/1ps
// Mock6: 4-request round-robin with backpressure.
// grant_valid & ready = completed transfer; advance pointer only then.
// When a grant is blocked, it stays asserted even if req changes.
// Every accepted grant rotates priority to (winner+1) modulo 4.
module rr_arbiter4_hold (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [3:0] req,
    input  wire       ready,
    output reg  [3:0] grant,
    output wire       grant_valid
);
    reg [1:0] pointer;
    reg       holding;
    reg [3:0] held_grant;
    integer i;
    reg [1:0] idx;

    always @* begin
        grant = 4'b0000;
        idx = pointer;
        if (holding) grant = held_grant;
        else begin
            for (i=0;i<4;i=i+1) begin
                idx = pointer + i;
                if (req[idx] && grant==0) grant[idx]=1'b1;
            end
        end
    end
    assign grant_valid = |grant;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pointer    <= 2'd0;
            holding    <= 1'b0;
            held_grant <= 4'd0;
        end else if (grant_valid) begin
            if (ready) begin
                case (grant)
                    4'b0001: pointer <= 2'd1;
                    4'b0010: pointer <= 2'd2;
                    4'b0100: pointer <= 2'd3;
                    4'b1000: pointer <= 2'd0;
                    default: pointer <= pointer;
                endcase
                holding <= 1'b0;
            end else if (!holding) begin
                holding    <= 1'b1;
                held_grant <= grant;
            end
        end
    end
endmodule
