`timescale 1ns/1ps
module restoring_divider8 (
    input wire clk,rst_n,start,
    input wire [7:0] dividend,divisor,
    output reg [7:0] quotient,remainder,
    output reg busy,done,div_by_zero
);
  reg [7:0] div_shift,den_hold;
  reg [8:0] rem_acc;
  reg [2:0] bit_idx;
  wire [8:0] trial={rem_acc[7:0],div_shift[7]};
  wire can_sub=(trial>={1'b0,den_hold});
  wire [8:0] next_rem=can_sub?(trial-{1'b0,den_hold}):trial;
  always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      div_shift<=0;den_hold<=0;rem_acc<=0;bit_idx<=0;
      quotient<=0;remainder<=0;busy<=0;done<=0;div_by_zero<=0;
    end else begin
      done<=0;
      if(!busy)begin
        if(start)begin
          div_by_zero<=0;quotient<=0;remainder<=0;
          if(divisor==0)begin
            quotient<=8'hff;remainder<=dividend;div_by_zero<=1;
            busy<=0;done<=1;
          end else begin
            div_shift<=dividend;den_hold<=divisor;
            rem_acc<=0;bit_idx<=0;busy<=1;
          end
        end
      end else begin
        div_shift<={div_shift[6:0],1'b0};
        rem_acc<=next_rem;
        quotient<={quotient[6:0],can_sub};
        if(bit_idx==3'd7)begin
          remainder<=next_rem[7:0];busy<=0;done<=1;
        end else bit_idx<=bit_idx+3'd1;
      end
    end
  end
endmodule
