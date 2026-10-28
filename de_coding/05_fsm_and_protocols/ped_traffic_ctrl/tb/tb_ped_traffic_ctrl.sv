`timescale 1ns/1ps
module tb_ped_traffic_ctrl;
    reg clk=0, rst_n=0, tick=0, ped_req=0;
    wire car_green, car_yellow, car_red, walk;
    wire [1:0] phase;
    integer model_phase=0, model_elapsed=0;
    reg model_pending=0;
    integer tests=0, walk_seen=0, red_seen=0, k;
    always #5 clk=~clk;

    ped_traffic_ctrl #(.GREEN_TICKS(4), .YELLOW_TICKS(2),
                       .ALL_RED_TICKS(1), .WALK_TICKS(3)) dut(
        .clk(clk),.rst_n(rst_n),.tick(tick),.ped_req(ped_req),
        .car_green(car_green),.car_yellow(car_yellow),.car_red(car_red),
        .walk(walk),.phase(phase));
`ifdef GATE_SDF
    initial $sdf_annotate("Syn_ped_traffic_ctrl.sdf", dut);
`endif
`ifdef VCS_VPD
    initial begin $vcdplusfile("inter.vpd"); $vcdpluson(0,tb_ped_traffic_ctrl); end
`else
    initial begin $dumpfile("mock5.vcd"); $dumpvars(0,tb_ped_traffic_ctrl); end
`endif

    task automatic reset_model;
        begin model_phase=0; model_elapsed=0; model_pending=0; end
    endtask
    task automatic check_outputs;
        begin
            if (phase !== model_phase[1:0] ||
                car_green !== (model_phase==0) ||
                car_yellow !== (model_phase==1) ||
                car_red !== ((model_phase==2)||(model_phase==3)) ||
                walk !== (model_phase==3))
                $fatal(1,"Mock5 mismatch phase=%0d expected=%0d", phase, model_phase);
            if (car_green && car_red || car_yellow && car_red || walk && car_green)
                $fatal(1,"Mock5 unsafe lights");
            if (walk) walk_seen=walk_seen+1;
            if (model_phase==2) red_seen=red_seen+1;
            tests=tests+1;
        end
    endtask
    task automatic step(input reg req, input reg enable_tick);
        begin
            @(negedge clk); ped_req=req; tick=enable_tick;
            @(posedge clk);
            if (req && model_phase!=3) model_pending=1;
            if (enable_tick) begin
                case (model_phase)
                    0: if (model_elapsed==3) begin model_phase=1;model_elapsed=0;end
                       else model_elapsed=model_elapsed+1;
                    1: if (model_elapsed==1) begin model_phase=2;model_elapsed=0;end
                       else model_elapsed=model_elapsed+1;
                    2: if (model_elapsed==0) begin
                           model_elapsed=0;
                           if (model_pending) begin model_phase=3;model_pending=0;end
                           else model_phase=0;
                       end else model_elapsed=model_elapsed+1;
                    3: if (model_elapsed==2) begin model_phase=0;model_elapsed=0;end
                       else model_elapsed=model_elapsed+1;
                endcase
            end
            #1; check_outputs();
        end
    endtask
    initial begin
        repeat(2) @(negedge clk);
        reset_model();rst_n=1;
        check_outputs();
        // No pedestrian request => cycling GREEN-YELLOW-ALL_RED-GREEN.
        for (k=0;k<30;k=k+1) step(0,1);
        // Request must be latched even while tick=0.
        step(1,0);
        for (k=0;k<30;k=k+1) step(0,1);
        // Random request, random tick hold/stall.
        for (k=0;k<300;k=k+1)
            step($urandom_range(0,6)==0, $urandom_range(0,4)!=0);
        // Reset in flight.
        @(negedge clk); rst_n=0; tick=0;ped_req=0;reset_model();
        #1;check_outputs();
        @(negedge clk);rst_n=1;
        for (k=0;k<25;k=k+1) step(k==2,1);
        if(walk_seen==0 || red_seen==0) $fatal(1,"Mock5 coverage missing");
        $display("PASS Mock5 ped_traffic_ctrl checks=%0d",tests);
        $finish;
    end
    initial begin #100000; $fatal(1,"Mock5 timeout"); end
endmodule
