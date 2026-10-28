`timescale 1ns/1ps

module tb_crc8;
    logic clk = 1'b0;
    always #5 clk = ~clk;

    logic rst_n = 1'b1;
    logic data_in = 1'b0;
    logic data_valid = 1'b0;
    wire [7:0] crc;
    wire crc_valid;

    crc8 dut (
        .clk(clk), .rst_n(rst_n),
        .data_in(data_in), .data_valid(data_valid),
        .crc(crc), .crc_valid(crc_valid)
    );

    logic [7:0] ref_crc = '0;
    int ref_bit_count = 0;
    int cycles = 0;

    // MSB-first CRC-8: polynomial x^8+x^2+x+1 (0x07), init=0.
    function automatic logic [7:0] crc8_step_ref(
        input logic [7:0] previous, input bit incoming
    );
        logic [7:0] shifted;
        shifted = {previous[6:0], 1'b0};
        return shifted ^ ((previous[7] ^ incoming) ? 8'h07 : 8'h00);
    endfunction

    task automatic reset_dut;
        @(negedge clk);
        rst_n = 1'b0;
        data_in = 1'b0;
        data_valid = 1'b0;
        ref_crc = '0;
        ref_bit_count = 0;
        #1;
        if (crc !== 8'h00 || crc_valid !== 1'b0)
            $fatal(1, "CRC ASYNC RESET FAIL: crc=%h valid=%b", crc, crc_valid);
        @(posedge clk);
        #1;
        @(negedge clk);
        rst_n = 1'b1;
        $display("CRC RESET PASS");
    endtask

    task automatic step(input bit valid_bit, input bit serial_bit);
        bit expected_valid;
        logic [7:0] old_crc;

        @(negedge clk);
        data_valid = valid_bit;
        data_in = serial_bit;
        old_crc = ref_crc;
        expected_valid = 1'b0;

        if (valid_bit) begin
            ref_crc = crc8_step_ref(ref_crc, serial_bit);
            if (ref_bit_count == 7) begin
                ref_bit_count = 0;
                expected_valid = 1'b1;
            end else begin
                ref_bit_count++;
            end
        end

        @(posedge clk);
        #1;
        cycles++;
        if (crc !== ref_crc || crc_valid !== expected_valid)
            $fatal(1,
                "CRC FAIL cycle=%0d valid_in=%b bit=%b expected_crc=%02h actual_crc=%02h exp_pulse=%b pulse=%b",
                cycles, valid_bit, serial_bit, ref_crc, crc, expected_valid, crc_valid);
        if (!valid_bit && crc !== old_crc)
            $fatal(1, "CRC HOLD FAIL cycle=%0d", cycles);
    endtask

    task automatic send_byte_msb(input logic [7:0] value,
                                 input bit insert_gaps);
        for (int j = 7; j >= 0; j--) begin
            step(1'b1, value[j]);
            if (insert_gaps && (j == 5 || j == 2))
                step(1'b0, 1'b1); // invalid bit must be ignored
        end
    endtask

    initial begin
        if ($test$plusargs("WAVES")) begin
            $dumpfile("crc8.vcd");
            $dumpvars(0, tb_crc8);
        end

        reset_dut();
        send_byte_msb(8'h31, 1'b1);
        if (crc !== 8'h97 || crc_valid !== 1'b1)
            $fatal(1, "Known-vector 0x31 FAIL: crc=%h", crc);
        step(1'b0, 1'b1); // pulse must deassert and CRC must hold

        reset_dut();
        send_byte_msb(8'h00, 1'b0);
        if (crc !== 8'h00) $fatal(1, "Known-vector 0x00 FAIL");

        reset_dut();
        send_byte_msb(8'h01, 1'b0);
        if (crc !== 8'h07) $fatal(1, "Known-vector 0x01 FAIL");

        // Standard CRC-8/SMBus test: ASCII "123456789" => 0xF4.
        reset_dut();
        for (int i = 0; i < 9; i++)
            send_byte_msb(8'(8'h31 + i), i % 2 == 0);
        if (crc !== 8'hF4)
            $fatal(1, "CRC-8/SMBus known-vector FAIL: expected F4 got %02h", crc);

        // Random valid bits, stalls, continuous 8-bit boundaries.
        for (int i = 0; i < 100; i++)
            step($urandom_range(0,1), $urandom_range(0,1));

        $display("CRC8 ALL TESTS PASSED, checked %0d cycles", cycles);
        $finish;
    end
endmodule
