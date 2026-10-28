// Round-robin arbiter. Priority starts after the last accepted requester.


module round_robin_arbiter (
    input wire clk,
    input wire rst_n,
    input wire [3:0] req,
    input wire grant_accept,
    output reg [3:0] grant,
    output reg grant_valid
);

    reg [1:0] last_grant;
    reg [1:0] selected;
    reg found;
    integer     offset;
    integer     index;

    always @* begin
        grant       = 4'b0000;
        grant_valid = 1'b0;
        selected    = last_grant;
        found       = 1'b0;

        for (offset = 1; offset <= 4; offset = offset + 1) begin
            index = (last_grant + offset) % 4;

            if (!found && req[index]) begin
                grant[index] = 1'b1;
                grant_valid  = 1'b1;
                selected     = index[1:0];
                found        = 1'b1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            last_grant <= 2'd3;
        end
        else if (grant_valid && grant_accept) begin
            last_grant <= selected;
        end
    end

endmodule