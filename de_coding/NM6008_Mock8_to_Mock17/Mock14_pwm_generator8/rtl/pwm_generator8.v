`timescale 1ns/1ps
module pwm_generator8 (
    input wire clk,rst_n,enable,config,
    input wire [7:0] period_in,duty_in,
    output reg [7:0] count,active_period,active_duty,
    output wire pwm
);
    wire [7:0] clean_period=(period_in==0)?8'd1:period_in;
    assign pwm=(count<active_duty);
    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)begin count<=0;active_period<=4;active_duty<=2;end
      else if(config)begin
        active_period<=clean_period;
        active_duty<=(duty_in>clean_period)?clean_period:duty_in;
        count<=0;
      end else if(enable)begin
        if(count==active_period-1'b1)count<=0;
        else count<=count+1'b1;
      end
    end
endmodule
