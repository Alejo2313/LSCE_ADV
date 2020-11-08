----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.10.2020 19:14:01
-- Design Name: 
-- Module Name: tb_display - Behavioral
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


library ieee;
use ieee.std_logic_1164.all;

entity tb_display is
end tb_display;

architecture tb of tb_display is

    component display
        port (Clk         : in std_logic;
              Reset       : in std_logic;
              Address_s   : in std_logic_vector (7 downto 0);
              InBus_s     : in std_logic_vector (7 downto 0);
              outBus_s    : out std_logic_vector (7 downto 0);
              WE_s        : in std_logic;
              RE_s        : in std_logic;
              out_display : out std_logic_vector (7 downto 0);
              anode       : out std_logic_vector (7 downto 0));
    end component;

    signal Clk         : std_logic;
    signal Reset       : std_logic;
    signal Address_s   : std_logic_vector (7 downto 0);
    signal InBus_s     : std_logic_vector (7 downto 0);
    signal outBus_s    : std_logic_vector (7 downto 0);
    signal WE_s        : std_logic;
    signal RE_s        : std_logic;
    signal out_display : std_logic_vector (7 downto 0);
    signal anode       : std_logic_vector (7 downto 0);

    constant TbPeriod : time := 10 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : display
    port map (Clk         => Clk,
              Reset       => Reset,
              Address_s   => Address_s,
              InBus_s     => InBus_s,
              outBus_s    => outBus_s,
              WE_s        => WE_s,
              RE_s        => RE_s,
              out_display => out_display,
              anode       => anode);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that Clk is really your main clock signal
    Clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        Address_s <= (others => '0');
        InBus_s <= (others => '0');
        WE_s <= '0';
        RE_s <= '0';

        -- Reset generation
        -- EDIT: Check that Reset is really your reset signal
        Reset <= '1';
        wait for 100 ns;
        Reset <= '0';
        wait for 100 ns;
        Address_s <= "11011001";   
        InBus_s <=   "11111101";
        wait for 20 ns;
        WE_s <= '1';
        wait for 20 ns;
        Address_s <= "11011000";   
        InBus_s <=   "10000000";
        wait for 20 ns;        
         Address_s <= "11011010";
         InBus_s <=   "00010010";
        wait for 20 ns;        
        Address_s <= "11011011";
        InBus_s <=   "00110100";
        wait for 20 ns;
        Address_s <= "11011100";
        InBus_s <=   "01010110";
        wait for 20 ns;
        wait for 20 ns;
        Address_s <= "11011101";
        InBus_s <=   "01111000";
        wait for 20 ns;
--        Address_s <= "11011111";
--        InBus_s <=   "01111000";
--        wait for 20 ns;
        wait;
    end process;

end tb;