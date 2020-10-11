-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 10.10.2020 19:54:05 UTC

library ieee;
use ieee.std_logic_1164.all;

entity tb_DMA is
end tb_DMA;

architecture tb of tb_DMA is

    component DMA
        port (Reset     : in std_logic;
              Clk       : in std_logic;
              RCVD_Data : in std_logic_vector (7 downto 0);
              RX_Full   : in std_logic;
              RX_Empty  : in std_logic;
              Data_Read : out std_logic;
              ACK_out   : in std_logic;
              TX_RDY    : in std_logic;
              Valid_D   : out std_logic;
              TX_Data   : out std_logic_vector (7 downto 0);
              Address   : out std_logic_vector (7 downto 0);
              Databus   : inout std_logic_vector (7 downto 0);
              Write_en  : out std_logic;
              OE        : out std_logic;
              DMA_ACK   : in std_logic;
              Send_comm : in std_logic;
              DMA_RQ    : out std_logic;
              READY     : out std_logic);
    end component;

    signal Reset     : std_logic;
    signal Clk       : std_logic;
    signal RCVD_Data : std_logic_vector (7 downto 0);
    signal RX_Full   : std_logic;
    signal RX_Empty  : std_logic;
    signal Data_Read : std_logic;
    signal ACK_out   : std_logic;
    signal TX_RDY    : std_logic;
    signal Valid_D   : std_logic;
    signal TX_Data   : std_logic_vector (7 downto 0);
    signal Address   : std_logic_vector (7 downto 0);
    signal Databus   : std_logic_vector (7 downto 0);
    signal Write_en  : std_logic;
    signal OE        : std_logic;
    signal DMA_ACK   : std_logic;
    signal Send_comm : std_logic;
    signal DMA_RQ    : std_logic;
    signal READY     : std_logic;

    constant TbPeriod : time := 1000 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : DMA
    port map (Reset     => Reset,
              Clk       => Clk,
              RCVD_Data => RCVD_Data,
              RX_Full   => RX_Full,
              RX_Empty  => RX_Empty,
              Data_Read => Data_Read,
              ACK_out   => ACK_out,
              TX_RDY    => TX_RDY,
              Valid_D   => Valid_D,
              TX_Data   => TX_Data,
              Address   => Address,
              Databus   => Databus,
              Write_en  => Write_en,
              OE        => OE,
              DMA_ACK   => DMA_ACK,
              Send_comm => Send_comm,
              DMA_RQ    => DMA_RQ,
              READY     => READY);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that Clk is really your main clock signal
    Clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        RCVD_Data <= (others => '0');
        RX_Full <= '0';
        RX_Empty <= '0';
        ACK_out <= '0';
        TX_RDY <= '0';
        DMA_ACK <= '0';
        Send_comm <= '0';

        -- Reset generation
        -- EDIT: Check that Reset is really your reset signal
        Reset <= '1';
        wait for 100 ns;
        Reset <= '0';
        wait for 100 ns;

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;
