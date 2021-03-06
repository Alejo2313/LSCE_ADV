    
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LCSE_PKG.all;
   
entity RS232top is

  port (
    Reset       : in  std_logic;   -- Low_level-active asynchronous reset
    Clk         : in  std_logic;   -- System clock (20MHz), rising edge used
    -- Configuration 
--    Conf        : in STD_LOGIC_VECTOR (7 DOWNTO 0);
    -- Transmission lines 
    TX          : out std_logic;
    RX          : in  std_logic;
    -- Events 
    DMA_TX      : out std_logic;
    DMA_RX      : out  std_logic; 
    IRQ_TX      : out std_logic;
    IRQ_RX      : out  std_logic;   
    -- Slave buses
    Address_s   : in  STD_LOGIC_VECTOR (7 downto 0);    -- Slave Address bus
    InBus_s     : in  STD_LOGIC_VECTOR (7 downto 0);    -- Slave input bus
    OutBus_s    : out STD_LOGIC_VECTOR (7 downto 0);    -- slave outpur bus
    WE_s        : in  STD_LOGIC;                        -- slave write enablr
    RE_s        : in  STD_LOGIC);                       -- slave read enable 

end RS232top;

architecture RTL of RS232top is


    
    
    type dev_mem_rs is array (to_integer(eRS232 - sRS232) downto 0) of std_logic_vector(7 downto 0);

    -- Register offset
    constant RS232_TX_DATA_offset   : integer   := TO_INTEGER(RS232_TX_DATA - RS232_BASE);
    constant RS232_CONF_offset      : integer   := TO_INTEGER(RS232_CONF - RS232_BASE);
    constant RS232_STATUS_offset    : integer   := TO_INTEGER(RS232_STATUS - RS232_BASE);
    constant RS232_RX_DATA_offset   : integer   := TO_INTEGER(RS232_RX_DATA - RS232_BASE);
    -- Bit index
    constant rx_en                  : integer   :=  7;
    constant tx_en                  : integer   :=  6;
    constant rx_dma_en              : integer   :=  3;
    constant tx_dma_en              : integer   :=  2;
    constant rx_irq_en              : integer   :=  1;
    constant tx_irq_en              : integer   :=  0;
    
    
    --Signals   
    signal dev_mem, dev_mem_n               : dev_mem_rs :=(others => (others => '0'));
    signal OutBus_s_reg, OutBus_s_reg_n     : STD_LOGIC_VECTOR (7 downto 0);
    signal DMA_RX_reg, DMA_RX_reg_n         : std_logic;
    signal IRQ_RX_reg, IRQ_RX_reg_n         : std_logic;
    signal DMA_TX_reg, DMA_TX_reg_n         : std_logic;
    signal IRQ_TX_reg, IRQ_TX_reg_n         : std_logic;
    signal tx_start_reg, tx_start_reg_n     : std_logic;
    signal rx_start_reg, rx_start_reg_n     : std_logic;
    signal data_in, data_out                : STD_LOGIC_VECTOR (7 downto 0);
           
    signal tx_en_bit    : std_logic;
    signal rx_en_bit    : std_logic;
    
    signal rx_dma_bit   : std_logic;
    signal tx_irq_bit   : std_logic;   
    signal tx_dma_bit   : std_logic;
    signal rx_irq_bit   : std_logic;



 ------------------------------------------------------------------------
  -- Components for Transmitter Block
  ------------------------------------------------------------------------

  component RS232_TX
    port (
      Clk   : in  std_logic;
      Reset : in  std_logic;
      Start : in  std_logic;
      Data  : in  std_logic_vector(7 downto 0);
      Conf  : in STD_LOGIC_VECTOR (7 DOWNTO 0);
      EOT   : out std_logic;
      TX    : out std_logic);
  end component;

  ------------------------------------------------------------------------
  -- Components for Receiver Block
  ------------------------------------------------------------------------

  component ShiftRegister
    port (
      Reset  : in  std_logic;
      Clk    : in  std_logic;
      Enable : in  std_logic;
      D      : in  std_logic;
      Q      : out std_logic_vector(7 downto 0));
  end component;

  component RS232_RX
    port (
      Clk       : in  std_logic;
      Reset     : in  std_logic;
      LineRD_in : in  std_logic;
      Conf      : in STD_LOGIC_VECTOR (7 DOWNTO 0);
      Valid_out : out std_logic;
      Code_out  : out std_logic;
      Store_out : out std_logic);
  end component;


  ------------------------------------------------------------------------
  -- Internal Signals
  ------------------------------------------------------------------------

  signal Data_FF    : std_logic_vector(7 downto 0);
  signal StartTX    : std_logic;  -- start signal for transmitter
  signal LineRD_in  : std_logic;  -- internal RX line
  signal Valid_out  : std_logic;  -- valid bit @ receiver
  signal Code_out   : std_logic;  -- bit @ receiver output
  signal sinit      : std_logic;  -- fifo reset
  signal Fifo_in    : std_logic_vector(7 downto 0);
  signal EOR         : std_logic;
  signal EOT        : std_logic;
  signal reset_p    : std_logic;
  signal rx_in      : std_logic;

begin  -- RTL

tx_en_bit   <= dev_mem(RS232_CONF_offset)(tx_en);
rx_en_bit   <= dev_mem(RS232_CONF_offset)(rx_en);

