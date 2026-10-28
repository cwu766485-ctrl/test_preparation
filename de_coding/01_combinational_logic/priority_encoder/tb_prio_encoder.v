`timescale 1ns/1ps

module tb_prio_encoder;

reg  [7:0] req;

wire [2:0] enc;
wire       valid;

reg [2:0] exp_enc;
reg       exp_valid;

integer i;


prio_encoder dut (
    .req   (req),
    .enc   (enc),
    .valid (valid)
);


// ============================================================
// waveform
// ============================================================

`ifdef FSDB
initial begin
    $fsdbDumpfile("prio_encoder.fsdb");
    $fsdbDumpvars(0, tb_prio_encoder);
end
`endif


// ============================================================
// stimulus
// ============================================================

initial begin

    req = 8'b0;

    #10;


    // 遍历所有256种request
    for (i = 0; i < 256; i = i + 1) begin

        req = i[7:0];

        // ---------------------------------------------
        // reference model
        // ---------------------------------------------

        exp_valid = |req;

        if      (req[7]) exp_enc = 3'd7;
        else if (req[6]) exp_enc = 3'd6;
        else if (req[5]) exp_enc = 3'd5;
        else if (req[4]) exp_enc = 3'd4;
        else if (req[3]) exp_enc = 3'd3;
        else if (req[2]) exp_enc = 3'd2;
        else if (req[1]) exp_enc = 3'd1;
        else             exp_enc = 3'd0;


        #10;


        // ---------------------------------------------
        // compare
        // ---------------------------------------------

        if ((enc !== exp_enc) ||
            (valid !== exp_valid)) begin

            $display(
                "ERROR req=%b enc=%0d exp_enc=%0d valid=%b exp_valid=%b",
                req,
                enc,
                exp_enc,
                valid,
                exp_valid
            );

            $finish;
        end

    end


    $display("==============================");
    $display(" PRIORITY ENCODER TEST PASS");
    $display("==============================");

    #20;
    $finish;

end

endmodule
