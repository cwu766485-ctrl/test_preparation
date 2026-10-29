`timescale 1ns/1ps
module tb_pulse_width_meter8;
  reg clk=0,rst_n=0,arm=0,signal_in=0;
  wire [7:0] width;wire busy,done,overflow;
  integer checks=0,n,k;
  pulse_width_meter8 dut(.*);always #5 clk=~clk;
  task automatic measure(input integer high_clks);
    begin
      @(negedge clk);arm=1;signal_in=1;
      for(k=0;k<high_clks;k=k+1)begin
        @(posedge clk);#1;checks=checks+1;
        if(!busy || done || overflow!==(k>=255))
          $fatal(1,"meter busy count mismatch sample %0d",k);
        @(negedge clk);arm=0;
      end
      signal_in=0;
      @(posedge clk);#1;
      if(busy||!done||width!==((high_clks>255)?255:high_clks)
         ||overflow!==(high_clks>255))
         $fatal(1,"pulse width result width=%0d n=%0d",width,high_clks);
      @(posedge clk);#1;if(done)$fatal(1,"done pulse");
    end
  endtask
  initial begin
    repeat(2)@(posedge clk);#1;
    if(busy||done||width!==0)$fatal(1,"reset");
    @(negedge clk);rst_n=1;
    measure(1);measure(8);measure(255);measure(256);measure(300);measure(2);
    $display("PASS ALL pulse-width checks=%0d",checks);$finish;
  end
  initial begin #100000;$fatal(1,"TIMEOUT");end

`ifdef GATE_SDF
  initial $sdf_annotate("Syn_pulse_width_meter8.sdf", dut);
`endif
  initial begin
`ifdef VCS_VPD
    $vcdplusfile("inter.vpd");
    $vcdpluson(0, tb_pulse_width_meter8);
`else
    $dumpfile("pulse_width_meter8_rtl.vcd");
    $dumpvars(0, tb_pulse_width_meter8);
`endif
  end

endmodule
