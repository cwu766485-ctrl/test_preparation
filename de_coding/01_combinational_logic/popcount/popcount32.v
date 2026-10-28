module popcount32 (
    input  wire [31:0] data_i,
    output reg  [5:0]  count
);

integer i;

always @(*) begin
    count = 6'd0;

    for (i = 0; i < 32; i = i + 1) begin
        count = count + data_i[i];
    end
end

endmodule

/*
module popcount32 (
    input  wire [31:0] data_i,
    output wire [5:0]  count
);

function [5:0] popcount;
    input [31:0] din;

    integer i;
    reg [5:0] cnt;

    begin
        cnt = 6'd0;

        for (i = 0; i < 32; i = i + 1)
            cnt = cnt + din[i];

        popcount = cnt;
    end
endfunction

assign count = popcount(data_i);

endmodule
*/

/*
你写：

for (...)
    cnt = cnt + din[i];

从 RTL 语义上是一串组合累加。

综合工具可能进行优化，但你不能想当然认为：

它一定自动变成完美平衡的高速树。

如果真的追求高频率，更合理的体系结构是平衡加法树：

第一层：
bit0 + bit1
bit2 + bit3
...
bit30 + bit31
       ↓ 16个结果
第二层：
两两相加
       ↓ 8个结果
第三层：
       ↓ 4个
第四层：
       ↓ 2个
第五层：
       ↓ 1个
逻辑深度大致从：
O(32)
降为：
O(log2 32) = O(5)
这才是高速 popcount 的思路。
*/
