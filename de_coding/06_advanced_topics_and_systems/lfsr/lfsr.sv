module lfsr4 (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       en,
    output logic [3:0] lfsr
);

    logic feedback;

    assign feedback = lfsr[3] ^ lfsr[2];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr <= 4'b0001;
        end
        else if (en) begin
            lfsr <= {lfsr[2:0], feedback};
        end
    end

endmodule
