`timescale 1ns/1ps
module sync_fifo8 (
    input wire clk,rst_n,w_en,r_en,
    input wire [7:0] wdata,
    output wire w_ready,r_valid,full,empty,
    output wire [7:0] rdata,
    output reg [3:0] count
);
    reg [7:0] mem[0:7];
    reg [2:0] wptr,rptr;
    wire push,pop;
    assign full = (count==4'd8);
    assign empty = (count==4'd0);
    assign r_valid = !empty;
    assign w_ready = !full || (r_en && r_valid);
    assign push = w_en && w_ready;
    assign pop = r_en && r_valid;
    assign rdata = empty ? 8'd0 : mem[rptr];
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin wptr<=0;rptr<=0;count<=0;end
        else begin
            if(push) begin mem[wptr]<=wdata;wptr<=wptr+1'b1;end
            if(pop) rptr<=rptr+1'b1;
            case({push,pop})
                2'b10:count<=count+4'd1;
                2'b01:count<=count-4'd1;
                default:count<=count;
            endcase
        end
    end
endmodule
