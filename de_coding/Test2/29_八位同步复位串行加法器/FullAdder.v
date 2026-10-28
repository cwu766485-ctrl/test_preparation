// M3: 1 位全加器。串行加法器每个时钟周期复用同一个实例。
module FullAdder (
    input  wire A,
    input  wire B,
    input  wire CIN,
    output wire S,
    output wire COUT
);
    assign S    = A ^ B ^ CIN;
    assign COUT = (A & B) | (CIN & (A ^ B));
endmodule
