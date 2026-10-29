`timescale 1ns/1ps
module tb_bcd_stopwatch;
  reg clk=0,rst_n=0,clear=0,enable=0,tick_in=0;
  wire [3:0] tens,ones;wire wrap;
  integer reference=0,checks=0,k;reg ew;
  bcd_stopwatch dut(.*);always #5 clk=~clk;
  task automatic cycle(input reg cl,input reg en,input reg t);
    begin
      @(negedge clk);clear=cl;enable=en;tick_in=t;ew=0;
      if(cl)reference=0;
      else if(en&&t)begin
        if(reference==99)begin reference=0;ew=1;end
        else reference=reference+1;
      end
      @(posedge clk);#1;checks=checks+1;
      if(tens !== reference/10 || ones !== reference%10 || wrap!==ew)
        $fatal(1,"BCD failure expected %0d got %0d%0d",reference,tens,ones);
    end
  endtask
  initial begin
    repeat(2) @(posedge clk);#1;
    if(tens!==0||ones!==0||wrap!==0)$fatal(1,"reset");
    @(negedge clk);rst_n=1;
    for(k=0;k<215;k=k+1)cycle(0,1,1);
    for(k=0;k<10;k=k+1)cycle(0,0,1);
    for(k=0;k<10;k=k+1)cycle(0,1,0);
    cycle(1,1,1);
    for(k=0;k<105;k=k+1)cycle(0,1,1);
    $display("PASS ALL BCD checks=%0d",checks);$finish;
  end
  initial begin #100000;$fatal(1,"TIMEOUT");end

`ifdef GATE_SDF
  initial $sdf_annotate("Syn_bcd_stopwatch.sdf", dut);
`endif
  initial begin
`ifdef VCS_VPD
    $vcdplusfile("inter.vpd");
    $vcdpluson(0, tb_bcd_stopwatch);
`else
    $dumpfile("bcd_stopwatch_rtl.vcd");
    $dumpvars(0, tb_bcd_stopwatch);
`endif
  end

endmodule
