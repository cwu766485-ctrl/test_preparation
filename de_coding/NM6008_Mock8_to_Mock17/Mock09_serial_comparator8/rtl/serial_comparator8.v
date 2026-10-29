`timescale 1ns/1ps
module serial_comparator8 (
    input wire clk,rst_n,start,bit_valid,a_bit,b_bit,
    output reg busy,done,gt,eq,lt
);
    reg [2:0] bit_idx;
    reg less_so_far,greater_so_far;
    wire g_now = greater_so_far | ((!less_so_far) && (!greater_so_far) && a_bit && !b_bit);
    wire l_now = less_so_far | ((!less_so_far) && (!greater_so_far) && !a_bit && b_bit);
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            busy<=0;done<=0;gt<=0;eq<=1;lt<=0;
            bit_idx<=0;less_so_far<=0;greater_so_far<=0;
        end else begin
            done<=0;
            if(!busy) begin
                if(start) begin
                    busy<=1;bit_idx<=0;greater_so_far<=0;less_so_far<=0;
                    gt<=0;eq<=1;lt<=0;
                end
            end else if(bit_valid) begin
                greater_so_far<=g_now; less_so_far<=l_now;
                if(bit_idx==3'd7) begin
                    busy<=0;done<=1;gt<=g_now;lt<=l_now;eq<=!(g_now|l_now);
                end else bit_idx<=bit_idx+3'd1;
            end
        end
    end
endmodule
