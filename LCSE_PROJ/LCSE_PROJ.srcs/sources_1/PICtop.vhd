
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.PIC_pkg.all;

entity PICtop is
  port (
    Reset    : in  std_logic;           -- Asynchronous, active low
    Clk      : in  std_logic;           -- System clock, 20 MHz, rising_edge
    RS232_RX : in  std_logic;           -- RS232 RX line
    RS232_TX : out std_logic;           -- RS232 TX line
    switches : out std_logic_vector(7 downto 0);   -- Switch status bargraph
    Temp     : out std_logic_vector(7 downto 0);   -- Display value for T_STAT
    Disp     : out std_logic_vector(1 downto 0));  -- Display activation for T_STAT
end PICtop;

architecture behavior of PICtop is

    signal Data_in    : std_logic_vector(7 downto 0);
    signal Valid_D    : std_logic;
    signal Ack_out    : std_logic;
    signal TX_RDY     : std_logic;
    signal TD         : std_logic;
    signal RD         : std_logic;
    signal Data_out   : std_logic_vector(7 downto 0);
    signal Data_read  : std_logic;
    signal RX_Full    : std_logic;
    signal RX_Empty   : std_logic;
    
    signal RCVD_Data : std_logic_vector (7 downto 0);
    signal TX_Data   : std_logic_vector (7 downto 0);
    signal Address   : std_logic_vector (7 downto 0);
    signal Databus   : std_logic_vector (7 downto 0);
    signal Write_en  : std_logic;
    signal OE        : std_logic;
    signal DMA_ACK   : std_logic;
    signal Send_comm : std_logic;
    signal DMA_RQ    : std_logic;
    signal READY     : std_logic;
          
      
    component RS232top
    port (
        Reset     : in  std_logic;
        Clk       : in  std_logic;
        Data_in   : in  std_logic_vector(7 downto 0);
        Valid_D   : in  std_logic;
        Ack_in    : out std_logic;
        TX_RDY    : out std_logic;
        TD        : out std_logic;
        RD        : in  std_logic;
        Data_out  : out std_logic_vector(7 downto 0);
        Data_read : in  std_logic;
        Full      : out std_logic;
        Empty     : out std_logic);
    end component;
  
    component DMA
    port (
        Reset     : in std_logic;
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

begin  -- behavior
    
  RS232_PHY: RS232top
    port map (
        Reset     => Reset,
        Clk       => Clk,
        Data_in   => TX_Data,
        Valid_D   => Valid_D,
        Ack_in    => Ack_out,
        TX_RDY    => TX_RDY,
        TD        => RS232_TX,
        RD        => RS232_RX,
        Data_out  => RCVD_Data,
        Data_read => Data_read,
        Full      => RX_Full,
        Empty     => RX_Empty);
DMA_DEV : DMA
    port map (
        Reset     => Reset,
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
end behavior;

