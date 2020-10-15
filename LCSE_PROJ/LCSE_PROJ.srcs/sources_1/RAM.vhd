
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.std_logic_unsigned.all;
USE work.PIC_pkg.all;

ENTITY ram IS
PORT (
   Clk      : in    std_logic;
   write_en : in    std_logic;
   oe       : in    std_logic;
   address  : in    std_logic_vector(7 downto 0);
   databus  : inout std_logic_vector(7 downto 0));
END ram;

ARCHITECTURE behavior OF ram IS

  SIGNAL contents_ram : array8_ram(191 downto 0); -- 0xFF-0x40 =0xBF 

BEGIN

-------------------------------------------------------------------------
-- Memoria de propósito general
-------------------------------------------------------------------------
p_ram : process (clk)  -- no reset
begin
  if clk'event and clk = '1' then
    if write_en = '1' then
      contents_ram(conv_Integer(address)) <= databus;
    end if;
  end if;

end process;

databus <= contents_ram(conv_integer(address)) when oe = '0' else (others => 'Z');
END behavior;

