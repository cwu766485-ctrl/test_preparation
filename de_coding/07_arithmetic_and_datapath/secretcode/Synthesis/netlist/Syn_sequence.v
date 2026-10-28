/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : R-2020.09-SP4
// Date      : Tue Oct 20 11:18:15 2026
/////////////////////////////////////////////////////////////


module sequence ( clk, rst_n, en, bit_in, detected );
  input clk, rst_n, en, bit_in;
  output detected;
  wire   \next_state[0] , N18, n7, n8, n9, n10, n11, n12, n13;
  wire   [1:0] state;
  assign \next_state[0]  = bit_in;

  HDBSLT20_FDPRBQ_V2_1 \state_reg[0]  ( .D(n8), .CK(clk), .RD(rst_n), .Q(
        state[0]) );
  HDBSLT20_FDPRBQ_V2_1 \state_reg[1]  ( .D(n7), .CK(clk), .RD(rst_n), .Q(
        state[1]) );
  HDBSLT20_FDPRBQ_V2_1 detected_reg ( .D(N18), .CK(clk), .RD(rst_n), .Q(
        detected) );
  HDBSLT20_MUXI2_1 U11 ( .D0(n9), .D1(n10), .S(en), .X(n8) );
  HDBSLT20_OAI32_1 U12 ( .A1(n9), .A2(\next_state[0] ), .A3(n11), .B1(n12), 
        .B2(n13), .X(n7) );
  HDBSLT20_AOI21_0P5 U13 ( .A1(\next_state[0] ), .A2(n9), .B(n11), .X(n12) );
  HDBSLT20_NR4_0P5 U14 ( .A1(n11), .A2(n10), .A3(n9), .A4(n13), .X(N18) );
  HDBSLT20_INV_0P75 U15 ( .A(state[1]), .X(n13) );
  HDBSLT20_INV_0P75 U16 ( .A(state[0]), .X(n9) );
  HDBSLT20_INV_0P75 U17 ( .A(\next_state[0] ), .X(n10) );
  HDBSLT20_INV_0P75 U18 ( .A(en), .X(n11) );
endmodule

