// ============================================================
// 第14题：4 位线性反馈移位寄存器，用于产生伪随机序列。反馈位 fb=Q[3] 异或 Q[2]；EN=1 时，每拍执行 Q<={Q[2:0],fb}。复位种子取 0001，不能取 0000，因为全零状态会一直锁死；理论周期为 15 个非零状态。
// ============================================================
module LFSR4 (
    input  wire       CLK,
    input  wire       NRST,
    input  wire       EN,
    output reg  [3:0] Q
);
    wire fb = Q[3] ^ Q[2];               // 反馈抽头取 Q[3] 和 Q[2] 并进行异或

    always @(posedge CLK or negedge NRST) begin
        if (!NRST)
            Q <= 4'b0001;                // 复位种子为非零值，避免进入全零锁死状态
        else if (EN)
            Q <= {Q[2:0], fb};
    end
endmodule
