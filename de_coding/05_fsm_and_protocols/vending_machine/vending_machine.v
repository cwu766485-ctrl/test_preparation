// Simple 15-unit vending machine. Accepts one 5-unit or 10-unit coin per
// cycle. DISPENSE and CHANGE are one-cycle outputs; credit clears on vend.
module vending_machine (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       coin_5,
    input  wire       coin_10,
    output reg        dispense,
    output reg  [4:0] change,
    output reg  [4:0] credit
);
    wire [5:0] inserted = coin_10 ? 6'd10 : 6'd5;
    wire [5:0] total = {1'b0, credit} + inserted;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dispense <= 1'b0; change <= 0; credit <= 0;
        end else begin
            dispense <= 1'b0;
            change <= 0;
            if (coin_5 ^ coin_10) begin
                if (total >= 6'd15) begin
                    dispense <= 1'b1;
                    change <= total - 6'd15;
                    credit <= 0;
                end else credit <= total[4:0];
            end
        end
    end
endmodule
