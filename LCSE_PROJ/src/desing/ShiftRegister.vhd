----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  Alejandro Gomez Molina
-- 
-- Create Date: 20.09.2020 12:05:27
-- Design Name: 
-- Module Name: ShiftRegister - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ShiftRegister is
    Port ( Clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Enable: in STD_LOGIC;
           D : in STD_LOGIC;
           Q : out STD_LOGIC_VECTOR (7 downto 0));
end ShiftRegister;

architecture Behavioral of ShiftRegister is

signal Q_new  : STD_LOGIC_VECTOR(7 downto 0);

begin

shift: Process( Clk, Reset, Enable, D, Q_new) is
begin

if( Reset = '0' ) then
    Q_new  <= (others => '0');

elsif( Clk'event and Clk = '1' ) then
    if (Enable = '1') then
        Q_new  <= D&Q_new( 7 downto 1 );
    end if;  
end if;

Q <= Q_new;

end process;

end Behavioral;
