-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 23.10.2020 17:50:34 UTC

library ieee;
use ieee.std_logic_1164.all;

entity tb_IRQ is
end tb_IRQ;

architecture tb of tb_IRQ is

    component IRQ
        port (Clk       : in std_logic;
              Reset     : in std_logic;
              Address_s : in std_logic_vector (7 downto 0);
              InBus_s   : in std_logic_vector (7 downto 0);
              outBus_s  : out std_logic_vector (7 downto 0);
              WE_s      : in std_logic;
              RE_s      : in std_logic;
              IRQV      : in std_logic_vector (7 downto 0);
              IRQ_E     : out std_logic);
    end component;

    signal Clk       : std_logic;
    signal Reset     : std_logic;
    signal Address_s : std_logic_vector (7 downto 0);
    signal InBus_s   : std_logic_vector (7 downto 0);
    signal outBus_s  : std_logic_vector (7 downto 0);
    signal WE_s      : std_logic;
    signal RE_s      : std_logic;
    signal IRQV      : std_logic_vector (7 downto 0);
    signal IRQ_E     : std_logic;

    constant TbPeriod : time := 50 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : IRQ
    port map (Clk       => Clk,
              Reset     => Reset,
              Address_s => Address_s,
              InBus_s   => InBus_s,
              outBus_s  => outBus_s,
              WE_s      => WE_s,
              RE_s      => RE_s,
              IRQV      => IRQV,
              IRQ_E     => IRQ_E);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that Clk is really your main clock signal
    Clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        Address_s <= (others => '1');
        InBus_s <= (others => '0');
        WE_s <= '0';
        RE_s <= '0';
        IRQV <= (others => '0');

        -- Reset generation
        -- EDIT: Check that Reset is really your reset signal
        Reset <= '1';
        wait for 100 ns;
        Reset <= '0';
        wait for 125 ns;

        -- EDIT Add stimuli here
        wait for 50 ns;
        IRQV <= x"01";
        wait for 50 ns;
        IRQV <= x"02";
        wait for 50 ns;
        IRQV <= x"04";
        wait for 50 ns;
        IRQV <= x"00";
        wait for 50 ns;
        Address_s <= (others => '0');
        InBus_s <= (others => '0');
        WE_s <= '1';
        wait for 50 ns;
        WE_s <= '0';
        
        -- Stop the clock and hence terminate the simulation
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_IRQ of tb_IRQ is
    for tb
    end for;
end cfg_tb_IRQ;