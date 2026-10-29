`timescale 1ns/1ps
module tb_sync_fifo8;
  reg clk=0,rst_n=0,w_en=0,r_en=0;reg [7:0] wdata=0;
  wire w_ready,r_valid,full,empty;wire [7:0] rdata;wire [3:0] count;
  reg [7:0] model[0:2047];integer rd=0,wr=0,used=0,checks=0,k;
  reg exp_push,exp_pop;reg [7:0] exp_data;reg [31:0] rng=32'h813475ac;
  sync_fifo8 dut(.*);always #5 clk=~clk;
  task automatic drive(input reg we,input reg re,input reg [7:0] d);
    begin
      @(negedge clk);w_en=we;r_en=re;wdata=d;
      exp_pop = re && (used!=0);
      exp_push = we && ((used<8)||exp_pop);
      exp_data=(used>0)?model[rd]:0;
      #1;
      if(w_ready!==((used<8)||exp_pop) || r_valid!==(used>0) ||
         full!==(used==8) || empty!==(used==0) || rdata!==exp_data)
        $fatal(1,"fifo combinational mismatch check=%0d",checks);
      if(exp_pop && rdata!==model[rd]) $fatal(1,"FIFO data mismatch");
      @(posedge clk);
      if(exp_push) begin model[wr]=d;wr=wr+1;end
      if(exp_pop) rd=rd+1;
      used=used+(exp_push?1:0)-(exp_pop?1:0);
      #1; checks=checks+1;
      if(count!==used || full!==(used==8) || empty!==(used==0))
        $fatal(1,"fifo occupancy mismatch check=%0d",checks);
    end
  endtask
  initial begin
    repeat(2)@(posedge clk);#1;
    if(count!==0||!empty)$fatal(1,"fifo reset");
    @(negedge clk);rst_n=1;
    drive(1,1,8'h3a); // empty simultaneous => write only
    for(k=0;k<7;k=k+1)drive(1,0,k);
    for(k=0;k<10;k=k+1)drive(1,1,8'h80+k); // full read+write
    for(k=0;k<8;k=k+1)drive(0,1,0);
    drive(0,1,0); // empty pop rejected
    // random, keep model buffer below 2048 entries
    for(k=0;k<450;k=k+1)begin
       rng=rng*32'd1664525+32'd1013904223;
       drive(rng[0],rng[3],rng[15:8]);
    end
    $display("PASS ALL FIFO checks=%0d",checks);$finish;
  end
  initial begin #100000;$fatal(1,"TIMEOUT");end

`ifdef GATE_SDF
  initial $sdf_annotate("Syn_sync_fifo8.sdf", dut);
`endif
  initial begin
`ifdef VCS_VPD
    $vcdplusfile("inter.vpd");
    $vcdpluson(0, tb_sync_fifo8);
`else
    $dumpfile("sync_fifo8_rtl.vcd");
    $dumpvars(0, tb_sync_fifo8);
`endif
  end

endmodule
