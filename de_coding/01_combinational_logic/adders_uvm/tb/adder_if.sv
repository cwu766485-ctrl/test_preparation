interface adder_if(input logic clk);
    logic valid;
    logic a;
    logic b;
    logic cin;

    logic half_sum;
    logic half_cout;

    logic full_sum;
    logic full_cout;
endinterface
