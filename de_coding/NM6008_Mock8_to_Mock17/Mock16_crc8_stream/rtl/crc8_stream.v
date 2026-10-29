`timescale 1ns/1ps
module crc8_stream (
    input wire clk,rst_n,start,valid,last,
    input wire [7:0] data,
    output reg [7:0] crc,
    output reg busy,done
);
  function [7:0] crc_byte;
    input [7:0] old_crc,byte_in;
    reg [7:0] x;
    integer j;
    begin
      x=old_crc ^ byte_in;
      for(j=0;j<8;j=j+1)
        x=x[7] ? ((x<<1)^8'h07) : (x<<1);
      crc_byte=x;
    end
  endfunction
  always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin crc<=0;busy<=0;done<=0;end
    else begin
      done<=0;
      if(!busy)begin
        if(start)begin crc<=0;busy<=1;end
      end else if(valid)begin
        crc<=crc_byte(crc,data);
        if(last)begin busy<=0;done<=1;end
      end
    end
  end
endmodule
