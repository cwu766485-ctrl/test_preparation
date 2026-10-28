module barrel_shifter #(
    parameter W = 8
)(
    input  wire [W-1:0] din,
    input  wire [$clog2(W)-1:0] shamt,
    input  wire         dir,
    output wire [W-1:0] dout
);

assign dout = dir ? (din >> shamt)
                  : (din << shamt);

endmodule

/*
所以你必须区分：
<<   逻辑左移
>>   逻辑右移
>>>  算术右移
*/