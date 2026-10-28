`timescale 1ns/1ps
/*
Leading Zero Count
1. 什么叫前导零
比如：
din = 32'b0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
从最高位 din[31] 往低位看：
0 0 0 0 0 0 0 1 ...
↑
这些最前面的0就是leading zeros
如果第一个 1 出现在：
din[24]
那么：
din[31:25] 一共7个0
所以：
lzc = 7;

2. 几个例子
din = 32'h8000_0000
二进制最高位就是1
→ lzc = 0
din = 32'h4000_0000
最高两位 = 01
→ lzc = 1
din = 32'h0000_0001
只有最低位是1
→ lzc = 31
特殊情况：
din = 32'h0000_0000
→ 32个bit全是0
→ lzc = 32
所以输出必须是 6 bit：
[5:0]
因为要表示 32。
*/


module lzc32 (
    input  wire [31:0] din,
    output reg  [5:0]  count
);

integer i;
reg found;

always @(*) begin
    count = 6'd0;
    found = 1'b0;

    for (i = 31; i >= 0; i = i - 1) begin
        if (!found) begin
            if (din[i] == 1'b0)
                count = count + 1'b1;
            else
                found = 1'b1;
        end
    end
end

endmodule