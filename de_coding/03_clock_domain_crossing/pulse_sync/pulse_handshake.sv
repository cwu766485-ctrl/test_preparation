// Lossless for ACCEPTED source pulses. A pulse presented while src_ready=0
// is not accepted; hold it or queue it in the source domain if it must survive.
module pulse_handshake (
    input  logic src_clk,
    input  logic dst_clk,
    input  logic rst_n,
    input  logic pulse_i,
    output logic src_ready,
    output logic pulse_o
);
    logic unused_data;
    multi_bit_synchronizer #(.W(1)) u_event (
        .src_clk(src_clk), .dst_clk(dst_clk), .rst_n(rst_n),
        .src_valid(pulse_i), .src_data(1'b0), .src_ready(src_ready),
        .dst_valid(pulse_o), .dst_data(unused_data)
    );
endmodule
