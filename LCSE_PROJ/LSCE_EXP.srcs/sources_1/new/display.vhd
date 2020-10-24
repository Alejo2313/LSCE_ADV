----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Alejandro Gomez Molina
-- Engineer: Luis Felipe Velez Flores
-- Create Date: 22.10.2020 15:52:03
-- Design Name: 
-- Module Name: display - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- Display configured with 6 registers of 8 bits. One for enable the entire device, another for activate the desired anode
-- (0 is for select), and the rest for passing the value in BCD (in each register there are two BDC words).
-- Dependencies: use LCSE_PKG in order to get the constanst needed and numeric_Std for math operations.
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.LCSE_PKG.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity display is
    Port ( Clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Address_s : in STD_LOGIC_VECTOR (7 downto 0);
           InBus_s : in STD_LOGIC_VECTOR (7 downto 0);
           outBus_s : out STD_LOGIC_VECTOR (7 downto 0);
           WE_s : in STD_LOGIC;
           RE_s : in STD_LOGIC;
           out_display : out STD_LOGIC_VECTOR(7 downto 0));
end display;

architecture Behavioral of display is
    type dev_mem_8 is array (0 to TO_INTEGER(eDISPLAY - sDISPLAY) ) of std_logic_vector(7 downto 0);
    
    signal mem_r,mem_n : dev_mem_8;
    signal outBus_r : STD_LOGIC_VECTOR(7 downto 0);
--    signal outDisp_r, outDisp_n : STD_LOGIC_VECTOR(7 downto 0);
    
--    signal index     : UNSIGNED((log2c(TO_INTEGER(eDISPLAY - sDISPLAY)) - 1) downto 0);
    
    --Components
    component decod7s 
        Port ( D : in  STD_LOGIC_VECTOR (3 downto 0);					
               S : out  STD_LOGIC_VECTOR (7 downto 0));   	
    end component;
    
    signal S                    : STD_LOGIC_VECTOR (7 downto 0);
    signal D                    : STD_LOGIC_VECTOR (3 downto 0);    
begin

    decoder: decod7s 
        port map ( D => D,
                   S => S);

 FF: process (Clk, Reset) is
 begin
    if (Reset = '1') then
        mem_r <= (others => (others => '0'));
        mem_r(TO_INTEGER(DISPLAY_ANODE - DISPLAY_BASE)) <= X"FF";
--        outDisp_r <= (others => '0');
--        index <= (others => '0');
    elsif (Clk'event and Clk = '1') then
        mem_r <= mem_n; 
--        outDisp_r <= outDisp_n; 
    end if;
 end process;
 
next_state: process(Address_s, inBus_s,WE_s, RE_s, mem_r) is
begin
--    index <= UNSIGNED(Address_s) - DISPLAY_BASE;
    outBus_r <= (others => 'Z');
    mem_n <= mem_r;
    
    if (WE_s = '1') then
        mem_n(TO_INTEGER(UNSIGNED(Address_s) - DISPLAY_BASE)) <= InBus_s;
    elsif (RE_s = '1') then
        outBus_r <= mem_r(TO_INTEGER(UNSIGNED(Address_s) - DISPLAY_BASE));
    end if;
    
--    if (mem_r()) then
--    else
--    end if;   
end process;

outBus_s <= outBus_r;



D <=  mem_r(TO_INTEGER(DISPLAY_01 - DISPLAY_BASE))(3 downto 0) when (mem_r(TO_INTEGER(DISPLAY_ANODE - DISPLAY_BASE))(0) = '0') else
      mem_r(TO_INTEGER(DISPLAY_01 - DISPLAY_BASE))(7 downto 4) when (mem_r(TO_INTEGER(DISPLAY_ANODE - DISPLAY_BASE))(1) = '0') else
      mem_r(TO_INTEGER(DISPLAY_23 - DISPLAY_BASE))(3 downto 0) when (mem_r(TO_INTEGER(DISPLAY_ANODE - DISPLAY_BASE))(2) = '0') else
      mem_r(TO_INTEGER(DISPLAY_23 - DISPLAY_BASE))(7 downto 4) when (mem_r(TO_INTEGER(DISPLAY_ANODE - DISPLAY_BASE))(3) = '0') else 
      mem_r(TO_INTEGER(DISPLAY_45 - DISPLAY_BASE))(3 downto 0) when (mem_r(TO_INTEGER(DISPLAY_ANODE - DISPLAY_BASE))(4) = '0') else
      mem_r(TO_INTEGER(DISPLAY_45 - DISPLAY_BASE))(7 downto 4) when (mem_r(TO_INTEGER(DISPLAY_ANODE - DISPLAY_BASE))(5) = '0') else
      mem_r(TO_INTEGER(DISPLAY_67 - DISPLAY_BASE))(3 downto 0) when (mem_r(TO_INTEGER(DISPLAY_ANODE - DISPLAY_BASE))(6) = '0') else
      mem_r(TO_INTEGER(DISPLAY_67 - DISPLAY_BASE))(7 downto 4) when (mem_r(TO_INTEGER(DISPLAY_ANODE - DISPLAY_BASE))(7) = '0') else
      "0000";           
end Behavioral;
