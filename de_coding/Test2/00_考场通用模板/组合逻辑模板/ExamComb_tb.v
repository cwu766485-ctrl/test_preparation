`timescale 1ns/1ps
// 默认异或示例的自检测试平台；修改设计功能后，必须修改对应的期望公式。
module ExamComb_tb;
    parameter NUM_VECTORS = 8;
    reg [7:0] A, B;
    wire [7:0] RESULT;
    wire FLAG;
    reg [15:0] vectors [0:NUM_VECTORS-1]; // 每条向量 16 位：高 8 位是 A，低 8 位是 B。
    reg [7:0] expected_result;
    reg expected_flag;
    integer i, seed, tests, errors, log_fd;

    ExamComb U1 (.A(A), .B(B), .RESULT(RESULT), .FLAG(FLAG));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_ExamComb.sdf", U1);
`endif
`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, ExamComb_tb);
    end
`endif

    task check_case;
        input [7:0] a, b;
        begin
            A = a; B = b;
            #5;                           // 改变输入后等待 5 ns，再检查组合逻辑输出，避免在传播期间误判。

            // 修改点 TB-1：独立计算预期的 RESULT 和 FLAG，不要直接读取设计内部信号。
            expected_result = a ^ b;
            expected_flag = (expected_result == 0);
            tests = tests + 1;
            if (RESULT !== expected_result || FLAG !== expected_flag) begin
                errors = errors + 1;
                $display("FAIL A=%h B=%h: RESULT=%h FLAG=%b; expected %h %b",
                         a, b, RESULT, FLAG, expected_result, expected_flag);
                $fdisplay(log_fd, "FAIL A=%h B=%h", a, b);
            end else
                $fdisplay(log_fd, "PASS A=%h B=%h -> RESULT=%h FLAG=%b",
                          a, b, RESULT, FLAG);
        end
    endtask

    initial begin
        $readmemh("InputVector.txt", vectors);
        log_fd = $fopen("Check.txt", "w");
        A = 0; B = 0; tests = 0; errors = 0; seed = 42;
        for (i = 0; i < NUM_VECTORS; i = i + 1)
            check_case(vectors[i][15:8], vectors[i][7:0]);
        for (i = 0; i < 128; i = i + 1)
            check_case($random(seed), $random(seed));

        $display("==== DONE: %0d combinational cases, %0d errors ====", tests, errors);
        $fdisplay(log_fd, "==== DONE: %0d combinational cases, %0d errors ====", tests, errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
