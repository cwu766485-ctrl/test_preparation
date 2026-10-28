`timescale 1ns/1ps
// ============================================================
// 第 6 题：Module 3 的可选题 B1 与 B2，测量全加器跳变延时。
// B1：8 种三位输入状态中，每种都跳到另外 7 种，共 8×7=56 次跳变。
// B2：分别找出 S 与 COUT 的最大传播延时，以及造成它的输入跳变。
// 延时测量只在带 SDF 的门级仿真有意义；行为级模型一般显示 0。
// 门级仿真命令如下，需具备综合网表、SDF 和库文件：
// 结果写入 All56.txt：每次跳变一行，末尾汇总最大延时。
// 沿用 Module 3 报告中的测法；示例曾测得 S 为 53 ps、COUT 为 39 ps，实际结果依网表而变。
// ============================================================
module FullAdder_tb_all;
    reg  CIN, A, B;
    wire S, COUT;

    FullAdder U1 (.A(A), .B(B), .CIN(CIN), .S(S), .COUT(COUT));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_FullAdder.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, FullAdder_tb_all);
    end
`endif

    integer   p, n, k, fd;
    integer   ns_s, ns_c;               // 分别记录本次输入跳变后 S、COUT 翻转的次数。
    reg       meas;                     // 测量开关；为 1 时输出跳变才计入本次测量。
    realtime  t_in, d_s, d_c, max_s, max_c;
    reg [2:0] ms_p, ms_n, mc_p, mc_n;   // 保存造成最大 S 延时和最大 COUT 延时的起始与目标输入。
    reg [2:0] pv, nv;

    // 每次输出变化记录相对输入改变的时间；多次翻转时保留最后一次时间。
    always @(S)    if (meas) begin d_s = $realtime - t_in; ns_s = ns_s + 1; end
    always @(COUT) if (meas) begin d_c = $realtime - t_in; ns_c = ns_c + 1; end

    initial begin
        fd = $fopen("All56.txt", "w");
        meas = 0; max_s = 0; max_c = 0; k = 0;
        ms_p = 0; ms_n = 0; mc_p = 0; mc_n = 0;
        {B, A, CIN} = 3'b000; #10;
        $fdisplay(fd, " No  {B A CIN}      S delay(ps) #chg   COUT delay(ps) #chg");

        for (p = 0; p < 8; p = p + 1)
            for (n = 0; n < 8; n = n + 1)
                if (n != p) begin
                    pv = p; nv = n;
                    meas = 0;
                    {B, A, CIN} = pv; #10;          // 先设置本次起始输入并等待 10 ns，让电路稳定。
                    d_s = 0; d_c = 0; ns_s = 0; ns_c = 0;
                    t_in = $realtime; meas = 1;
                    {B, A, CIN} = nv; #10;          // 再设置目标输入并等待 10 ns，在这段时间里测量输出变化。
                    meas = 0;
                    k = k + 1;
                    $fdisplay(fd, " %2d  %b -> %b    %8.1f   %0d     %8.1f   %0d",
                              k, pv, nv, d_s*1000, ns_s, d_c*1000, ns_c);
                    // 输出翻转奇数次代表最终值改变；偶数次表示回到原值，视为毛刺，不参与最大值统计。
                    if ((ns_s % 2 == 1) && (d_s > max_s)) begin max_s = d_s; ms_p = pv; ms_n = nv; end
                    if ((ns_c % 2 == 1) && (d_c > max_c)) begin max_c = d_c; mc_p = pv; mc_n = nv; end
                end

        $fdisplay(fd, "Transitions applied = %0d", k);
        $fdisplay(fd, "Worst S    delay = %0.1f ps  for {B A CIN} %b -> %b", max_s*1000, ms_p, ms_n);
        $fdisplay(fd, "Worst COUT delay = %0.1f ps  for {B A CIN} %b -> %b", max_c*1000, mc_p, mc_n);
        $display ("Transitions applied = %0d", k);
        $display ("Worst S    delay = %0.1f ps  for {B A CIN} %b -> %b", max_s*1000, ms_p, ms_n);
        $display ("Worst COUT delay = %0.1f ps  for {B A CIN} %b -> %b", max_c*1000, mc_p, mc_n);
        $fclose(fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
