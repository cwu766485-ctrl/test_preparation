// 第26题：售货机状态机，商品价格 15 分；NICKEL 表示投入 5 分，DIME 表示投入 10 分。
// 每种投币信号保持一拍；若同拍两种币都为 1，视为无效且维持当前余额。
// S0/S5/S10 分别代表当前累计 0/5/10 分；达到 15 分出货并清零，达到 20 分还找 5 分。
// VEND、CHANGE 都是寄存器输出，在接收使余额达标的硬币的上升沿后有效一拍。
module VendingMachine (
    input  wire CLK,
    input  wire NRST,
    input  wire NICKEL,
    input  wire DIME,
    output reg  VEND,
    output reg  CHANGE
);
    localparam S0 = 2'd0, S5 = 2'd1, S10 = 2'd2;

    reg [1:0] state;

    always @(posedge CLK or negedge NRST) begin
        if (!NRST) begin
            state  <= S0;
            VEND   <= 1'b0;
            CHANGE <= 1'b0;
        end else begin
            VEND   <= 1'b0;                      // 每拍默认清零，使出货、找零只持续一拍
            CHANGE <= 1'b0;
            if (NICKEL && !DIME) begin           // 投入 5 分硬币
                case (state)
                    S0:  state <= S5;
                    S5:  state <= S10;
                    S10: begin state <= S0; VEND <= 1'b1; end                  // 累计达到 15 分，出货并清零
                    default: state <= S0;
                endcase
            end else if (DIME && !NICKEL) begin  // 投入 10 分硬币
                case (state)
                    S0:  state <= S10;
                    S5:  begin state <= S0; VEND <= 1'b1; end                  // 累计达到 15 分，出货并清零
                    S10: begin state <= S0; VEND <= 1'b1; CHANGE <= 1'b1; end  // 累计达到 20 分，出货并找 5 分
                    default: state <= S0;
                endcase
            end
            // 没投币或同时投两种币时，保持当前余额
        end
    end
endmodule
