-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 23.10.2020 18:41:19 UTC

library ieee;
use ieee.std_logic_1164.all;
use work.LCSE_PKG.all;
use IEEE.numeric_std.all;


entity tb_MCU is
end tb_MCU;

architecture tb of tb_MCU is

    component MCU
        port (Clk_100Mhz   : in std_logic;
              Reset : in std_logic;
--              TX    : out std_logic;
--              RX    : in std_logic;
              GPIOA : inout std_logic_vector (7 downto 0);
              GPIOB : inout std_logic_vector (7 downto 0));
    end component;

    signal Clk   : std_logic;
    signal Reset : std_logic;
    signal TX    : std_logic;
    signal RX    : std_logic;
    signal GPIOA : std_logic_vector (7 downto 0);
    signal GPIOB : std_logic_vector (7 downto 0);

    constant TbPeriod : time := 10 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    
    constant inPeriod : time := 10us; -- EDIT Put right period here
    signal gpioClk : std_logic := '0';
    
    
    signal TbSimEnded : std_logic := '0';

    signal send_en : std_logic := '0';
    signal cmd    : std_logic_vector(0 downto 6) ;
    
begin

    dut : MCU
    port map (Clk_100Mhz   => Clk,
              Reset => Reset,
--              TX    => TX,
--              RX    => RX,
              GPIOA => GPIOA,
              GPIOB => GPIOB);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    
    gpioClk <= not gpioClk after inPeriod/2 when TbSimEnded /= '1' else '0';
    GPIOB(7) <= gpioClk;
    -- EDIT: Check that Clk is really your main clock signal
    Clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        RX <= '0';
        GPIOB <= (others => 'Z');
        GPIOA(1) <= '1';
        -- Reset generation
        -- EDIT: Check that Reset is really your reset signal
        Reset <= '1';
        wait for 100 ns;
        Reset <= '0';
        wait for 125 ns;
        
           
        
        GPIOA(1) <= '1';
        
        send_string("GCA60"&lf, GPIOA(1));
        send_string("GSA6"&lf, GPIOA(1));
        send_string("GRA6"&lf, GPIOA(1));     
        send_string("GCB72"&lf, GPIOA(1));
        send_string("GCB71"&lf, GPIOA(1));
        send_string("GCB71"&lf, GPIOA(1));
        send_string("GCB31"&lf, GPIOA(1));
        
        
        
        
        wait;
    end process;

end tb;


