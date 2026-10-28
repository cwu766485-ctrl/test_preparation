`timescale 1ns/1ns

module data_sel(
   input             S0     ,
   input             S1     ,
   input             D0     ,
   input             D1     ,
   input             D2     ,
   input             D3     ,
   
   output wire        Y    
);

assign Y = ~S1 & (~S0&D0 | S0&D1) | S1&(~S0&D2 | S0&D3);
     
endmodule

module sel_exp(
   input             A     ,
   input             B     ,
   input             C     ,
   
   output wire       L            
);


    wire C_n;

    // 产生 ~C
    not u_not_c(C_n, C);

    // 例化4选1数据选择器
    data_sel u_data_sel(
        .S1 (A),
        .S0 (B),

        .D0 (1'b0),
        .D1 (C),
        .D2 (C_n),
        .D3 (1'b1),

        .Y  (L)
    );

endmodule