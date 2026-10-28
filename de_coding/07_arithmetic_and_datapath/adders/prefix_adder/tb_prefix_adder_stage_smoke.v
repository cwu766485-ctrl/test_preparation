`timescale 1ns/1ps
// Generated standalone smoke test for prefix_adder_stage.
module tb_prefix_adder_stage_smoke;
    localparam integer WIDTH = 16;
    localparam integer DISTANCE = 1;
    reg [WIDTH-1:0] propagate_in;
    reg [WIDTH-1:0] generate_in;
    wire [WIDTH-1:0] propagate_out;
    wire [WIDTH-1:0] generate_out;

    prefix_adder_stage dut (
        .propagate_in(propagate_in),
        .generate_in(generate_in),
        .propagate_out(propagate_out),
        .generate_out(generate_out)
    );

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        propagate_in = 0;
        generate_in = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            #5;
            propagate_in = $random;
            generate_in = $random;
            #1;
            if ((^propagate_out) === 1'bx) begin $display("FAIL: prefix_adder_stage.propagate_out is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^generate_out) === 1'bx) begin $display("FAIL: prefix_adder_stage.generate_out is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: prefix_adder_stage reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_prefix_adder_stage_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("prefix_adder_tb_prefix_adder_stage_smoke.vcd");
        $dumpvars(0, tb_prefix_adder_stage_smoke);
    end

endmodule
