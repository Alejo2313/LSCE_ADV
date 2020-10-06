library ieee;
use ieee.std_logic_1164.all;

entity tb_ShiftRegister is
end tb_ShiftRegister;

architecture tb of tb_ShiftRegister is

    component ShiftRegister
        port (Clk    : in std_logic;
              Reset  : in std_logic;
              Enable : in std_logic;
              D      : in std_logic;
              Q      : out std_logic_vector (7 downto 0));
    end component;

    signal Clk    : std_logic;
    signal Reset  : std_logic;
    signal Enable : std_logic;
    signal D      : std_logic;
    signal Q      : std_logic_vector (7 downto 0);

    constant TbPeriod : time := 50 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : ShiftRegister
    port map (Clk    => Clk,
              Reset  => Reset,
              Enable => Enable,
              D      => D,
              Q      => Q);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that Clk is really your main clock signal
    Clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        Enable <= '0';
        D <= '0';

        -- Reset generation
        -- EDIT: Check that Reset is really your reset signal
        Reset <= '1';
        wait for 100 ns;
        Reset <= '0';
        wait for 100 ns;

        
        
        D <= '1';
        wait for 100 ns;
        Enable <= '1';
        wait for 50ns;
        D <= '0';
        wait for 100 ns;
        

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

