`timescale 1ns/1ps
module bcd_stopwatch (
    input wire clk,rst_n,clear,enable,tick_in,
    output reg [3:0] tens,ones,
    output reg wrap
);
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin tens<=0;ones<=0;wrap<=0;end
    else begin
      wrap<=0;
      if(clear) begin tens<=0;ones<=0;end
      else if(enable && tick_in) begin
        if(ones==9) begin
          ones<=0;
          if(tens==9) begin tens<=0;wrap<=1;end
          else tens<=tens+1'b1;
        end else ones<=ones+1'b1;
      end
    end
  end
endmodule
