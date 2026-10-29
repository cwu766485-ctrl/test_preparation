`timescale 1ns/1ps
module overlap_detector (
    input wire clk,rst_n,bit_valid,din,
    output reg match
);
    reg [3:0] history;
    reg [2:0] seen;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin history<=0;seen<=0;match<=0;end
        else begin
            match<=0;
            if(bit_valid) begin
                history<={history[2:0],din};
                if(seen<4) seen<=seen+1'b1;
                if(seen>=3 && {history[2:0],din}==4'b1101)
                    match<=1;
            end
        end
    end
endmodule