tx_dma_bit  <= dev_mem(RS232_CONF_offset)(tx_dma_en);
rx_dma_bit  <= dev_mem(RS232_CONF_offset)(rx_dma_en);

tx_irq_bit  <= dev_mem(RS232_CONF_offset)(tx_irq_en);
rx_irq_bit  <= dev_mem(RS232_CONF_offset)(rx_irq_en);

data_in     <= dev_mem(RS232_TX_DATA_offset);

  Transmitter: RS232_TX
    port map (
      Clk   => Clk,
      Reset => Reset,
      Start => tx_en_bit,
      Data  => data_in,
      Conf  => dev_mem(RS232_STATUS_offset),
      EOT   => EOT, ---ToDo: RQ DMA, IRQ CORE, BIT STATE. debe durar 1 ciclo
      TX    => TX);

    rx_in <= RX when rx_en_bit = '1' else
             '1';
             
  Receiver: RS232_RX   -- Add enable and baudrate, add more config options 
    port map (
      Clk       => Clk,
      Reset     => Reset,
      LineRD_in => rx_in,
      Conf      => dev_mem(RS232_STATUS_offset),
      Valid_out => Valid_out,
      Code_out  => Code_out,
      Store_out => EOR); --- ToDo: RQ DMA, IRQ CORE, BIT STATE 

  Shift: ShiftRegister
    port map (
      Reset  => Reset,
      Clk    => Clk,
      Enable => Valid_Out,  
      D      => Code_Out,
      Q      => data_out);
    
  
FF:process( clk, reset ) is

begin --TODO DMA have to be on high impedance
    if( reset = '1' ) then
        dev_mem        <= (others => (others => '0'));
        DMA_RX_reg     <= '0';
        IRQ_RX_reg     <= '0';
        DMA_TX_reg     <= '0';
        IRQ_TX_reg     <= '0';

        
    elsif ( Clk = '1' and Clk'event ) then
        dev_mem        <= dev_mem_n;
        DMA_RX_reg     <= DMA_RX_reg_n;
        IRQ_RX_reg     <= IRQ_RX_reg_n;
        DMA_TX_reg     <= DMA_TX_reg_n;
        IRQ_TX_reg     <= IRQ_TX_reg_n;
    
    end if;
end process;

LOGIC: process( dev_mem, Address_s, EOT, EOR, 
                data_out,InBus_s, WE_s, RE_s,
                tx_en_bit, rx_en_bit, tx_dma_bit, rx_dma_bit, 
                tx_irq_bit, rx_irq_bit) is
begin
    DMA_RX_reg_n    <= '0';
    IRQ_RX_reg_n    <= '0';
    DMA_TX_reg_n    <= '0';
    IRQ_TX_reg_n    <= '0';
    OutBus_s_reg    <= (others => 'Z') ;
    dev_mem_n       <= dev_mem;
    
    if ( EOT = '1' ) then
        dev_mem_n(RS232_CONF_offset)(tx_en)   <= '0'  ;
        dev_mem_n(RS232_STATUS_offset)(tx_en) <= '1';
        
        if (tx_dma_bit = '1') then
            DMA_TX_reg_n  <= '1';
        end if;
        if (tx_irq_bit = '1') then
            IRQ_TX_reg_n  <= '1';
        end if;
        
    elsif (tx_en_bit = '1' ) then
        dev_mem_n(RS232_STATUS_offset)(tx_en) <= '0';
        DMA_TX_reg_n  <= '0';
        IRQ_TX_reg_n  <= '0';
    end if;
    
    if ( EOR = '1' ) then
--        dev_mem_n(RS232_CONF_offset)(rx_en)     <= '0';
        dev_mem_n(RS232_STATUS_offset)(rx_en)   <= '1';
        dev_mem_n(RS232_RX_DATA_offset)         <= data_out;
        
        if (rx_dma_bit = '1') then
            DMA_RX_reg_n  <= '1';
        end if;
        
        if (rx_irq_bit = '1') then
            IRQ_RX_reg_n  <= '1';
        end if;
        
    elsif ( rx_en_bit = '1' ) then
 --       dev_mem_n(RS232_STATUS_offset)(rx_en) <= '0';
        DMA_RX_reg_n  <= '0';
        IRQ_RX_reg_n  <= '0';
    end if;
    
   
    if ( unsigned(Address_s) >= sRS232 and unsigned(Address_s) <= eRS232  )  then
        if( WE_s = '1' ) then
            dev_mem_n( TO_INTEGER(UNSIGNED(Address_s(3 downto 0))) ) <= InBus_s;
            if ( unsigned(Address_s) = (RS232_TX_DATA) and tx_dma_bit = '1' ) then
               dev_mem_n(RS232_CONF_offset)(tx_en) <= '1';
            end if;
        elsif ( RE_s = '1' ) then
            OutBus_s_reg <= dev_mem( TO_INTEGER(UNSIGNED(Address_s(3 downto 0))) );
        end if;
    end if;

end process;


IRQ_RX  <= IRQ_RX_reg;
IRQ_TX  <= IRQ_TX_reg;
DMA_TX  <= DMA_TX_reg;
DMA_RX  <= DMA_RX_reg;
OutBus_s <= OutBus_s_reg;

end RTL;

