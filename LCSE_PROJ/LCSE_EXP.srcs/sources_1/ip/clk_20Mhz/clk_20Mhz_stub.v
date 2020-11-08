// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
// Date        : Sun Nov  8 16:11:06 2020
// Host        : DESKTOP-U9SF4CB running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/OneDrive/Documentos/Universidad/LCSE/entregas/LCSE_PROJ/LCSE_EXP.srcs/sources_1/ip/clk_20Mhz/clk_20Mhz_stub.v
// Design      : clk_20Mhz
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_20Mhz(Clk, reset, Clk_100Mhz)
/* synthesis syn_black_box black_box_pad_pin="Clk,reset,Clk_100Mhz" */;
  output Clk;
  input reset;
  input Clk_100Mhz;
endmodule
