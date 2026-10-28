// ============================================================
// 第18题：无符号移位相加乘法器。START 装入 A、B；随后 W 个时钟每拍看 b_sh[0]，若为 1 就把当前左移后的 A 加到部分积。A 每拍左移，B 每拍右移，只复用一个 2W 位加法器。最后一拍把 acc_next 写入 P，并把 DONE 拉高一拍。
// ============================================================
module ShiftAddMul #(
    parameter W = 8
) (
    input  wire           CLK,
    input  wire           NRST,
    input  wire           START,
    input  wire [W-1:0]   A,
    input  wire [W-1:0]   B,
    output reg  [2*W-1:0] P,
    output reg            DONE
);
    localparam IDLE = 1'b0, RUN = 1'b1;

    reg           state;
    reg [2*W-1:0] a_sh;                    // 被乘数的扩展副本，每拍左移一位
    reg [W-1:0]   b_sh;                    // 乘数副本每拍右移一位，最低位决定本拍是否相加
    reg [2*W-1:0] acc;                     // 已累加的部分积
    reg [4:0]     cnt;                     // 当前处理的乘数位序号；5 位可表示 0 到 31

    wire [2*W-1:0] acc_next = acc + (b_sh[0] ? a_sh : {2*W{1'b0}});   // 唯一的加法器：最低乘数位为 1 就加 a_sh，否则加 0

    always @(posedge CLK or negedge NRST) begin
        if (!NRST) begin
            state <= IDLE;
            a_sh  <= 0;  b_sh <= 0;  acc <= 0;  cnt <= 0;
            P     <= 0;  DONE <= 1'b0;
        end else begin
            DONE <= 1'b0;
            case (state)
                IDLE: if (START) begin
                    a_sh  <= {{W{1'b0}}, A};       // 将无符号 A 高位补零扩展为 2W 位，供后续左移
                    b_sh  <= B;
                    acc   <= 0;
                    cnt   <= 0;
                    state <= RUN;
                end
                RUN: begin
                    acc  <= acc_next;
                    a_sh <= a_sh << 1;
                    b_sh <= b_sh >> 1;
                    if (cnt == W - 1) begin
                        P     <= acc_next;          // 最后一位也要计入，因此输出 acc_next 而非旧 acc
                        DONE  <= 1'b1;
                        state <= IDLE;
                    end else
                        cnt <= cnt + 5'd1;
                end
            endcase
        end
    end
endmodule
