// Weighted round-robin arbiter.
// Each requester may receive WEIGHTx consecutive accepted grants before
// priority advances to the next active requester.
module weighted_round_robin_arbiter #(
    parameter int WEIGHT0 = 1,
    parameter int WEIGHT1 = 2,
    parameter int WEIGHT2 = 3,
    parameter int WEIGHT3 = 4
) (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [3:0] req,
    input  logic       grant_accept,
    output logic [3:0] grant,
    output logic       grant_valid
);

    localparam int MAX_WEIGHT = (WEIGHT0 > WEIGHT1) ?
                                ((WEIGHT0 > WEIGHT2) ?
                                 ((WEIGHT0 > WEIGHT3) ? WEIGHT0 : WEIGHT3) :
                                 ((WEIGHT2 > WEIGHT3) ? WEIGHT2 : WEIGHT3)) :
                                ((WEIGHT1 > WEIGHT2) ?
                                 ((WEIGHT1 > WEIGHT3) ? WEIGHT1 : WEIGHT3) :
                                 ((WEIGHT2 > WEIGHT3) ? WEIGHT2 : WEIGHT3));
    localparam int CW = (MAX_WEIGHT <= 1) ? 1 : $clog2(MAX_WEIGHT + 1);

    logic [1:0]  current_owner;
    logic [CW-1:0] grants_used;
    logic [1:0]  selected;
    logic        found;
    integer      offset;
    integer      index;
    integer      selected_weight;

    function automatic integer get_weight(input logic [1:0] requester);
        case (requester)
            2'd0: get_weight = WEIGHT0;
            2'd1: get_weight = WEIGHT1;
            2'd2: get_weight = WEIGHT2;
            2'd3: get_weight = WEIGHT3;
            default: get_weight = 1;
        endcase
    endfunction

    always_comb begin
        grant           = 4'b0000;
        grant_valid     = 1'b0;
        selected        = current_owner;
        selected_weight = get_weight(current_owner);
        found           = 1'b0;

        if (req[current_owner] && (grants_used < selected_weight)) begin
            grant[current_owner] = 1'b1;
            grant_valid          = 1'b1;
            found                = 1'b1;
        end
        else begin
            for (offset = 1; offset <= 4; offset = offset + 1) begin
                index = (current_owner + offset) % 4;

                if (!found && req[index]) begin
                    grant[index] = 1'b1;
                    grant_valid  = 1'b1;
                    selected     = index[1:0];
                    found        = 1'b1;
                end
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_owner <= 2'd0;
            grants_used   <= '0;
        end
        else if (grant_valid && grant_accept) begin
            if (selected != current_owner) begin
                current_owner <= selected;
                grants_used   <= {{(CW-1){1'b0}}, 1'b1};
            end
            else if (grants_used + 1 >= get_weight(current_owner)) begin
                grants_used <= get_weight(current_owner);
            end
            else begin
                grants_used <= grants_used + 1'b1;
            end
        end
    end

endmodule
