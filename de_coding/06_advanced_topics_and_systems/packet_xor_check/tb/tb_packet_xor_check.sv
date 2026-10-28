`timescale 1ns/1ps
module tb_packet_xor_check;
    reg clk=0,rst_n=0,in_valid=0,in_start=0,in_last=0;
    reg [7:0] in_data=0;
    wire packet_done,overflow;
    wire [7:0] checksum,length;
    integer tests=0,k,t;
    reg ref_active=0;
    reg [7:0] ref_xor=0,ref_count=0,ref_sum=0,ref_len=0;
    reg ref_done=0,ref_overflow=0;
    always #5 clk=~clk;
    packet_xor_check #(.MAX_LEN(8)) dut (
        .clk(clk),.rst_n(rst_n),.in_valid(in_valid),
        .in_start(in_start),.in_last(in_last),.in_data(in_data),
        .packet_done(packet_done),.checksum(checksum),
        .length(length),.overflow(overflow));
`ifdef GATE_SDF
    initial $sdf_annotate("Syn_packet_xor_check.sdf",dut);
`endif
`ifdef VCS_VPD
    initial begin $vcdplusfile("inter.vpd"); $vcdpluson(0,tb_packet_xor_check); end
`else
    initial begin $dumpfile("mock7.vcd"); $dumpvars(0,tb_packet_xor_check); end
`endif
    task automatic reset_reference;
        begin
            ref_active=0;ref_xor=0;ref_count=0;
            ref_done=0;ref_sum=0;ref_len=0;ref_overflow=0;
        end
    endtask
    task automatic check;
        begin
            if(packet_done !== ref_done || checksum !== ref_sum ||
               length !== ref_len || overflow !== ref_overflow)
                $fatal(1,"Mock7 mismatch done %b/%b xor %h/%h len %d/%d over %b/%b",
                       packet_done,ref_done,checksum,ref_sum,length,ref_len,overflow,ref_overflow);
            tests=tests+1;
        end
    endtask
    task automatic beat(input reg v,input reg s,input reg l,input [7:0] data_byte);
        begin
            @(negedge clk);in_valid=v;in_start=s;in_last=l;in_data=data_byte;
            @(posedge clk);
            ref_done=0;
            if(v) begin
                if(s) begin
                    ref_active=!l;
                    ref_xor=data_byte;
                    ref_count=1;
                    if(l) begin
                        ref_done=1;ref_sum=data_byte;
                        ref_len=1;ref_overflow=0;
                    end
                end else if(ref_active) begin
                    ref_xor=ref_xor ^ data_byte;
                    if(ref_count<9) ref_count=ref_count+1;
                    if(l) begin
                        ref_done=1;ref_active=0;ref_sum=ref_xor;
                        ref_len=ref_count;ref_overflow=(ref_count>8);
                    end
                end
            end
            #1;check();
        end
    endtask
    initial begin
        repeat(2) @(negedge clk);rst_n=1;reset_reference();check();
        beat(1,0,1,8'hAA); // ignored without start
        beat(1,1,1,8'hF0); // one-beat packet
        beat(0,0,0,8'h00);
        beat(1,1,0,8'h11);
        beat(1,0,0,8'h22);
        beat(0,0,0,8'h00); // bubble in stream
        beat(1,0,0,8'h33);
        beat(1,0,1,8'h44); // 4-beat packet
        // 10 beats: count saturates at 9 and overflow asserts.
        for(k=0;k<10;k=k+1) beat(1,k==0,k==9,k);
        // New start aborts prior frame.
        beat(1,1,0,8'hAA);
        beat(1,0,0,8'hBB);
        beat(1,1,1,8'hCC);
        for(t=0;t<40;t=t+1) begin
            k=$urandom_range(1,12);
            for(integer j=0;j<k;j=j+1) begin
                beat(1,j==0,j==k-1,$urandom_range(0,255));
                if($urandom_range(0,1)) beat(0,0,0,0);
            end
        end
        @(negedge clk);rst_n=0;in_valid=0;reset_reference();
        #1;check();
        @(negedge clk);rst_n=1;
        beat(1,1,1,8'h5A);
        $display("PASS Mock7 packet_xor_check checks=%0d",tests);
        $finish;
    end
    initial begin #100000; $fatal(1,"Mock7 timeout"); end
endmodule
