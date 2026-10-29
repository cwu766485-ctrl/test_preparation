`timescale 1ns/1ps
module tb_pwm_generator8;
  reg clk=0,rst_n=0,enable=0,config=0;
  reg [7:0] period_in=0,duty_in=0;
  wire [7:0] count,active_period,active_duty;wire pwm;
  integer ec=0,ep=4,ed=2,checks=0,k;reg [31:0] rng=32'h3141abcd;
  pwm_generator8 dut(.*);always #5 clk=~clk;
  task automatic cycle(input reg en,input reg cfg,input reg [7:0] p,input reg [7:0] d);
    begin
      @(negedge clk);enable=en;config=cfg;period_in=p;duty_in=d;
      if(cfg)begin ep=p==0?1:p;ed=d>ep?ep:d;ec=0;end
      else if(en)ec=(ec+1)%ep;
      @(posedge clk);#1;checks=checks+1;
      if(count!==ec || active_period!==ep || active_duty!==ed || pwm!==(ec<ed))
         $fatal(1,"PWM mismatch at check=%0d",checks);
    end
  endtask
  initial begin
    repeat(2)@(posedge clk);#1;
    if(count!==0 || pwm!==1) $fatal(1,"reset");
    @(negedge clk);rst_n=1;
    for(k=0;k<20;k=k+1)cycle(1,0,0,0);
    cycle(1,1,7,0);for(k=0;k<15;k=k+1)cycle(1,0,0,0);
    cycle(1,1,7,7);for(k=0;k<15;k=k+1)cycle(1,0,0,0);
    cycle(0,1,0,255);for(k=0;k<5;k=k+1)cycle(1,0,0,0);
    for(k=0;k<250;k=k+1)begin
      rng=rng*32'd1664525+32'd1013904223;
      cycle(rng[6],(k%31)==0,rng[15:8],rng[23:16]);
    end
    $display("PASS ALL PWM checks=%0d",checks);$finish;
  end
  initial begin #100000;$fatal(1,"TIMEOUT");end

`ifdef GATE_SDF
  initial $sdf_annotate("Syn_pwm_generator8.sdf", dut);
`endif
  initial begin
`ifdef VCS_VPD
    $vcdplusfile("inter.vpd");
    $vcdpluson(0, tb_pwm_generator8);
`else
    $dumpfile("pwm_generator8_rtl.vcd");
    $dumpvars(0, tb_pwm_generator8);
`endif
  end

endmodule
