// Lossless for ACCEPTED source pulses. A pulse presented while src_ready=0
// is not accepted; hold it or queue it in the source domain if it must survive.


module pulse_handshake (
    input wire src_clk,
    input wire dst_clk,
    input wire rst_n,
    input wire pulse_i,
    output wire src_ready,
    output wire pulse_o
);
    wire unused_data;
    multi_bit_synchronizer #(.W(1)) u_event (
        .src_clk(src_clk), .dst_clk(dst_clk), .rst_n(rst_n),
        .src_valid(pulse_i), .src_data(1'b0), .src_ready(src_ready),
        .dst_valid(pulse_o), .dst_data(unused_data)
    );
endmodule