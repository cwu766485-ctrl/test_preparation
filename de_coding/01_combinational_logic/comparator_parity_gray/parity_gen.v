module parity_gen (
    input  [7:0] data,
    output       even_p,
    output       odd_p
);

assign even_p =  ^data;
assign odd_p  = ~^data;

endmodule