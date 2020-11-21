// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
// Date        : Tue Nov 17 19:54:32 2020
// Host        : DESKTOP-U9SF4CB running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top clk_20Mhz -prefix
//               clk_20Mhz_ clk_20Mhz_stub.v
// Design      : clk_20Mhz
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_20Mhz(clk, reset, clk_100Mhz)
/* synthesis syn_black_box black_box_pad_pin="clk,reset,clk_100Mhz" */;
  output clk;
  input reset;
  input clk_100Mhz;
endmodule
