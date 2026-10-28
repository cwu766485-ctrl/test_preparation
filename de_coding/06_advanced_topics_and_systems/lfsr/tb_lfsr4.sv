`timescale 1ns/1ps

module tb_lfsr4;
    logic clk = 1'b0;
    always #5 clk = ~clk;

    logic rst_n = 1'b1;
    logic en = 1'b0;
    wire [3:0] lfsr;

    lfsr4 dut (.clk(clk), .rst_n(rst_n), .en(en), .lfsr(lfsr));

    // Independent 15-state golden sequence, beginning from 4'b0001.
    logic [3:0] golden [0:14];
    logic [15:0] visited;

    task automatic reset_dut;
        @(negedge clk);
        rst_n = 1'b0;
        en = 1'b0;
        #1;
        if (lfsr !== 4'b0001)
            $fatal(1, "LFSR ASYNC RESET FAIL: got=%b", lfsr);
        @(posedge clk);
        #1;
        @(negedge clk);
        rst_n = 1'b1;
    endtask

    task automatic tick(input bit enable);
        logic [3:0] before_state;
        @(negedge clk);
        en = enable;
        before_state = lfsr;
        @(posedge clk);
        #1;
        if (!enable && lfsr !== before_state)
            $fatal(1, "ENABLE HOLD FAIL: prev=%b got=%b", before_state, lfsr);
        if (lfsr === 4'b0000)
            $fatal(1, "LFSR ENTERED ZERO STATE");
    endtask

    initial begin
        if ($test$plusargs("WAVES")) begin
            $dumpfile("lfsr4.vcd");
            $dumpvars(0, tb_lfsr4);
        end

        golden[0]=4'h1; golden[1]=4'h2; golden[2]=4'h4;
        golden[3]=4'h9; golden[4]=4'h3; golden[5]=4'h6;
        golden[6]=4'hD; golden[7]=4'hA; golden[8]=4'h5;
        golden[9]=4'hB; golden[10]=4'h7;golden[11]=4'hF;
        golden[12]=4'hE;golden[13]=4'hC;golden[14]=4'h8;

        reset_dut();
        visited = '0;
        for (int i = 0; i < 15; i++) begin
            if (lfsr !== golden[i])
                $fatal(1, "SEQUENCE FAIL step=%0d exp=%b got=%b",
                       i, golden[i], lfsr);
            if (visited[lfsr])
                $fatal(1, "STATE REPEATED TOO EARLY: %b", lfsr);
            visited[lfsr] = 1'b1;
            $display("PASS step=%0d state=%b", i, lfsr);
            tick(1'b1);
        end
        if (lfsr !== golden[0] || visited !== 16'hFFFE)
            $fatal(1, "PERIOD FAIL: state=%b visited=%h", lfsr, visited);

        repeat (4) tick(1'b0); // When disabled, state must hold.
        tick(1'b1);
        if (lfsr !== golden[1])
            $fatal(1, "RE-ENABLE FAIL: got=%b", lfsr);

        reset_dut();           // Asynchronous reset while running.
        tick(1'b1);
        if (lfsr !== golden[1])
            $fatal(1, "POST-RESET START FAIL");

        $display("LFSR4 ALL TESTS PASSED");
        $finish;
    end
endmodule
