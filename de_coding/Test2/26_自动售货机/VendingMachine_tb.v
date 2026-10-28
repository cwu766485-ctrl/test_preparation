`timescale 1ns/1ps
// 第26题测试：先测 5+5+5、10+5、5+10、10+10、5+5+10 等定向投币顺序。
// 再用 400 拍随机覆盖 5 分、10 分、不投币、两种同时投入；每拍用整数余额模型算期望输出。
// 最后核对金额守恒：投入总额=15×出货数+5×找零数+剩余余额。时钟周期 2*CLK_T=20 ns。
module VendingMachine_tb;
    parameter CLK_T = 10;

    reg  CLK, NRST, NICKEL, DIME;
    wire VEND, CHANGE;

    integer credit, money_in, items, changes, errors, i, r, seed, log_fd;
    reg     exp_vend, exp_change;

    VendingMachine U1 (.CLK(CLK), .NRST(NRST), .NICKEL(NICKEL), .DIME(DIME),
                       .VEND(VEND), .CHANGE(CHANGE));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_VendingMachine.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, VendingMachine_tb);
    end
`endif

    initial CLK = 1'b0;
    always #CLK_T CLK = ~CLK;

    // 独立余额参考模型及逐拍检查器
    always @(posedge CLK) begin
        if (NRST) begin
            exp_vend = 0; exp_change = 0;
            if (NICKEL ^ DIME) begin
                credit   = credit + (NICKEL ? 5 : 10);
                money_in = money_in + (NICKEL ? 5 : 10);
                if (credit >= 15) begin
                    exp_vend   = 1;
                    exp_change = (credit == 20);
                    credit     = 0;
                end
            end
            #2;
            if (VEND !== exp_vend || CHANGE !== exp_change) begin
                errors = errors + 1;
                $display ("FAIL t=%0t VEND=%b CHANGE=%b (exp %b %b)", $time, VEND, CHANGE, exp_vend, exp_change);
                $fdisplay(log_fd, "FAIL t=%0t VEND=%b CHANGE=%b (exp %b %b)", $time, VEND, CHANGE, exp_vend, exp_change);
            end
            if (VEND)   items   = items + 1;
            if (CHANGE) changes = changes + 1;
            if (VEND &&  CHANGE) $fdisplay(log_fd, "t=%0t VEND + CHANGE (5)", $time);
            if (VEND && !CHANGE) $fdisplay(log_fd, "t=%0t VEND", $time);
        end
    end

    task coin(input n, input d);
        begin
            @(negedge CLK); NICKEL = n; DIME = d;
            @(negedge CLK); NICKEL = 0; DIME = 0;      // 每次投币后插入一个空闲拍
        end
    endtask

    initial begin
        log_fd = $fopen("Check.txt", "w");
        errors = 0; credit = 0; money_in = 0; items = 0; changes = 0; seed = 26;
        NRST = 0; NICKEL = 0; DIME = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;

        coin(1,0); coin(1,0); coin(1,0);          // 三枚 5 分币，应出货
        coin(0,1); coin(1,0);                     // 10 分加 5 分，应出货
        coin(1,0); coin(0,1);                     // 5 分加 10 分，应出货
        coin(0,1); coin(0,1);                     // 两枚 10 分币，应出货并找 5 分
        coin(1,0); coin(1,0); coin(0,1);          // 5+5+10 分，应出货并找 5 分
        coin(1,1);                                // 两种币同时投入，应忽略

        for (i = 0; i < 400; i = i + 1) begin     // 随机投币，可能连续每拍都有硬币
            @(negedge CLK);
            r = $random(seed) & 7;
            NICKEL = (r == 1 || r == 2 || r == 7);
            DIME   = (r == 3 || r == 4 || r == 7);  // r=7 时两币同时出现，应忽略
        end
        @(negedge CLK); NICKEL = 0; DIME = 0;
        repeat (2) @(negedge CLK);

        if (money_in != 15 * items + 5 * changes + credit) begin
            errors = errors + 1;
            $display("FAIL: money in %0d != 15*%0d + 5*%0d + %0d", money_in, items, changes, credit);
        end
        $display ("==== DONE: %0d cents in, %0d items, %0d changes, %0d errors ====", money_in, items, changes, errors);
        $fdisplay(log_fd, "==== DONE: %0d cents in, %0d items, %0d changes, %0d errors ====", money_in, items, changes, errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
