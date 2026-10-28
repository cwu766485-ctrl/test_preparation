`timescale 1ns/1ps

module tb_top;
    import uvm_pkg::*;
    import adder_pkg::*;

    logic clk = 1'b0;
    always #5 clk = ~clk;

    adder_if vif(clk);

    half_adder u_half_adder (
        .a    (vif.a),
        .b    (vif.b),
        .sum  (vif.half_sum),
        .cout (vif.half_cout)
    );

    full_adder u_full_adder (
        .a    (vif.a),
        .b    (vif.b),
        .cin  (vif.cin),
        .sum  (vif.full_sum),
        .cout (vif.full_cout)
    );

    initial begin
        uvm_config_db #(virtual adder_if)::set(null, "*", "vif", vif);
        run_test("adder_test");
    end

    initial begin
        $dumpfile("adder.vcd");
        $dumpvars(0, tb_top);
    end
endmodule
