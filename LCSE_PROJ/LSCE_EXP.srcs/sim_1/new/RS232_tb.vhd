
-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 16.10.2020 20:24:22 UTC

library ieee;
use ieee.std_logic_1164.all;
use work.LCSE_PKG.all;

entity tb_RS232top is
end tb_RS232top;

architecture tb of tb_RS232top is

    component RS232top
        port (Reset     : in std_logic;
              Clk       : in std_logic;
              TX        : out std_logic;
              RX        : in std_logic;
              DMA_TX    : out std_logic;
              DMA_RX    : out std_logic;
              IRQ_TX    : out std_logic;
              IRQ_RX    : out std_logic;
              Address_s : in std_logic_vector (7 downto 0);
              InBus_s   : in std_logic_vector (7 downto 0);
              OutBus_s  : out std_logic_vector (7 downto 0);
              WE_s      : in std_logic;
              RE_s      : in std_logic);
    end component;

    signal Reset     : std_logic;
    signal Clk       : std_logic;
    signal TX        : std_logic;
    signal RX        : std_logic;
    signal DMA_TX    : std_logic;
    signal DMA_RX    : std_logic;
    signal IRQ_TX    : std_logic;
    signal IRQ_RX    : std_logic;
    signal Address_s : std_logic_vector (7 downto 0);
    signal InBus_s   : std_logic_vector (7 downto 0);
    signal OutBus_s  : std_logic_vector (7 downto 0);
    signal WE_s      : std_logic;
    signal RE_s      : std_logic;

    constant TbPeriod : time := 50 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : RS232top
    port map (Reset     => Reset,
              Clk       => Clk,
              TX        => TX,
              RX        => RX,
              DMA_TX    => DMA_TX,
              DMA_RX    => DMA_RX,
              IRQ_TX    => IRQ_TX,
              IRQ_RX    => IRQ_RX,
              Address_s => Address_s,
              InBus_s   => InBus_s,
              OutBus_s  => OutBus_s,
              WE_s      => WE_s,
              RE_s      => RE_s);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that Clk is really your main clock signal
    Clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        RX <= '1';
        Address_s <= (others => '0');
        InBus_s <= (others => '0');
        WE_s <= '0';
        RE_s <= '0';

        -- Reset generation
        -- EDIT: Check that Reset is really your reset signal
        Reset <= '1';
        wait for 100 ns;
        Reset <= '0';
        wait for 90 ns;

       Address_s <= std_logic_vector(RS232_TX_DATA);
       InBus_s    <= "10101010";
       WE_s     <= '1';
       wait for TbPeriod; 
       WE_s     <= '0';
       wait for TbPeriod;
       
       Address_s <= std_logic_vector(RS232_CONF);
       InBus_s    <= "01001111";
       WE_s     <= '1';
       wait for TbPeriod; 
       WE_s     <= '0';
       wait for TbPeriod;      
       
        -- Stop the clock and hence terminate the simulation
       RX <= '1',
           '0' after 500 ns,    -- StartBit
           '1' after 9150 ns,   -- LSb
           '0' after 17800 ns,
           '0' after 26450 ns,
           '1' after 35100 ns,
           '1' after 43750 ns,
           '1' after 52400 ns,
           '1' after 61050 ns,
           '0' after 69700 ns,  -- MSb
           '1' after 78350 ns,  -- Stopbit
           '1' after 87000 ns;
        wait;
        
        RX <= '1';
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_RS232top of tb_RS232top is
    for tb
    end for;
end cfg_tb_RS232top;