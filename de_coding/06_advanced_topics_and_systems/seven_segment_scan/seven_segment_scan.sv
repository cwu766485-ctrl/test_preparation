module seg_scan #(
    parameter int N = 4
) (
    input  logic         clk,
    input  logic         rst_n,
    input  logic [N*4-1:0] bcd,
    output logic [N-1:0] sel,
    output logic [6:0]   seg
);

    logic [15:0]       refresh_count;
    logic [$clog2(N)-1:0] digit;

    function automatic logic [6:0] decode_bcd(input logic [3:0] value);
        case (value)
            4'd0: decode_bcd = 7'b1111110;
            4'd1: decode_bcd = 7'b0110000;
            4'd2: decode_bcd = 7'b1101101;
            4'd3: decode_bcd = 7'b1111001;
            4'd4: decode_bcd = 7'b0110011;
            4'd5: decode_bcd = 7'b1011011;
            4'd6: decode_bcd = 7'b1011111;
            4'd7: decode_bcd = 7'b1110000;
            4'd8: decode_bcd = 7'b1111111;
            4'd9: decode_bcd = 7'b1111011;
            default: decode_bcd = 7'b0000000;
        endcase
    endfunction

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            refresh_count <= '0;
            digit         <= '0;
        end
        else begin
            refresh_count <= refresh_count + 1'b1;

            if (refresh_count == 0) begin
                if (digit == N - 1) begin
                    digit <= '0;
                end
                else begin
                    digit <= digit + 1'b1;
                end
            end
        end
    end

    always_comb begin
        sel = ~(1'b1 << digit);
        seg = decode_bcd(bcd[digit * 4 +: 4]);
    end

endmodule
