library ieee;
use ieee.std_logic_1164.all;

entity tb_RS232_RX is
end tb_RS232_RX;

architecture tb of tb_RS232_RX is

    component RS232_RX
        port (Clk       : in std_logic;
              Reset     : in std_logic;
              LineRD_in : in std_logic;
              Valid_out : out std_logic;
              Code_out  : out std_logic;
              Store_out : out std_logic);
    end component;

    signal Clk       : std_logic;
    signal Reset     : std_logic;
    signal LineRD_in : std_logic;
    signal Valid_out : std_logic;
    signal Code_out  : std_logic;
    signal Store_out : std_logic;

    constant TbPeriod : time := 50 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : RS232_RX
    port map (Clk       => Clk,
              Reset     => Reset,
              LineRD_in => LineRD_in,
              Valid_out => Valid_out,
              Code_out  => Code_out,
              Store_out => Store_out);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that Clk is really your main clock signal
    Clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        LineRD_in <= '0';

        -- Reset generation
        -- EDIT: Check that Reset is really your reset signal
        LineRD_in <= '1';
        Reset <= '1';
        wait for 150 ns;
        Reset <= '0';
        wait for 100 ns;

        LineRD_in <= '0';
        wait for 8.68 us;
        
        LineRD_in <= '1';
        wait for 8.68 us;
        LineRD_in <= '0';
        wait for 8.68 us;
        LineRD_in <= '1';
        wait for 8.68 us;
        LineRD_in <= '0';
        wait for 8.68 us;
        LineRD_in <= '1';
        wait for 8.68 us;
        LineRD_in <= '0';
        wait for 8.68 us;
        LineRD_in <= '1';
        wait for 8.68 us;
        LineRD_in <= '0';
        wait for 8.68 us;
        
        LineRD_in <= '1';

        
        
        -- EDIT Add stimuli here
        wait for 500us;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

