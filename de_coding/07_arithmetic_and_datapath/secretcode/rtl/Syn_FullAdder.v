/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : R-2020.09-SP4
// Date      : Wed Oct 14 14:48:29 2026
/////////////////////////////////////////////////////////////


module FullAdder ( CIN, A, B, S, COUT );
  input CIN, A, B;
  output S, COUT;
  wire   n2;

  HDBSLT20_EO2_V2_0P5 U4 ( .A1(CIN), .A2(n2), .X(S) );
  HDBSLT20_AO22_1 U5 ( .A1(B), .A2(A), .B1(n2), .B2(CIN), .X(COUT) );
  HDBSLT20_EO2_V2_0P5 U6 ( .A1(A), .A2(B), .X(n2) );
endmodule

