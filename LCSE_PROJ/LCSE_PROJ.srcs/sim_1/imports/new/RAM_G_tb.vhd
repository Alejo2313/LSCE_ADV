----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.10.2020 15:10:04
-- Design Name: 
-- Module Name: RAM_G_tb - Behavioral
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
use work.PIC_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RAM_G_tb is
--  Port ( );
end RAM_G_tb;

architecture Behavioral of RAM_G_tb is

    component ram
        port (Clk      : in std_logic;
              write_en : in std_logic;
              oe       : in std_logic;
              address  : in std_logic_vector (7 downto 0);
              databus  : inout std_logic_vector (7 downto 0));
    end component;
    
    signal Clk      : std_logic;
    signal write_en : std_logic;
    signal oe       : std_logic;
    signal address  : std_logic_vector (7 downto 0);
    signal databus  : std_logic_vector (7 downto 0);

    constant TbPeriod : time := 20 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';    
begin

   dut : ram
    port map (Clk      => Clk,
              write_en => write_en,
              oe       => oe,
              address  => address,
              databus  => databus);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that Clk is really your main clock signal
    Clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        write_en <= '0';
        oe <= '0';
        address <= (others => '0');
        databus <= (others => '0');

        -- EDIT Add stimuli here
        wait for 10 *TbPeriod;
        write_en <= '1';
        oe <= '1';
        wait for 10 ns;
        address <= X"FF";
        databus <= X"4F";        
        wait for 10 ns;
        databus <= X"FF";
        wait for 10 ns;
        oe <= '0';
        wait for 10 ns;
        -- Stop the clock and hence terminate the simulation
        wait;
    end process;

end Behavioral;
