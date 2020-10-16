LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.std_logic_unsigned.all;
use work.LCSE_PKG.all;

ENTITY ram IS
PORT (
   Clk      : in    std_logic;
   Reset    : in    std_logic;
   write_en : in    std_logic;
   oe       : in    std_logic;
   address  : in    std_logic_vector(7 downto 0);
   inbus    : in std_logic_vector(7 downto 0);
   outBus   : out std_logic_vector(7 downto 0));
END ram;

ARCHITECTURE behavior OF ram IS
    CONSTANT sRAM       : UNSIGNED( 7 downto 0) := X"10" ;
    CONSTANT eRAM       : UNSIGNED( 7 downto 0) := X"1F" ;
    
  SIGNAL contents_ram, contents_ram_n: array8_ram(to_integer(eRAM - sRAM - 1) downto 0);
  SIGNAL inBound      : std_logic;
  SIGNAL rAdrress     : UNSIGNED( 7 downto 0);


  SIGNAL inBus_reg, inBus_reg_n : std_logic_vector( 7 downto 0);
  SIGNAL outBus_reg, outBus_reg_n : std_logic_vector( 7 downto 0);
BEGIN

-------------------------------------------------------------------------
-- Memoria de propósito general
-------------------------------------------------------------------------



rAdrress <= unsigned(address) - sRAM when (inBound = '1') else
            (others => '0');
inBound <= '1' when (unsigned(address) >= sRAM AND unsigned(address) <= eRAM) else
           '0';   

p_ram : process (clk, reset)  -- no reset
begin
    
  if ( clk'event and clk = '1' ) then
        contents_ram <= contents_ram_n;
  end if;

end process;

LOGIC: process (write_en, inBound, oe, inbus) is

begin
    contents_ram_n <= contents_ram;
    
    if (unsigned(address) >= sRAM AND unsigned(address) <= eRAM) then
        if ( write_en = '1') then
            contents_ram_n(to_integer(unsigned(address) - sRAM))<= inbus;
        end if;
    end if;
end process;


            
    
outBus <= contents_ram(to_integer(unsigned(address) - sRAM)) when (oe = '1' AND inBound = '1' ) else
            (others => 'Z');
                    
-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- Decodificador de BCD a 7 segmentos
-------------------------------------------------------------------------
--with contents_ram()(7 downto 4) select
--Temp_H <=
--    "0000110" when "0001",  -- 1
--    "1011011" when "0010",  -- 2
--    "1001111" when "0011",  -- 3
--    "1100110" when "0100",  -- 4
--    "1101101" when "0101",  -- 5
--    "1111101" when "0110",  -- 6
--    "0000111" when "0111",  -- 7
--    "1111111" when "1000",  -- 8
--    "1101111" when "1001",  -- 9
--    "1110111" when "1010",  -- A
--    "1111100" when "1011",  -- B
--    "0111001" when "1100",  -- C
--    "1011110" when "1101",  -- D
--    "1111001" when "1110",  -- E
--    "1110001" when "1111",  -- F
--    "0111111" when others;  -- 0
-------------------------------------------------------------------------

END behavior;