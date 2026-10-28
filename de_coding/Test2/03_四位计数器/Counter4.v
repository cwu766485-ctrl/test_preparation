// ============================================================
// 第 3 题：4 位向上计数器，数值按 0、1、…、15、0 循环。
// NRST：低电平有效异步复位，发生时立即把 Q 清零。
// CLR：高电平有效同步清零，只在下一时钟上升沿生效。
// EN：计数使能；EN=0 时保持 Q 不变。
// Q：当前 4 位计数值，15 再加 1 自动回到 0。
// TC：终值指示；仅在 EN=1 且 Q=15 时为 1，可用于级联计数器。
// 控制优先级为 NRST、CLR、EN，前者优先。
// ============================================================
module Counter4 (
    input  wire       CLK,
    input  wire       NRST,
    input  wire       CLR,
    input  wire       EN,
    output reg  [3:0] Q,
    output wire       TC
);
    always @(posedge CLK or negedge NRST) begin
        if (!NRST)
            Q <= 4'd0;              // NRST 在敏感列表中，因此清零是异步的。
        else if (CLR)
            Q <= 4'd0;              // CLR 只在时钟上升沿被检查，因此清零是同步的。
        else if (EN)
            Q <= Q + 4'd1;          // Q 只有 4 位；15+1 的进位被丢弃，结果自然回到 0。
        // 没有末尾 else 时，Q 在 EN=0 时保持旧值；这里是时钟触发寄存器，
        // 综合结果是带使能的触发器，并非锁存器。
    end

    assign TC = EN & (Q == 4'd15);  // TC 是组合信号；当前 Q=15 且允许计数时提示即将回绕。
endmodule
