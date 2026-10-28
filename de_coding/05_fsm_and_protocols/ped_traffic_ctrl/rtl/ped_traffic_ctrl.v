`timescale 1ns/1ps
// Mock5: one synchronous tick defines one time unit; tick=0 freezes the timer.
// A pedestrian request latches in GREEN/YELLOW/ALL_RED, not in WALK.
// Sequence: GREEN -> YELLOW -> ALL_RED -> (WALK if pending else GREEN) -> GREEN.
module ped_traffic_ctrl #(
    parameter integer GREEN_TICKS = 4,
    parameter integer YELLOW_TICKS = 2,
    parameter integer ALL_RED_TICKS = 1,
    parameter integer WALK_TICKS = 3
)(
    input  wire clk,
    input  wire rst_n,
    input  wire tick,
    input  wire ped_req,
    output wire car_green,
    output wire car_yellow,
    output wire car_red,
    output wire walk,
    output reg  [1:0] phase
);
    localparam [1:0] GREEN=2'd0, YELLOW=2'd1, ALL_RED=2'd2, WALK=2'd3;
    reg [31:0] elapsed;
    reg pending;
    assign car_green  = (phase == GREEN);
    assign car_yellow = (phase == YELLOW);
    assign car_red    = (phase == ALL_RED || phase == WALK);
    assign walk       = (phase == WALK);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phase   <= GREEN;
            elapsed <= 32'd0;
            pending <= 1'b0;
        end else begin
            if (ped_req && phase != WALK) pending <= 1'b1;
            if (tick) begin
                case (phase)
                    GREEN: begin
                        if (elapsed == GREEN_TICKS-1) begin
                            elapsed <= 0; phase <= YELLOW;
                        end else elapsed <= elapsed + 1;
                    end
                    YELLOW: begin
                        if (elapsed == YELLOW_TICKS-1) begin
                            elapsed <= 0; phase <= ALL_RED;
                        end else elapsed <= elapsed + 1;
                    end
                    ALL_RED: begin
                        if (elapsed == ALL_RED_TICKS-1) begin
                            elapsed <= 0;
                            if (pending || ped_req) begin
                                phase <= WALK;
                                pending <= 0;
                            end else phase <= GREEN;
                        end else elapsed <= elapsed + 1;
                    end
                    WALK: begin
                        if (elapsed == WALK_TICKS-1) begin
                            elapsed <= 0; phase <= GREEN;
                        end else elapsed <= elapsed + 1;
                    end
                    default: begin
                        phase <= GREEN; elapsed <= 0; pending <= 0;
                    end
                endcase
            end
        end
    end
endmodule
