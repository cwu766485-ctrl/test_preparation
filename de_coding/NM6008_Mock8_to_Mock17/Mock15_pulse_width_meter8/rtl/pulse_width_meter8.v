`timescale 1ns/1ps
module pulse_width_meter8 (
    input wire clk,rst_n,arm,signal_in,
    output reg [7:0] width,
    output reg busy,done,overflow
);
    reg [7:0] run_count;
    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)begin
        width<=0;busy<=0;done<=0;overflow<=0;run_count<=0;
      end else begin
        done<=0;
        if(!busy)begin
          if(arm && signal_in)begin
            busy<=1;run_count<=8'd1;width<=0;overflow<=0;
          end
        end else if(signal_in)begin
          if(run_count==8'hff)overflow<=1;
          else run_count<=run_count+8'd1;
        end else begin
          busy<=0;done<=1;width<=run_count;
        end
      end
    end
endmodule
