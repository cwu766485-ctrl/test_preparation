module pulse_width (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        sig,
    output logic [15:0] width,
    output logic        done
);

    logic sig_d;
    logic measuring;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sig_d     <= 1'b0;
            measuring <= 1'b0;
            width     <= '0;
            done      <= 1'b0;
        end
        else begin
            sig_d <= sig;
            done  <= 1'b0;

            if (sig && !sig_d) begin
                measuring <= 1'b1;
                width     <= '0;
            end
            else if (sig && measuring) begin
                width <= width + 1'b1;
            end
            else if (!sig && sig_d) begin
                measuring <= 1'b0;
                done      <= 1'b1;
            end
        end
    end

endmodule
