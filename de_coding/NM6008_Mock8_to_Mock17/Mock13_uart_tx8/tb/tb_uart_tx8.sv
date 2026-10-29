`timescale 1ns/1ps
module tb_uart_tx8;
  localparam integer DIV=4;
  reg clk=0,rst_n=0,start=0;reg [7:0] data_in=0;
  wire tx,busy,done;integer checks=0,k,t,n;reg [9:0] bits;
  reg [31:0] rng=32'haabb1258;
  uart_tx8 #(.CLKS_PER_BIT(DIV)) dut(.*);always #5 clk=~clk;
  task automatic send(input reg [7:0] data);
    begin
      bits={1'b1,data,1'b0};
      @(negedge clk);start=1;data_in=data;
      @(posedge clk);#1;
      if(!busy||done||tx!==0)$fatal(1,"UART start");
      for(k=0;k<10;k=k+1)begin
        for(t=0;t<DIV;t=t+1)begin
          @(negedge clk); checks=checks+1;
          if(!busy||tx!==bits[k]||done)
            $fatal(1,"UART waveform mismatch bit=%0d sample=%0d",k,t);
          start=(k==3 && t==2); // ignored while busy
          data_in=~data;
        end
      end
      @(posedge clk);#1;
      if(busy||!done||tx!==1)$fatal(1,"UART completion");
      @(posedge clk);#1;
      if(done||busy||tx!==1)$fatal(1,"UART done not pulsed");
      @(negedge clk);start=0;
    end
  endtask
  initial begin
    repeat(2)@(posedge clk);#1;
    if(tx!==1||busy||done)$fatal(1,"UART reset");
    @(negedge clk);rst_n=1;
    send(8'h00);send(8'hff);send(8'h55);send(8'ha6);
    for(n=0;n<20;n=n+1)begin
       rng=rng*32'd1664525+32'd1013904223;send(rng[7:0]);
    end
    $display("PASS ALL UART checks=%0d",checks);$finish;
  end
  initial begin #100000;$fatal(1,"TIMEOUT");end

`ifdef GATE_SDF
  initial $sdf_annotate("Syn_uart_tx8.sdf", dut);
`endif
  initial begin
`ifdef VCS_VPD
    $vcdplusfile("inter.vpd");
    $vcdpluson(0, tb_uart_tx8);
`else
    $dumpfile("uart_tx8_rtl.vcd");
    $dumpvars(0, tb_uart_tx8);
`endif
  end

endmodule
