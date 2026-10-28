// Fixed priority: request 3 has the highest priority.


module strict_priority_arbiter (
    input wire [3:0] req,
    output reg [3:0] grant,
    output reg grant_valid
);

    always @* begin
        grant       = 4'b0000;
        grant_valid = 1'b0;

        casez (req)
            4'b1???: grant = 4'b1000;
            4'b01??: grant = 4'b0100;
            4'b001?: grant = 4'b0010;
            4'b0001: grant = 4'b0001;
            default: begin
                grant       = 4'b0000;
                grant_valid = 1'b0;
            end
        endcase
    end

endmodule