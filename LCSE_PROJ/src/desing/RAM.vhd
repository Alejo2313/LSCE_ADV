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
   inbus    : in    std_logic_vector(7 downto 0);
   outBus   : out   std_logic_vector(7 downto 0));
END ram;
  
ARCHITECTURE behavior OF ram IS

  SIGNAL contents_ram, contents_ram_n : array8_ram(to_integer(eRAM - sRAM - 1) downto 0);
  SIGNAL inBound                      : std_logic;
  SIGNAL rAdrress                     : UNSIGNED( 7 downto 0);
  SIGNAL inBus_reg, inBus_reg_n       : std_logic_vector( 7 downto 0);
  SIGNAL outBus_reg, outBus_reg_n     : std_logic_vector( 7 downto 0);
BEGIN



FF : process (clk, reset)  -- no rest
begin
    
  if ( clk'event and clk = '1' ) then
        contents_ram <= contents_ram_n;
  end if;

end process;

LOGIC: process (write_en, inbus, oe, address, contents_ram) is

begin
    contents_ram_n <= contents_ram;
    outBus <= (others => 'Z');
    -- Check if adress is in bound
    if (unsigned(address) >= sRAM AND unsigned(address) < eRAM ) then
        if ( write_en = '1' ) then
            contents_ram_n(to_integer(unsigned(address) - sRAM))<= inbus;
        elsif (oe = '1' ) then
            outBus <= contents_ram(to_integer(unsigned(address) - sRAM));
        end if;
    end if;  
    
end process;

END behavior;