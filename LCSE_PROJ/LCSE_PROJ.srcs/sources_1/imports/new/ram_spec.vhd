----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Alejandro Gomez Molina
-- Engineer: Luis Felipe Velez Flores 
-- Create Date: 13.10.2020 15:39:36
-- Design Name: 
-- Module Name: ram_spec - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- Ram for specific use function. It uses an asynchronous reset that
-- initializates the specific memory adresses. 
-- Dependencies: 
-- use IEEE library and PIC_pkg in order to use constans defined there.
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.std_logic_unsigned.all;
USE work.PIC_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ram_spec is
PORT(
   Clk      : in    std_logic;
   Reset    : in    std_logic;
   write_en : in    std_logic;
   oe       : in    std_logic;
   address  : in    std_logic_vector(7 downto 0);
   databus  : inout std_logic_vector(7 downto 0);
   switches : out std_logic_vector(7 downto 0);
   Temp_L   : out std_logic_vector(6 downto 0);
   Temp_H   : out std_logic_vector(6 downto 0));
end ram_spec;

architecture Behavioral of ram_spec is
    SIGNAL contents_ram : array8_ram(63 downto 0);
begin
    process (Clk,Reset)
    begin
        if (Reset = '0') then
            contents_ram <= (others => (others => '0'));
            contents_ram(conv_Integer(T_STAT)) <=  X"18"; -- 18 degrees 
--            contents_ram(conv_Integer(DMA_RX_BUFFER_MSB)) <=  X"00";
--            contents_ram(conv_Integer(DMA_RX_BUFFER_MID)) <=  X"00";
--            contents_ram(conv_Integer(DMA_RX_BUFFER_LSB)) <=  X"00";
--            contents_ram(conv_Integer(NEW_INST)) <=  X"00";
--            contents_ram(conv_Integer(DMA_TX_BUFFER_MSB)) <=  X"00";
--            contents_ram(conv_Integer(DMA_TX_BUFFER_LSB)) <=  X"00";
            
--            contents_ram(conv_Integer(SWITCH_BASE)) <=  X"00";
--            contents_ram(conv_Integer(SWITCH_BASE+1)) <=  X"00";
--            contents_ram(conv_Integer(SWITCH_BASE+2)) <=  X"00";
--            contents_ram(conv_Integer(SWITCH_BASE+3)) <=  X"00";
--            contents_ram(conv_Integer(SWITCH_BASE+4)) <=  X"00";
--            contents_ram(conv_Integer(SWITCH_BASE+5)) <=  X"00";
--            contents_ram(conv_Integer(SWITCH_BASE+6)) <=  X"00";
--            contents_ram(conv_Integer(SWITCH_BASE+7)) <=  X"00";
           
--            contents_ram(conv_Integer(LEVER_BASE)) <=  X"00";
--            contents_ram(conv_Integer(LEVER_BASE+1)) <=  X"00";
--            contents_ram(conv_Integer(LEVER_BASE+2)) <=  X"00";
--            contents_ram(conv_Integer(LEVER_BASE+3)) <=  X"00";
--            contents_ram(conv_Integer(LEVER_BASE+4)) <=  X"00";
--            contents_ram(conv_Integer(LEVER_BASE+5)) <=  X"00";
--            contents_ram(conv_Integer(LEVER_BASE+6)) <=  X"00";
--            contents_ram(conv_Integer(LEVER_BASE+7)) <=  X"00";
--            contents_ram(conv_Integer(LEVER_BASE+8)) <=  X"00";
--            contents_ram(conv_Integer(LEVER_BASE+9)) <=  X"00";   
       
               
                       
        elsif (Clk'event and Clk = '1') then
            if write_en = '1' then
              contents_ram(conv_Integer(address)) <= databus;
            end if;
        end if;
    end process;

databus <= contents_ram(conv_integer(address)) when oe = '0' else (others => 'Z');

---------------------------------------------------------------------------
---- Switches output
---------------------------------------------------------------------------
switches <= contents_ram(conv_integer(address)) when ((not (address(7) or address(6) or address(5)) and address(4)) = '1') else
            (others =>'0');
-------------------------------------------------------------------------

-- Decodificador de BCD a 7 segmentos
-------------------------------------------------------------------------
with contents_ram(conv_integer(T_STAT))(7 downto 4) select
Temp_H <=
    "0000110" when "0001",  -- 1
    "1011011" when "0010",  -- 2
    "1001111" when "0011",  -- 3
    "1100110" when "0100",  -- 4
    "1101101" when "0101",  -- 5
    "1111101" when "0110",  -- 6
    "0000111" when "0111",  -- 7
    "1111111" when "1000",  -- 8
    "1101111" when "1001",  -- 9
    "1110111" when "1010",  -- A
    "1111100" when "1011",  -- B
    "0111001" when "1100",  -- C
    "1011110" when "1101",  -- D
    "1111001" when "1110",  -- E
    "1110001" when "1111",  -- F
    "0111111" when others;  -- 0
    
with contents_ram(conv_integer(T_STAT))(3 downto 0) select
Temp_L <=
    "0000110" when "0001",  -- 1
    "1011011" when "0010",  -- 2
    "1001111" when "0011",  -- 3
    "1100110" when "0100",  -- 4
    "1101101" when "0101",  -- 5
    "1111101" when "0110",  -- 6
    "0000111" when "0111",  -- 7
    "1111111" when "1000",  -- 8
    "1101111" when "1001",  -- 9
    "1110111" when "1010",  -- A
    "1111100" when "1011",  -- B
    "0111001" when "1100",  -- C
    "1011110" when "1101",  -- D
    "1111001" when "1110",  -- E
    "1110001" when "1111",  -- F
    "0111111" when others;  -- 0    
-------------------------------------------------------------------------

end Behavioral;
