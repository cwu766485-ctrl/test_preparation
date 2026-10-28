`timescale 1ns/1ps
// NM6008 Mock Test 2: variable-length, unsigned serial adder.
// Single source: synthesizable RTL + self-checking RTL/gate-level testbench.
//
// Contract (the original exam statement is not available):
//   * MAX_WIDTH=16. n_in=1..15 selects that many LSBs;
//     n_in=0 encodes 16 bits because a 4-bit field cannot encode 16.
//   * On a rising edge with start=1 in IDLE, operands and n_in are latched.
//   * One LSB is added at each of the next N rising edges.
//   * done pulses on the Nth calculation edge. sum_out is right-aligned;
//     c contains the carry out of bit N-1. Outputs hold until next start.
//   * start is ignored in CALC. rst is asynchronous, active high.
//
// RTL simulation (NTU VCS):
//   vcs -full64 -sverilog -top tb_mock2_serial_adder \
//       tb/mock2_nbit_serial_adder_all.sv -o simv_mock2
//   ./simv_mock2
// Gate-level (substitute the actual netlist / library.f as needed):
//   vcs -full64 -sverilog +define+GATE_LEVEL -top tb_mock2_serial_adder \
//       tb/mock2_nbit_serial_adder_all.sv Syn_nbit_serial_adder.v \
//       -f ./library.f -o simv_mock2_gate
//   ./simv_mock2_gate
// To annotate matched SDF also add +define+GATE_SDF; adjust path below.
// For synthesis, set top nbit_serial_adder; testbench is excluded by
// `SYNTHESIS` and Synopsys translate_off guards.

`ifndef GATE_LEVEL
module nbit_serial_adder #(
    parameter integer MAX_WIDTH = 16
) (
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 start,
    input  wire [MAX_WIDTH-1:0] a_in,
    input  wire [MAX_WIDTH-1:0] b_in,
    input  wire [3:0]           n_in,
    output reg  [MAX_WIDTH-1:0] sum_out,
    output reg                  c,
    output reg                  done
);
    localparam IDLE = 1'b0;
    localparam CALC = 1'b1;

    reg state;
    reg [MAX_WIDTH-1:0] a_shift, b_shift;
    reg carry_ff;
    reg [4:0] bit_index;
    reg [4:0] n_reg;

    wire sum_bit = a_shift[0] ^ b_shift[0] ^ carry_ff;
    wire carry_next = (a_shift[0] & b_shift[0]) |
                      (a_shift[0] & carry_ff) |
                      (b_shift[0] & carry_ff);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            a_shift   <= {MAX_WIDTH{1'b0}};
            b_shift   <= {MAX_WIDTH{1'b0}};
            carry_ff  <= 1'b0;
            bit_index <= 5'd0;
            n_reg     <= 5'd0;
            sum_out   <= {MAX_WIDTH{1'b0}};
            c         <= 1'b0;
            done      <= 1'b0;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    if (start) begin
                        a_shift   <= a_in;
                        b_shift   <= b_in;
                        n_reg     <= (n_in == 4'd0) ? 5'd16 : {1'b0, n_in};
                        carry_ff  <= 1'b0;
                        bit_index <= 5'd0;
                        sum_out   <= {MAX_WIDTH{1'b0}};
                        c         <= 1'b0;
                        state     <= CALC;
                    end
                end
                CALC: begin
                    sum_out[bit_index] <= sum_bit;
                    carry_ff          <= carry_next;
                    a_shift           <= a_shift >> 1;
                    b_shift           <= b_shift >> 1;
                    if (bit_index == n_reg - 5'd1) begin
                        c     <= carry_next;
                        done  <= 1'b1;
                        state <= IDLE;
                    end else begin
                        bit_index <= bit_index + 5'd1;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
`endif

// synopsys translate_off
`ifndef SYNTHESIS
module tb_mock2_serial_adder;
    localparam integer MAX_WIDTH = 16;
    reg clk;
    reg rst;
    reg start;
    reg [15:0] a_in, b_in;
    reg [3:0] n_in;
    wire [15:0] sum_out;
    wire c, done;

    integer pass_count;
    integer width_num, k, j;
    reg [3:0] encoded_width;
    reg [31:0] prng;
    reg [15:0] random_a, random_b;

    nbit_serial_adder dut (
        .clk(clk), .rst(rst), .start(start),
        .a_in(a_in), .b_in(b_in), .n_in(n_in),
        .sum_out(sum_out), .c(c), .done(done)
    );

    always #5 clk = ~clk;

    initial begin
`ifdef VCS_VPD
        $vcdplusfile("mock2_serial_adder.vpd");
        $vcdpluson(0, tb_mock2_serial_adder);
`else
        $dumpfile("mock2_serial_adder.vcd");
        $dumpvars(0, tb_mock2_serial_adder);
`endif
    end

`ifdef GATE_SDF
    initial $sdf_annotate("Syn_nbit_serial_adder.sdf", dut);
`endif

    task automatic run_case(
        input [15:0] aa,
        input [15:0] bb,
        input [3:0]  nn
    );
        integer nbits, cycle;
        reg [16:0] mask;
        reg [16:0] expected;
        begin
            nbits = (nn == 4'd0) ? 16 : nn;
            mask = (17'd1 << nbits) - 17'd1;
            expected = ({1'b0, aa} & mask) + ({1'b0, bb} & mask);

            @(negedge clk);
            a_in = aa;
            b_in = bb;
            n_in = nn;
            start = 1'b1;
            @(posedge clk); #1;
            if (done !== 1'b0 || sum_out !== 16'd0 || c !== 1'b0)
                $fatal(1, "START fail: a=%h b=%h n=%0d", aa, bb, nbits);

            @(negedge clk);
            start = 1'b0;
            // Inputs must be latched at start, not re-read while calculating.
            a_in = ~aa;
            b_in = ~bb;
            n_in = (nn == 4'd1) ? 4'd2 : 4'd1;

            for (cycle = 1; cycle <= nbits; cycle = cycle + 1) begin
                @(posedge clk); #1;
                if (cycle < nbits && done !== 1'b0)
                    $fatal(1, "EARLY done: n=%0d cycle=%0d", nbits, cycle);
                if (cycle == nbits) begin
                    if (done !== 1'b1)
                        $fatal(1, "MISSING done: n=%0d", nbits);
                    if (sum_out !== expected[15:0] || c !== expected[nbits])
                        $fatal(1, "SUM FAIL n=%0d a=%h b=%h got=%h carry=%b expected=%h carry=%b",
                               nbits, aa, bb, sum_out, c,
                               expected[15:0], expected[nbits]);
                end
            end

            @(posedge clk); #1;
            if (done !== 1'b0 || sum_out !== expected[15:0] ||
                c !== expected[nbits])
                $fatal(1, "DONE pulse/result hold failed n=%0d", nbits);
            pass_count = pass_count + 1;
        end
    endtask

    task automatic test_busy_start;
        integer cycle;
        begin
            // 8-bit: 0xF0 + 0x0F = 0xFF, no carry.
            @(negedge clk);
            start = 1'b1;
            a_in = 16'h00F0;
            b_in = 16'h000F;
            n_in = 4'd8;
            @(posedge clk); #1;
            for (cycle = 1; cycle <= 8; cycle = cycle + 1) begin
                @(negedge clk);
                start = (cycle == 3);
                a_in = 16'hFFFF;
                b_in = 16'hFFFF;
                n_in = 4'd1;
                @(posedge clk); #1;
                if (cycle < 8 && done !== 1'b0)
                    $fatal(1, "busy start caused early done");
            end
            if (done !== 1'b1 || sum_out !== 16'h00FF || c !== 1'b0)
                $fatal(1, "busy start corrupted the active transaction");
            @(negedge clk); start = 1'b0;
            @(posedge clk); #1;
            if (done !== 1'b0) $fatal(1, "done was not one cycle");
            pass_count = pass_count + 1;
        end
    endtask

    task automatic test_async_reset;
        integer cycle;
        begin
            @(negedge clk);
            a_in = 16'hFFFF;
            b_in = 16'h0001;
            n_in = 4'd8;
            start = 1'b1;
            @(posedge clk); #1;
            @(negedge clk); start = 1'b0;
            repeat (3) begin @(posedge clk); #1; end
            // Reset between clock edges; state must clear immediately.
            #1 rst = 1'b1;
            #1;
            if (done !== 1'b0 || sum_out !== 16'd0 || c !== 1'b0)
                $fatal(1, "asynchronous reset did not clear outputs");
            @(negedge clk); rst = 1'b0;
            for (cycle = 0; cycle < 3; cycle = cycle + 1) begin
                @(posedge clk); #1;
                if (done !== 1'b0 || sum_out !== 16'd0 || c !== 1'b0)
                    $fatal(1, "stale transaction after reset");
            end
            pass_count = pass_count + 1;
        end
    endtask

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        start = 1'b0;
        a_in = 16'd0;
        b_in = 16'd0;
        n_in = 4'd0;
        pass_count = 0;
        prng = 32'h1234ABCD;

        #2;
        if (sum_out !== 16'd0 || c !== 1'b0 || done !== 1'b0)
            $fatal(1, "power-on asynchronous reset failed");
        @(negedge clk); rst = 1'b0;

        // The known example on page 6 of the submitted mock report.
        run_case(16'd5, 16'd3, 4'd4);

        for (width_num = 1; width_num <= 16; width_num = width_num + 1) begin
            encoded_width = (width_num == 16) ? 4'd0 : width_num;
            run_case(16'h0000, 16'h0000, encoded_width);
            run_case(16'hFFFF, 16'h0001, encoded_width);
            run_case(16'hFFFF, 16'hFFFF, encoded_width);
            run_case(16'hAAAA, 16'h5555, encoded_width);
            run_case(16'h8000, 16'h8000, encoded_width);
            run_case(16'h1234, 16'h5678, encoded_width);
            for (k = 0; k < 24; k = k + 1) begin
                prng = prng * 32'd1664525 + 32'd1013904223;
                random_a = prng[15:0];
                prng = prng * 32'd1664525 + 32'd1013904223;
                random_b = prng[31:16];
                run_case(random_a, random_b, encoded_width);
            end
        end
        test_busy_start();
        test_async_reset();
        run_case(16'hFFFF, 16'h0001, 4'd0);

        $display("PASS: %0d serial-adder cases (n=1..16, carry, reset, busy-start, done pulse)", pass_count);
        $finish;
    end

    initial begin
        #5000000;
        $fatal(1, "TB GLOBAL TIMEOUT");
    end
endmodule
`endif
// synopsys translate_on
