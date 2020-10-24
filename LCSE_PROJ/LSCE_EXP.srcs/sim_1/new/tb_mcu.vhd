-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 23.10.2020 18:41:19 UTC

library ieee;
use ieee.std_logic_1164.all;

entity tb_MCU is
end tb_MCU;

architecture tb of tb_MCU is

    component MCU
        port (Clk   : in std_logic;
              Reset : in std_logic;
              TX    : out std_logic;
              RX    : in std_logic;
              GPIOA : inout std_logic_vector (7 downto 0);
              GPIOB : inout std_logic_vector (7 downto 0));
    end component;

    signal Clk   : std_logic;
    signal Reset : std_logic;
    signal TX    : std_logic;
    signal RX    : std_logic;
    signal GPIOA : std_logic_vector (7 downto 0);
    signal GPIOB : std_logic_vector (7 downto 0);

    constant TbPeriod : time := 50 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : MCU
    port map (Clk   => Clk,
              Reset => Reset,
              TX    => TX,
              RX    => RX,
              GPIOA => GPIOA,
              GPIOB => GPIOB);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that Clk is really your main clock signal
    Clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        RX <= '0';
        GPIOB <= (others => 'Z');
        -- Reset generation
        -- EDIT: Check that Reset is really your reset signal
        Reset <= '1';
        wait for 100 ns;
        Reset <= '0';
        wait for 125 ns;
        
        wait for 4000 ns;
        GPIOB(7) <= '1'; 
        wait for 1000 ns;
        GPIOB(7) <= '0';
        wait for 1000 ns;
        GPIOB(7) <= '1';
        wait for 1000 ns;
        GPIOB(7) <= '0';
        wait for 1000 ns;
        GPIOB(7) <= '1'; 
        wait for 1000 ns;
        GPIOB(7) <= '0';
        wait for 1000 ns;
        GPIOB(7) <= '1';
        wait for 1000 ns;
        GPIOB(7) <= '0';
        wait for 1000 ns;        
        
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_MCU of tb_MCU is
    for tb
    end for;
end cfg_tb_MCU;