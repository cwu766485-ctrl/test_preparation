

module lfsr4 (
    input wire clk,
    input wire rst_n,
    input wire en,
    output reg [3:0] lfsr
);

    wire feedback;

    assign feedback = lfsr[3] ^ lfsr[2];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr <= 4'b0001;
        end
        else if (en) begin
            lfsr <= {lfsr[2:0], feedback};
        end
    end

endmodule