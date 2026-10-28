`timescale 1ns/1ps
module tb_rr_arbiter4_hold;
    reg clk=0, rst_n=0, ready=0;
    reg [3:0] req=0;
    wire [3:0] grant;
    wire grant_valid;
    integer pointer=0, tests=0, k, winner;
    reg holding=0;
    reg [3:0] held=0;
    reg [3:0] expected_grant;
    always #5 clk=~clk;
    rr_arbiter4_hold dut(.clk(clk),.rst_n(rst_n),.req(req),.ready(ready),
                         .grant(grant),.grant_valid(grant_valid));
`ifdef GATE_SDF
    initial $sdf_annotate("Syn_rr_arbiter4_hold.sdf", dut);
`endif
`ifdef VCS_VPD
    initial begin $vcdplusfile("inter.vpd"); $vcdpluson(0,tb_rr_arbiter4_hold); end
`else
    initial begin $dumpfile("mock6.vcd"); $dumpvars(0,tb_rr_arbiter4_hold); end
`endif

    task automatic calculate_grant;
        integer x, pos;
        begin
            expected_grant=0;
            if(holding) expected_grant=held;
            else for(x=0;x<4;x=x+1) begin
                pos=(pointer+x)%4;
                if(req[pos] && expected_grant==0) expected_grant[pos]=1;
            end
        end
    endtask
    task automatic cycle(input [3:0] request_mask, input reg accept);
        integer g;
        begin
            @(negedge clk);req=request_mask;ready=accept;
            #1;calculate_grant();
            if(grant !== expected_grant || grant_valid !== (|expected_grant))
                $fatal(1,"Mock6 combinational mismatch req=%b exp=%b got=%b", req,expected_grant,grant);
            if(grant!=0 && (grant & (grant-1))!=0)
                $fatal(1,"Mock6 multi-hot grant");
            @(posedge clk);
            if(expected_grant!=0) begin
                if(accept) begin
                    for(g=0;g<4;g=g+1)
                        if(expected_grant[g]) pointer=(g+1)%4;
                    holding=0;
                end else if(!holding) begin
                    holding=1;held=expected_grant;
                end
            end
            #1;calculate_grant();
            if(grant !== expected_grant || grant_valid !== (|expected_grant))
                $fatal(1,"Mock6 registered-state mismatch");
            tests=tests+1;
        end
    endtask
    initial begin
        repeat(2) @(negedge clk);rst_n=1;
        cycle(4'b0000,1);
        // All request continuously: deterministic rotation 0,1,2,3,0...
        for(k=0;k<12;k=k+1) cycle(4'b1111,1);
        // Lock a grant on stall, withdraw request, and then release.
        cycle(4'b0101,0);
        cycle(4'b0000,0);
        cycle(4'b1010,0);
        cycle(4'b0000,1);
        for(k=0;k<250;k=k+1) cycle($urandom_range(0,15),$urandom_range(0,1));
        @(negedge clk);rst_n=0;req=0;ready=0;pointer=0;holding=0;held=0;
        #1;calculate_grant();
        if(grant !== 0 || grant_valid !== 0) $fatal(1,"Mock6 async reset");
        @(negedge clk);rst_n=1;
        cycle(4'b1111,1);
        $display("PASS Mock6 rr_arbiter4_hold checks=%0d",tests);
        $finish;
    end
    initial begin #100000; $fatal(1,"Mock6 timeout"); end
endmodule
