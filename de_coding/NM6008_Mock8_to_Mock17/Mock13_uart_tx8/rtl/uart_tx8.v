`timescale 1ns/1ps
module uart_tx8 #(parameter integer CLKS_PER_BIT=4) (
    input wire clk,rst_n,start,
    input wire [7:0] data_in,
    output wire tx,
    output reg busy,done
);
    reg [9:0] frame;
    reg [3:0] bit_idx;
    reg [15:0] baud_count;
    assign tx=busy ? frame[0] : 1'b1;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            frame<=10'h3ff;bit_idx<=0;baud_count<=0;busy<=0;done<=0;
        end else begin
            done<=0;
            if(!busy) begin
                if(start)begin
                    frame<={1'b1,data_in,1'b0};
                    busy<=1;bit_idx<=0;baud_count<=0;
                end
            end else if(baud_count==CLKS_PER_BIT-1)begin
                baud_count<=0;
                if(bit_idx==9)begin busy<=0;done<=1;end
                else begin frame<={1'b1,frame[9:1]};bit_idx<=bit_idx+1'b1;end
            end else baud_count<=baud_count+1'b1;
        end
    end
endmodule
