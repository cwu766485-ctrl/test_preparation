// ============================================================
// 第13题：4 位串行输入、并行输出移位寄存器。NRST 拉低时无需时钟立即清零；EN=1 的每个上升沿，旧 Q[2:0] 移向高位，SIN 进入 Q[0]；EN=0 时保持。SOUT 始终连接 Q[3]。时序块使用非阻塞赋值，保证各触发器读取同一拍的旧值。
// ============================================================
module ShiftReg4 (
    input  wire       CLK,
    input  wire       NRST,
    input  wire       EN,
    input  wire       SIN,
    output reg  [3:0] Q,
    output wire       SOUT
);
    always @(posedge CLK or negedge NRST) begin
        if (!NRST)
            Q <= 4'b0000;
        else if (EN)
            Q <= {Q[2:0], SIN};
    end

    assign SOUT = Q[3];

    // 同一移位操作也可逐位写出；注意时序逻辑使用非阻塞赋值。
    // 逐位非阻塞赋值示例：Q[3] <= Q[2];  Q[2] <= Q[1];  Q[1] <= Q[0];  Q[0] <= SIN; 这些右侧都读取旧值，语句先后顺序不影响结果。
    // 如果按下面顺序使用阻塞赋值，前面更新的新值会立即传给后面。
    // 错误的阻塞赋值示例：Q[0] = SIN; Q[1] = Q[0]; Q[2] = Q[1]; Q[3] = Q[2]; 新值逐句传递，会让四位在同一拍都变成 SIN。
endmodule
