// ============================================================
// 第 2 题：Moore 型有限状态机，逐拍检测串行输入 DIN 中的 101。
// 允许重叠，例如 10101 中第 1～3 位和第 3～5 位各检测一次。
// CLK：时钟，DIN 在上升沿被采样。
// NRST：低电平有效的异步复位，不必等待时钟即可回到初态。
// DIN：串行数据输入，每个时钟送入一位。
// DET：收到完整 101 后为 1，持续一个时钟周期。
// Moore 输出只取决于已登记的状态；状态进入 S3 后 DET 才变成 1。
// 因此 DET 不会直接跟随 DIN 的毛刺变化。
// ============================================================
module SeqDet101 (
    input  wire CLK,
    input  wire NRST,
    input  wire DIN,
    output wire DET
);
    // 四个状态需要 2 位编码；状态含义是“目前保留了模式的哪个前缀”。
    parameter S0 = 2'b00;   // S0：当前输入末尾还没有可用的 101 前缀。
    parameter S1 = 2'b01;   // S1：当前输入末尾是 1。
    parameter S2 = 2'b10;   // S2：当前输入末尾是 10。
    parameter S3 = 2'b11;   // S3：刚收到 101，此状态下 DET 为 1。

    reg [1:0] state, next_state;

    // 第一部分是状态寄存器：上升沿用非阻塞赋值更新，异步复位回 S0。
    always @(posedge CLK or negedge NRST) begin
        if (!NRST)
            state <= S0;
        else
            state <= next_state;
    end

    // 第二部分是组合下一状态逻辑：使用阻塞赋值，default 覆盖非法状态以避免锁存。
    always @(state or DIN) begin
        case (state)
            S0: next_state = DIN ? S1 : S0;
            S1: next_state = DIN ? S1 : S2;   // 在 S1 再收到 1，最后一位仍可作为新模式的起始 1。
            S2: next_state = DIN ? S3 : S0;   // 在 S2 再收到 0，末尾变成 100，不保留有效前缀。
            S3: next_state = DIN ? S1 : S2;   // 在 S3 收到新位时保留重叠：101 的末尾 1 可以作为下一次检测的开头。
            default: next_state = S0;
        endcase
    end

    // 第三部分是 Moore 输出译码：仅看当前状态是否为 S3。
    assign DET = (state == S3);
endmodule
