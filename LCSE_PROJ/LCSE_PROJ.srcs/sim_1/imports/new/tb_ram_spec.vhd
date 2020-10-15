library ieee;
use ieee.std_logic_1164.all;
use work.PIC_pkg.all;
entity tb_ram_spec is
end tb_ram_spec;

architecture tb of tb_ram_spec is

    component ram_spec
        port (Clk      : in std_logic;
              Reset    : in std_logic;
              write_en : in std_logic;
              oe       : in std_logic;
              address  : in std_logic_vector (7 downto 0);
              databus  : inout std_logic_vector (7 downto 0);
              switches : out std_logic_vector (7 downto 0);
              Temp_L   : out std_logic_vector (6 downto 0);
              Temp_H   : out std_logic_vector (6 downto 0));
    end component;

    signal Clk      : std_logic;
    signal Reset    : std_logic;
    signal write_en : std_logic;
    signal oe       : std_logic;
    signal address  : std_logic_vector (7 downto 0);
    signal databus  : std_logic_vector (7 downto 0);
    signal switches : std_logic_vector (7 downto 0);
    signal Temp_L   : std_logic_vector (6 downto 0);
    signal Temp_H   : std_logic_vector (6 downto 0);

    constant TbPeriod : time := 20 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : ram_spec
    port map (Clk      => Clk,
              Reset    => Reset,
              write_en => write_en,
              oe       => oe,
              address  => address,
              databus  => databus,
              switches => switches,
              Temp_L   => Temp_L,
              Temp_H   => Temp_H);

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

        -- Reset generation
        -- EDIT: Check that Reset is really your reset signal
        Reset <= '1';
        wait for 100 ns;
        Reset <= '0';
        wait for 100 ns;
        Reset <= '1';
        address <= T_STAT;
        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;