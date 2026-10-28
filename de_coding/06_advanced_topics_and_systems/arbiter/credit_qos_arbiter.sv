// Credit-based QoS arbiter.
// Credits are replenished every REPLENISH_PERIOD cycles. A requester with
// available credit is selected in round-robin order, and one accepted grant
// consumes one credit. WEIGHTx therefore defines its reserved service budget.
module credit_qos_arbiter #(
    parameter int CREDIT_W          = 8,
    parameter int REPLENISH_PERIOD  = 256,
    parameter int WEIGHT0           = 1,
    parameter int WEIGHT1           = 2,
    parameter int WEIGHT2           = 4,
    parameter int WEIGHT3           = 8
) (
    input  logic                clk,
    input  logic                rst_n,
    input  logic [3:0]          req,
    input  logic                grant_accept,
    output logic [3:0]          grant,
    output logic                grant_valid,
    output logic [CREDIT_W-1:0] credit0,
    output logic [CREDIT_W-1:0] credit1,
    output logic [CREDIT_W-1:0] credit2,
    output logic [CREDIT_W-1:0] credit3
);

    localparam int RW = (REPLENISH_PERIOD <= 1) ?
                        1 : $clog2(REPLENISH_PERIOD);

    logic [RW-1:0] replenish_count;
    logic [1:0]    last_grant;
    logic [1:0]    selected;
    logic          found;
    integer        offset;
    integer        index;

    function automatic logic has_credit(input integer requester);
        case (requester)
            0: has_credit = (credit0 != 0);
            1: has_credit = (credit1 != 0);
            2: has_credit = (credit2 != 0);
            3: has_credit = (credit3 != 0);
            default: has_credit = 1'b0;
        endcase
    endfunction

    always_comb begin
        grant       = 4'b0000;
        grant_valid = 1'b0;
        selected    = last_grant;
        found       = 1'b0;

        for (offset = 1; offset <= 4; offset = offset + 1) begin
            index = (last_grant + offset) % 4;

            if (!found && req[index] && has_credit(index)) begin
                grant[index] = 1'b1;
                grant_valid  = 1'b1;
                selected     = index[1:0];
                found        = 1'b1;
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            replenish_count <= '0;
            last_grant      <= 2'd3;
            credit0         <= WEIGHT0;
            credit1         <= WEIGHT1;
            credit2         <= WEIGHT2;
            credit3         <= WEIGHT3;
        end
        else if (replenish_count == REPLENISH_PERIOD - 1) begin
            replenish_count <= '0;
            credit0         <= WEIGHT0;
            credit1         <= WEIGHT1;
            credit2         <= WEIGHT2;
            credit3         <= WEIGHT3;
        end
        else begin
            replenish_count <= replenish_count + 1'b1;

            if (grant_valid && grant_accept) begin
                last_grant <= selected;

                case (selected)
                    2'd0: credit0 <= credit0 - 1'b1;
                    2'd1: credit1 <= credit1 - 1'b1;
                    2'd2: credit2 <= credit2 - 1'b1;
                    2'd3: credit3 <= credit3 - 1'b1;
                    default: begin
                        credit0 <= credit0;
                    end
                endcase
            end
        end
    end

endmodule
