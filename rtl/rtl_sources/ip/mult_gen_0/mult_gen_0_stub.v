// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.2 (lin64) Build 1909853 Thu Jun 15 18:39:10 MDT 2017
// Date        : Mon Nov 27 23:07:06 2017
// Host        : artemis.andrew.local.cmu.edu running 64-bit Red Hat Enterprise Linux Server release 7.4 (Maipo)
// Command     : write_verilog -force -mode synth_stub
//               /afs/ece.cmu.edu/usr/akuntz/testing_rtl/testing_rtl.srcs/sources_1/ip/mult_gen_0/mult_gen_0_stub.v
// Design      : mult_gen_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx485tffg1157-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "mult_gen_v12_0_12,Vivado 2017.2" *)
module mult_gen_0(CLK, A, B, CE, P)
/* synthesis syn_black_box black_box_pad_pin="CLK,A[31:0],B[31:0],CE,P[63:0]" */;
  input CLK;
  input [31:0]A;
  input [31:0]B;
  input CE;
  output [63:0]P;
endmodule
