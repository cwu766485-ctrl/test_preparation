// ============================================================
// 第 7 题：Module 5 的矩阵乘法器改为无符号版本。
// 输出计算 OUT=A1×B1+A0×B0；A、B 都是 0～255 的 8 位无符号数。
// 沿用 Module 5 的状态机、乘法器、累加器结构和时序；
// A1/B1 与 A0/B0 依次复用 A/B 输入总线，每组结果约五拍出现一次。
// 模块与端口名称保持原样，Module 5 的脚本无需改顶层名。
//
// 相对有符号版需注意以下三处：
// 第一，端口和寄存器不使用 signed 关键字。
// 第二，乘法按无符号解释，不做 $signed() 转换。
// 第三，16 位乘积扩成 17 位时在高位补 0，而非复制符号位。
// 最大值是 255×255+255×255=130050，小于 2^17，因此 17 位足够。
// ============================================================
module MatrixMultiplier (
    input  wire        CLK,
    input  wire        NRST,
    input  wire        START,
    input  wire [7:0]  A,              // A 为无符号 8 位输入。
    input  wire [7:0]  B,              // B 为无符号 8 位输入。
    output reg  [16:0] OUT,            // OUT 用 17 位容纳两项乘积之和。
    output reg         OUT_STROBE
);
    localparam [2:0] IDLE       = 3'd0,
                     ACC_FIRST  = 3'd1,
                     MUL_SECOND = 3'd2,
                     ACC_SECOND = 3'd3,
                     OUTPUT     = 3'd4,
                     MUL_FIRST  = 3'd5;

    reg [2:0]  state;
    reg [15:0] product_reg;            // 暂存一个无符号 16 位乘积。
    reg [16:0] acc_reg;                // 17 位累加寄存器，避免两项相加溢出。

    // 状态机产生的使能信号分别控制乘积、累加与输出寄存器。
    wire en1 = ((state == IDLE) && START) ||          // en1 允许乘积寄存器在接收输入的状态更新。
               (state == MUL_SECOND) || (state == MUL_FIRST);
    wire en2 = (state == ACC_FIRST) || (state == ACC_SECOND);   // en2 允许累加寄存器更新。
    wire en3 = (state == OUTPUT);                                // en3 允许输出寄存器更新，并使 OUT_STROBE 有效。

    wire [15:0] product          = A * B;                   // A×B 按无符号乘法产生 16 位结果。
    wire [16:0] extended_product = {1'b0, product_reg};     // 乘积高位补 0，扩为可与 17 位累加器相加的数。
    wire [16:0] acc_base         = (state == ACC_FIRST) ? 17'd0 : acc_reg;
    wire [16:0] acc_sum          = acc_base + extended_product;

    always @(posedge CLK or negedge NRST) begin
        if (!NRST) begin
            state       <= IDLE;
            product_reg <= 16'd0;
            acc_reg     <= 17'd0;
            OUT         <= 17'd0;
            OUT_STROBE  <= 1'b0;
        end else begin
            OUT_STROBE <= en3;
            if (en1) product_reg <= product;
            if (en2) acc_reg     <= acc_sum;
            if (en3) OUT         <= acc_reg;

            case (state)
                IDLE:       if (START) state <= ACC_FIRST;
                ACC_FIRST:  state <= MUL_SECOND;
                MUL_SECOND: state <= ACC_SECOND;
                ACC_SECOND: state <= OUTPUT;
                OUTPUT:     state <= MUL_FIRST;
                MUL_FIRST:  state <= ACC_FIRST;
                default:    state <= IDLE;
            endcase
        end
    end
endmodule
