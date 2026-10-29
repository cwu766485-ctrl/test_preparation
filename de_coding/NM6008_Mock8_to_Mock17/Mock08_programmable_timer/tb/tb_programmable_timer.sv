`timescale 1ns/1ps
module tb_programmable_timer;
  reg clk=0,rst_n=0,enable=0,load=0;
  reg [7:0] period_in=0;
  wire [7:0] count,active_period; wire tick;
  reg [7:0] exp_cnt=0,exp_period=4; reg exp_tick=0;
  integer checks=0,k; reg e;
  programmable_timer dut(.*);
  always #5 clk=~clk;
  task automatic cycle(input reg en, input reg ld, input reg [7:0] p);
    begin
      @(negedge clk); enable=en;load=ld;period_in=p;
      exp_tick=0;
      if(ld) begin exp_period=(p==0)?1:p; exp_cnt=0; end
      else if(en) begin
        if(exp_cnt == exp_period-1) begin exp_cnt=0;exp_tick=1;end
        else exp_cnt=exp_cnt+1;
      end
      @(posedge clk);#1; checks=checks+1;
      if(count !== exp_cnt || active_period !== exp_period || tick !== exp_tick)
        $fatal(1,"timer FAIL at check %0d",checks);
    end
  endtask
  initial begin
    repeat(2) @(posedge clk);#1;
    if(count !== 0 || active_period !== 4 || tick !== 0) $fatal(1,"reset");
    @(negedge clk); rst_n=1;
    for(k=0;k<11;k=k+1) cycle(1,0,0);
    cycle(0,1,0); for(k=0;k<3;k=k+1) cycle(1,0,0);
    cycle(0,1,3); for(k=0;k<7;k=k+1) cycle(1,0,0);
    for(k=0;k<5;k=k+1) cycle(0,0,0);
    cycle(1,1,255);
    for(k=0;k<300;k=k+1) cycle((k%7)!=0,0,0);
    $display("PASS ALL timer checks=%0d",checks);$finish;
  end
  initial begin #100000;$fatal(1,"TIMEOUT");end

`ifdef GATE_SDF
  initial $sdf_annotate("Syn_programmable_timer.sdf", dut);
`endif
  initial begin
`ifdef VCS_VPD
    $vcdplusfile("inter.vpd");
    $vcdpluson(0, tb_programmable_timer);
`else
    $dumpfile("programmable_timer_rtl.vcd");
    $dumpvars(0, tb_programmable_timer);
`endif
  end

endmodule
