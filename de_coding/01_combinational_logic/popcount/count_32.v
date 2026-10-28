module count_32 (
    input  wire        clk,
    input  wire        rst_n,

    input  wire [31:0] data_i,
    input  wire        valid_i,

    output reg  [5:0]  count,
    output reg         done
);

reg [31:0] data_reg;
reg [5:0]  count_reg;
reg [5:0]  cnt;
reg        busy;

always @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin

        data_reg  <= 32'd0;
        count_reg <= 6'd0;
        cnt       <= 6'd0;

        count     <= 6'd0;
        done      <= 1'b0;
        busy      <= 1'b0;

    end

    else begin

        // done默认只拉高1拍
        done <= 1'b0;

        // 接收新的32bit数据
        if (valid_i && !busy) begin

            data_reg  <= data_i;
            count_reg <= 6'd0;
            cnt       <= 6'd0;

            busy      <= 1'b1;

        end

        // 每拍处理1bit
        else if (busy) begin

            if (cnt == 6'd31) begin

                // 加上最后一个bit
                count <= count_reg + data_reg[0];

                done <= 1'b1;
                busy <= 1'b0;

            end

            else begin

                count_reg <= count_reg + data_reg[0];

                data_reg <= data_reg >> 1;

                cnt <= cnt + 1'b1;

            end

        end

    end
end

endmodule