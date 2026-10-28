`timescale 1ns/1ps

module tb_sync_fifo;
    localparam int W = 8;
    localparam int D = 16;

    logic clk = 1'b0;
    always #5 clk = ~clk;  // 10 ns clock period

    logic rst_n = 1'b1;
    logic wr_en = 1'b0;
    logic rd_en = 1'b0;
    logic [W-1:0] wdata = '0;
    wire  [W-1:0] rdata;
    wire  full, empty;

    sync_fifo #(.W(W), .D(D)) dut (
        .clk(clk), .rst_n(rst_n),
        .wr_en(wr_en), .rd_en(rd_en),
        .wdata(wdata), .rdata(rdata),
        .full(full), .empty(empty)
    );

    // Reference model: oldest data at the head of the queue.
    logic [W-1:0] expected_q[$];
    int cycles = 0;

    task automatic reset_dut;
        @(negedge clk);
        rst_n = 1'b0;
        wr_en = 1'b0;
        rd_en = 1'b0;
        wdata = '0;
        expected_q.delete();
        repeat (2) @(posedge clk);
        #1; // observe values after the DUT's nonblocking assignments
        if (empty !== 1'b1 || full !== 1'b0 || rdata !== '0)
            $fatal(1, "RESET FAIL: empty=%b full=%b rdata=%h",
                   empty, full, rdata);
        @(negedge clk);
        rst_n = 1'b1;
        $display("RESET PASS");
    endtask

    // One DUT clock cycle: drive on negedge, sample after next posedge.
    task automatic step(input bit we, input bit re,
                        input logic [W-1:0] din);
        bit accepted_write, accepted_read;
        logic [W-1:0] expected_data, previous_rdata;
        int old_count, new_count;

        @(negedge clk);
        wr_en = we;
        rd_en = re;
        wdata = din;

        old_count = expected_q.size();
        previous_rdata = rdata;
        accepted_write = we && (old_count < D);
        accepted_read  = re && (old_count > 0);

        // IMPORTANT: read the oldest item BEFORE adding any new item.
        // Full + read/write: read only. Empty + read/write: write only.
        if (accepted_read)
            expected_data = expected_q.pop_front();
        if (accepted_write)
            expected_q.push_back(din);

        @(posedge clk);
        #1;
        cycles++;
        new_count = expected_q.size();

        if (accepted_read && rdata !== expected_data)
            $fatal(1, "DATA FAIL @cycle=%0d exp=%h got=%h",
                   cycles, expected_data, rdata);
        if (!accepted_read && rdata !== previous_rdata)
            $fatal(1, "RDATA HOLD FAIL @cycle=%0d old=%h got=%h",
                   cycles, previous_rdata, rdata);
        if (full !== (new_count == D))
            $fatal(1, "FULL FAIL @cycle=%0d occupancy=%0d full=%b",
                   cycles, new_count, full);
        if (empty !== (new_count == 0))
            $fatal(1, "EMPTY FAIL @cycle=%0d occupancy=%0d empty=%b",
                   cycles, new_count, empty);

        $display("PASS cycle=%0d wr=%b rd=%b wr_ok=%b rd_ok=%b occupancy=%0d data=%h",
                 cycles, we, re, accepted_write, accepted_read, new_count, rdata);
    endtask

    initial begin
        if ($test$plusargs("WAVES")) begin
            $dumpfile("fifo.vcd");
            $dumpvars(0, tb_sync_fifo);
        end

        reset_dut();
        step(0, 1, 8'h00);  // Empty: invalid read
        step(1, 1, 8'hE0);  // Empty: simultaneous requests => write only
        step(0, 1, 8'h00);  // Read E0

        step(1, 0, 8'hA1);
        step(1, 0, 8'hB2);
        step(1, 1, 8'hC3);  // Normal: both accepted, reads A1
        step(0, 1, 8'h00);  // Read B2
        step(0, 1, 8'h00);  // Read C3

        for (int i = 0; i < D; i++)
            step(1, 0, W'(i));
        step(1, 0, 8'hFE);  // Full: reject write
        step(1, 1, 8'hFC);  // Full: read only
        step(1, 1, 8'hDD);  // Normal: both accepted
        for (int i = 0; i < D-1; i++)
            step(0, 1, '0);

        for (int i = 0; i < 3*D; i++) begin
            step(1, 0, W'(i + 8'h40));  // Cross pointer wraparound
            step(0, 1, '0);
        end

        for (int i = 0; i < 100; i++)
            step($urandom_range(0, 1), $urandom_range(0, 1),
                 W'($urandom));

        reset_dut();           // Reset in the middle of arbitrary traffic
        step(1, 0, 8'h5A);
        step(0, 1, '0);
        $display("FIFO ALL TESTS PASSED, checked %0d cycles", cycles);
        $finish;
    end
endmodule