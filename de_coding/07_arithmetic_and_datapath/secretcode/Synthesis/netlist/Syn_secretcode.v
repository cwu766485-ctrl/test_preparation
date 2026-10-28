/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : R-2020.09-SP4
// Date      : Tue Oct 20 15:47:02 2026
/////////////////////////////////////////////////////////////


module secretcode ( clk, rst_n, digit_valid, digit, relock, unlocked, 
        locked_out, error_pulse );
  input [3:0] digit;
  input clk, rst_n, digit_valid, relock;
  output unlocked, locked_out, error_pulse;
  wire   N44, n30, n31, n32, n33, n34, n35, n38, n39, n40, n41, n42, n43, n44,
         n45, n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58,
         n59, n60, n61, n62, n63;
  wire   [2:0] state;
  wire   [2:0] failures;

  HDBSLT20_FDPRBQ_V2_1 \state_reg[2]  ( .D(n33), .CK(clk), .RD(rst_n), .Q(
        state[2]) );
  HDBSLT20_FDPRBQ_V2_1 \failures_reg[2]  ( .D(n34), .CK(clk), .RD(rst_n), .Q(
        failures[2]) );
  HDBSLT20_FDPRBQ_V2_1 \failures_reg[1]  ( .D(n30), .CK(clk), .RD(rst_n), .Q(
        failures[1]) );
  HDBSLT20_FDPRBQ_V2_1 \failures_reg[0]  ( .D(n35), .CK(clk), .RD(rst_n), .Q(
        failures[0]) );
  HDBSLT20_FDPRBQ_V2_1 \state_reg[1]  ( .D(n31), .CK(clk), .RD(rst_n), .Q(
        state[1]) );
  HDBSLT20_FDPRBQ_V2_1 \state_reg[0]  ( .D(n32), .CK(clk), .RD(rst_n), .Q(
        state[0]) );
  HDBSLT20_FDPRBQ_V2_1 error_pulse_reg ( .D(N44), .CK(clk), .RD(rst_n), .Q(
        error_pulse) );
  HDBSLT20_MUXI2_1 U41 ( .D0(n38), .D1(n39), .S(failures[0]), .X(n35) );
  HDBSLT20_ND2_0P75 U42 ( .A1(n39), .A2(n40), .X(n38) );
  HDBSLT20_MUXI2_1 U43 ( .D0(n41), .D1(n42), .S(failures[2]), .X(n34) );
  HDBSLT20_AOI21_0P5 U44 ( .A1(n40), .A2(n43), .B(n44), .X(n42) );
  HDBSLT20_OR2_0P75 U45 ( .A1(n45), .A2(n43), .X(n41) );
  HDBSLT20_INV_0P75 U46 ( .A(failures[1]), .X(n43) );
  HDBSLT20_AO221_0P5 U47 ( .A1(state[2]), .A2(n46), .B1(N44), .B2(n47), .C(n48), .X(n33) );
  HDBSLT20_AO221_0P5 U48 ( .A1(state[0]), .A2(n46), .B1(N44), .B2(n47), .C(n49), .X(n32) );
  HDBSLT20_INV_0P75 U49 ( .A(n50), .X(n47) );
  HDBSLT20_MUXI2_1 U50 ( .D0(n51), .D1(n52), .S(state[1]), .X(n31) );
  HDBSLT20_NR2_1 U51 ( .A1(n49), .A2(n46), .X(n52) );
  HDBSLT20_AOI21_0P5 U52 ( .A1(relock), .A2(unlocked), .B(n53), .X(n46) );
  HDBSLT20_NR2_1 U53 ( .A1(n54), .A2(state[0]), .X(unlocked) );
  HDBSLT20_NR3_0P75 U54 ( .A1(n55), .A2(state[0]), .A3(n40), .X(n49) );
  HDBSLT20_MUXI2_1 U55 ( .D0(n45), .D1(n56), .S(failures[1]), .X(n30) );
  HDBSLT20_INV_0P75 U56 ( .A(n44), .X(n56) );
  HDBSLT20_OAI21_0P5 U57 ( .A1(failures[0]), .A2(n57), .B(n39), .X(n44) );
  HDBSLT20_ND3_0P75 U58 ( .A1(n39), .A2(n40), .A3(failures[0]), .X(n45) );
  HDBSLT20_INV_0P75 U59 ( .A(n57), .X(n40) );
  HDBSLT20_AO21_0P5 U60 ( .A1(n50), .A2(N44), .B(n48), .X(n39) );
  HDBSLT20_NR2B_0P5 U61 ( .A(state[1]), .B(n51), .X(n48) );
  HDBSLT20_ND3_0P75 U62 ( .A1(n53), .A2(state[0]), .A3(n57), .X(n51) );
  HDBSLT20_INV_0P75 U63 ( .A(n55), .X(n53) );
  HDBSLT20_OR3B_0P5 U64 ( .B1(failures[0]), .B2(failures[1]), .A(failures[2]), 
        .X(n50) );
  HDBSLT20_NR2B_0P5 U65 ( .A(state[0]), .B(n54), .X(locked_out) );
  HDBSLT20_NR2_1 U66 ( .A1(n55), .A2(n57), .X(N44) );
  HDBSLT20_NR4_0P5 U67 ( .A1(n58), .A2(n59), .A3(state[2]), .A4(digit[3]), .X(
        n57) );
  HDBSLT20_MUXI2_1 U68 ( .D0(n60), .D1(n61), .S(state[1]), .X(n59) );
  HDBSLT20_OA21B_0P5 U69 ( .A1(digit[1]), .A2(digit[2]), .B(digit[0]), .X(n61)
         );
  HDBSLT20_NR2_1 U70 ( .A1(digit[1]), .A2(digit[2]), .X(n60) );
  HDBSLT20_MUXI2_1 U71 ( .D0(n62), .D1(n63), .S(state[0]), .X(n58) );
  HDBSLT20_OA21B_0P5 U72 ( .A1(digit[0]), .A2(digit[2]), .B(digit[1]), .X(n63)
         );
  HDBSLT20_NR2_1 U73 ( .A1(digit[0]), .A2(digit[2]), .X(n62) );
  HDBSLT20_ND2_0P75 U74 ( .A1(digit_valid), .A2(n54), .X(n55) );
  HDBSLT20_ND2B_0P5 U75 ( .A(state[1]), .B(state[2]), .X(n54) );
endmodule

