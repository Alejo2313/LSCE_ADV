-makelib xcelium_lib/xpm -sv \
  "D:/Xilinx/Vivado/2020.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "D:/Xilinx/Vivado/2020.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../LCSE_PROJ.srcs/sources_1/ip/Clk_Gen/Clk_Gen_clk_wiz.v" \
  "../../../../LCSE_PROJ.srcs/sources_1/ip/Clk_Gen/Clk_Gen.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

