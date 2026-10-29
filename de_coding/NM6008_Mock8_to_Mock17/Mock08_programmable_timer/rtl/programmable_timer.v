`timescale 1ns/1ps
module programmable_timer (
    input wire clk, rst_n, enable, load,
    input wire [7:0] period_in,
    output reg [7:0] count, active_period,
    output reg tick
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 8'd0;
            active_period <= 8'd4;
            tick <= 1'b0;
        end else begin
            tick <= 1'b0;
            if (load) begin
                active_period <= (period_in == 8'd0) ? 8'd1 : period_in;
                count <= 8'd0;
            end else if (enable) begin
                if (count == active_period - 8'd1) begin
                    count <= 8'd0;
                    tick <= 1'b1;
                end else begin
                    count <= count + 8'd1;
                end
            end
        end
    end
endmodule
