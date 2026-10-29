`timescale 1ns/1ps
module tb_serial_comparator8;
  reg clk=0,rst_n=0,start=0,bit_valid=0,a_bit=0,b_bit=0;
  wire busy,done,gt,eq,lt;integer checks=0,k,n;
  reg [31:0] seed=32'h12345678;
  reg eg,el,ee;
  serial_comparator8 dut(.*);
  always #5 clk=~clk;
  task automatic check(input reg b,input reg d);
    begin #1;checks=checks+1;
      if(busy!==b||done!==d) $fatal(1,"serial cmp control fail case=%0d",checks);
    end
  endtask
  task automatic test(input reg [7:0] a,input reg [7:0] bb);
    begin
      @(negedge clk);start=1;bit_valid=0;
      @(posedge clk);check(1,0);
      @(negedge clk);start=0;
      for(k=7;k>=0;k=k-1) begin
        if((k%3)==0) begin
          bit_valid=0; @(posedge clk);check(1,0); @(negedge clk);
        end
        bit_valid=1;a_bit=a[k];b_bit=bb[k];start=(k==4);
        @(posedge clk);check(k!=0,k==0); @(negedge clk);
        start=0;bit_valid=0;
      end
      eg=a>bb;el=a<bb;ee=a==bb;
      if(gt!==eg||lt!==el||eq!==ee||!(gt^lt^eq)) $fatal(1,"cmp result %h %h",a,bb);
      @(posedge clk);check(0,0);
    end
  endtask
  initial begin
    repeat(2) @(posedge clk);#1;
    if(!eq||gt||lt||busy||done) $fatal(1,"cmp reset");
    @(negedge clk);rst_n=1;
    test(8'h00,8'h00);test(8'h00,8'hff);test(8'hff,8'h00);
    test(8'h80,8'h7f);test(8'h55,8'h55);test(8'h7f,8'h80);
    for(n=0;n<75;n=n+1) begin
      seed=seed*32'd1664525+32'd1013904223;
      test(seed[7:0],seed[15:8]);
    end
    $display("PASS ALL serial comparator checks=%0d",checks);$finish;
  end
  initial begin #100000;$fatal(1,"TIMEOUT");end

`ifdef GATE_SDF
  initial $sdf_annotate("Syn_serial_comparator8.sdf", dut);
`endif
  initial begin
`ifdef VCS_VPD
    $vcdplusfile("inter.vpd");
    $vcdpluson(0, tb_serial_comparator8);
`else
    $dumpfile("serial_comparator8_rtl.vcd");
    $dumpvars(0, tb_serial_comparator8);
`endif
  end

endmodule
