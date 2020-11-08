-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
-- Date        : Sun Nov  8 16:11:06 2020
-- Host        : DESKTOP-U9SF4CB running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               d:/OneDrive/Documentos/Universidad/LCSE/entregas/LCSE_PROJ/LCSE_EXP.srcs/sources_1/ip/clk_20Mhz/clk_20Mhz_stub.vhdl
-- Design      : clk_20Mhz
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_20Mhz is
  Port ( 
    Clk : out STD_LOGIC;
    reset : in STD_LOGIC;
    Clk_100Mhz : in STD_LOGIC
  );

end clk_20Mhz;

architecture stub of clk_20Mhz is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "Clk,reset,Clk_100Mhz";
begin
end;
