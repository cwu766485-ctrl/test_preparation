`timescale 1ns/1ps
module tb_crc8_stream;
  reg clk=0,rst_n=0,start=0,valid=0,last=0;
  reg [7:0] data=0;wire [7:0] crc;wire busy,done;
  integer checks=0,k,n;reg [7:0] model=0;
  reg [31:0] rng=32'h1234ffaa;
  reg [7:0] msg[0:8];
  crc8_stream dut(.*);always #5 clk=~clk;
  // independent reference processes bits MSB first through a shift register
  function automatic [7:0] reference_byte(input [7:0] prev,input [7:0] d);
    reg [7:0] r;integer i;
    begin
      r=prev;
      for(i=7;i>=0;i=i-1)begin
        if(r[7]^d[i])r={r[6:0],1'b0}^8'h07;
        else r={r[6:0],1'b0};
      end
      reference_byte=r;
    end
  endfunction
  task automatic start_frame;
    begin
      @(negedge clk);start=1;valid=0;last=0;
      @(posedge clk);#1;
      if(!busy||done||crc!==0)$fatal(1,"CRC start");
      model=0;@(negedge clk);start=0;
    end
  endtask
  task automatic byte_step(input reg [7:0] d,input reg v,input reg l);
    begin
      data=d;valid=v;last=l;start=0;
      if(v)model=reference_byte(model,d);
      @(posedge clk);#1;checks=checks+1;
      if(crc!==model || busy!==( !(v&&l)) || done!==(v&&l))
        $fatal(1,"CRC failure check=%0d exp=%h got=%h",checks,model,crc);
      @(negedge clk);
    end
  endtask
  initial begin
    msg[0]="1";msg[1]="2";msg[2]="3";msg[3]="4";msg[4]="5";
    msg[5]="6";msg[6]="7";msg[7]="8";msg[8]="9";
    repeat(2)@(posedge clk);#1;
    if(crc!==0||busy||done)$fatal(1,"CRC reset");
    @(negedge clk);rst_n=1;
    start_frame();
    for(k=0;k<9;k=k+1)begin
      if(k==3)byte_step(8'h11,0,1); // invalid last ignored
      byte_step(msg[k],1,k==8);
    end
    if(crc!==8'hf4)$fatal(1,"CRC check vector mismatch");
    @(posedge clk);#1;if(done)$fatal(1,"done not pulsed");
    for(n=0;n<50;n=n+1)begin
      start_frame();
      rng=rng*32'd1664525+32'd1013904223;
      byte_step(rng[15:8],1,0);
      byte_step(8'hff,0,0);
      byte_step(rng[7:0],1,1);
    end
    $display("PASS ALL CRC checks=%0d",checks);$finish;
  end
  initial begin #100000;$fatal(1,"TIMEOUT");end

`ifdef GATE_SDF
  initial $sdf_annotate("Syn_crc8_stream.sdf", dut);
`endif
  initial begin
`ifdef VCS_VPD
    $vcdplusfile("inter.vpd");
    $vcdpluson(0, tb_crc8_stream);
`else
    $dumpfile("crc8_stream_rtl.vcd");
    $dumpvars(0, tb_crc8_stream);
`endif
  end

endmodule
