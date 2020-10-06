library ieee;
use ieee.std_logic_1164.all;

entity tb_RS232_TX is
end tb_RS232_TX;

architecture tb of tb_RS232_TX is

    component RS232_TX
        port (Clk   : in std_logic;
              Reset : in std_logic;
              Start : in std_logic;
              Data  : in std_logic_vector (7 downto 0);
              EOT   : out std_logic;
              TX    : out std_logic);
    end component;

    signal Clk   : std_logic;
    signal Reset : std_logic;
    signal Start : std_logic;
    signal Data  : std_logic_vector (7 downto 0);
    signal EOT   : std_logic;
    signal TX    : std_logic;

    constant TbPeriod : time := 50 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : RS232_TX
    port map (Clk   => Clk,
              Reset => Reset,
              Start => Start,
              Data  => Data,
              EOT   => EOT,
              TX    => TX);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that Clk is really your main clock signal
    Clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        Start <= '0';
        Data <= (others => '0');

        -- Reset generation
        -- EDIT: Check that Reset is really your reset signal
        Reset <= '1';
        wait for 110 ns;
        Reset <= '0';
        wait for 100 ns;

        Data <= "10101010";
        Start <= '1';
        wait for 100 ns;
        Start <= '0';
        -- EDIT Add stimuli here
        
        wait for 150us;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_RS232_TX of tb_RS232_TX is
    for tb
    end for;
end cfg_tb_RS232_TX;