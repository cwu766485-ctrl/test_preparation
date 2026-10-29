`timescale 1ns/1ps
module tb_overlap_detector;
  reg clk=0,rst_n=0,bit_valid=0,din=0;
  wire match;reg [3:0] reference=0;integer accepted=0,checks=0,k;
  reg expected;reg [31:0] rng=32'hf00dbabe;
  overlap_detector dut(.*);always #5 clk=~clk;
  task automatic push(input reg v,input reg b);
    begin
      @(negedge clk);bit_valid=v;din=b;
      expected=v && accepted>=3 && {reference[2:0],b}==4'b1101;
      if(v) begin reference={reference[2:0],b};accepted=accepted+1;end
      @(posedge clk);#1;checks=checks+1;
      if(match!==expected) $fatal(1,"detector error check=%0d",checks);
    end
  endtask
  initial begin
    repeat(2) @(posedge clk);#1;if(match!==0)$fatal(1,"reset");
    @(negedge clk);rst_n=1;
    // 1101101 contains overlapping matches at indices 3 and 6.
    push(1,1);push(1,1);push(1,0);push(1,1);
    push(0,0);push(0,1);
    push(1,1);push(1,0);push(1,1);
    @(negedge clk);rst_n=0;#1;if(match!==0)$fatal(1,"async reset");
    reference=0;accepted=0;
    @(negedge clk);rst_n=1;
    for(k=0;k<400;k=k+1) begin
      rng=rng*32'd1664525+32'd1013904223;
      push(rng[3:2]!=0,rng[9]);
    end
    $display("PASS ALL overlapping detector checks=%0d",checks);$finish;
  end
  initial begin #100000;$fatal(1,"TIMEOUT");end

`ifdef GATE_SDF
  initial $sdf_annotate("Syn_overlap_detector.sdf", dut);
`endif
  initial begin
`ifdef VCS_VPD
    $vcdplusfile("inter.vpd");
    $vcdpluson(0, tb_overlap_detector);
`else
    $dumpfile("overlap_detector_rtl.vcd");
    $dumpvars(0, tb_overlap_detector);
`endif
  end

endmodule
