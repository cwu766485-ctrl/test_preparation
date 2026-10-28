// ============================================================
// 第12题：4 路、每路 4 位的组合多路选择器。SEL=00/01/10/11 分别选择 D0/D1/D2/D3。当前生效的是完整 case 写法；下方还有等价写法与一个专门展示锁存器问题的注释示例。
// ============================================================
module Mux4 (
    input  wire [3:0] D0,
    input  wire [3:0] D1,
    input  wire [3:0] D2,
    input  wire [3:0] D3,
    input  wire [1:0] SEL,
    output reg  [3:0] Y
);
    // 写法一（当前生效）：组合 always 加 case；所有选择值都赋值，避免锁存器。
    always @(*) begin
        case (SEL)
            2'b00:   Y = D0;
            2'b01:   Y = D1;
            2'b10:   Y = D2;
            2'b11:   Y = D3;
            default: Y = 4'd0;
        endcase
    end

    // 写法二：也可用嵌套条件运算符；若启用，需要把 Y 声明成 wire。
    // assign Y = SEL[1] ? (SEL[0] ? D3 : D2) : (SEL[0] ? D1 : D0);

    // 写法三是故意错误的示例：想一想综合后会出现什么元件。
    // always @(*) begin
    //     if (SEL == 2'b00) Y = D0;
    //     else if (SEL == 2'b01) Y = D1;
    // end
    // 当 SEL 为 10 或 11 时，Y 没有被赋值，因此必须保持原值。
    // 保持原值需要存储元件，综合会推断出锁存器。
endmodule
