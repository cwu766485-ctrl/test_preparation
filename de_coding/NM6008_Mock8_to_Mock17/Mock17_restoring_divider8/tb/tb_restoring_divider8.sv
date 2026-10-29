`timescale 1ns/1ps
module tb_restoring_divider8;
  reg clk=0,rst_n=0,start=0;reg [7:0] dividend=0,divisor=0;
  wire [7:0] quotient,remainder;wire busy,done,div_by_zero;
  integer checks=0,k,n;reg [31:0] rng=32'h756ac104;
  restoring_divider8 dut(.*);always #5 clk=~clk;
  task automatic test(input reg [7:0] a,input reg [7:0] b);
    begin
      @(negedge clk);start=1;dividend=a;divisor=b;
      @(posedge clk);#1;checks=checks+1;
      if(b==0)begin
        if(busy||!done||!div_by_zero||quotient!==255||remainder!==a)
          $fatal(1,"div0 mismatch");
      end else begin
        if(!busy||done||div_by_zero)$fatal(1,"divider start");
        for(k=0;k<8;k=k+1)begin
          // disturbance must not affect internal held operands
          dividend=~a;divisor=~b;start=(k==3);
          @(posedge clk);#1;checks=checks+1;
          if(busy!==(k!=7)||done!==(k==7))
            $fatal(1,"divider latency k=%0d",k);
          @(negedge clk);start=0;
        end
        if(quotient!==(a/b)||remainder!==(a%b))
          $fatal(1,"divider math %0d/%0d -> %0d rem%0d",a,b,quotient,remainder);
      end
      @(negedge clk);start=0;
      @(posedge clk);#1;
      if(done)$fatal(1,"divider done pulse");
    end
  endtask
  initial begin
    repeat(2)@(posedge clk);#1;
    if(busy||done||quotient!==0||remainder!==0)$fatal(1,"reset");
    @(negedge clk);rst_n=1;
    test(255,1);test(255,255);test(0,7);test(255,0);
    test(13,5);test(250,3);test(3,12);
    for(n=0;n<140;n=n+1)begin
      rng=rng*32'd1664525+32'd1013904223;
      test(rng[7:0],rng[23:16]);
    end
    $display("PASS ALL divider checks=%0d",checks);$finish;
  end
  initial begin #100000;$fatal(1,"TIMEOUT");end

`ifdef GATE_SDF
  initial $sdf_annotate("Syn_restoring_divider8.sdf", dut);
`endif
  initial begin
`ifdef VCS_VPD
    $vcdplusfile("inter.vpd");
    $vcdpluson(0, tb_restoring_divider8);
`else
    $dumpfile("restoring_divider8_rtl.vcd");
    $dumpvars(0, tb_restoring_divider8);
`endif
  end

endmodule
