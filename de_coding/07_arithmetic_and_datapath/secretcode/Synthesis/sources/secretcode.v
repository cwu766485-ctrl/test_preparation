`timescale 1ns/1ps

module secretcode(
  input clk,
  input rst_n, 
  input digit_valid, 
  input [3:0] digit, 
  input relock, 
  output unlocked,
  output locked_out, 
  output reg error_pulse
);
    localparam IDLE=3'd0,
               D1=3'd1,
               D2=3'd2,
               D3=3'd3,
               OPEN=3'd4,
               LOCKED=3'd5;
    reg [2:0] state;
    reg [2:0] failures;
    assign unlocked=(state==OPEN);
    assign locked_out=(state==LOCKED);
    // Password is 0,1,2,4. An incorrect digit ends that attempt.
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state<=IDLE;
            failures<=0;
            error_pulse<=0;
        end
        else begin
            error_pulse<=0;
            if(state==OPEN) begin
                if(relock) state<=IDLE;
            end
            else if(state!=LOCKED && digit_valid) begin
                if((state==IDLE && digit==0)||(state==D1 && digit==1)||(state==D2 && digit==2)||(state==D3 && digit==4)) begin
                    case(state) IDLE:state<=D1;
                        D1:state<=D2;
                        D2:state<=D3;
                        D3:begin
                            state<=OPEN;
                            failures<=0;
                        end
                        default:state<=IDLE;
                    endcase
                end
                else begin
                    error_pulse<=1;
                    if(failures==4) state<=LOCKED;
                    else begin
                        failures<=failures+1'b1;
                        state<=IDLE;
                    end
                end
            end
        end
    end
endmodule
