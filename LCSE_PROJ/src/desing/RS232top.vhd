
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LCSE_PKG.all;
   
entity RS232top is

  port (
    Reset       : in  std_logic;   -- Low_level-active asynchronous reset
    Clk         : in  std_logic;   -- System clock (20MHz), rising edge used
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

    signal dev_mem, dev_mem_n : dev_mem_rs :=(others => (others => '0'));
    signal OutBus_s_reg, OutBus_s_reg_n : STD_LOGIC_VECTOR (7 downto 0);
    signal DMA_RX_reg, DMA_RX_reg_n         : std_logic;
    signal IRQ_RX_reg, IRQ_RX_reg_n         : std_logic;
    signal DMA_TX_reg, DMA_TX_reg_n         : std_logic;
    signal IRQ_TX_reg, IRQ_TX_reg_n         : std_logic;
    signal tx_start_reg, tx_start_reg_n     : std_logic;
    signal rx_start_reg, rx_start_reg_n     : std_logic;
    signal data_in, data_out     : STD_LOGIC_VECTOR (7 downto 0);
    
    
    signal tx_en_bit : std_logic;
    signal rx_en_bit : std_logic;
    
    constant rx_en   : integer :=  7;
    constant tx_en   : integer :=  6;
    
    constant rx_dma_en : integer :=  3;
    constant tx_dma_en : integer :=  2;
    constant rx_irq_en : integer :=  1;
    constant tx_irq_en : integer :=  0;
    
    
    
 ------------------------------------------------------------------------
  -- Components for Transmitter Block
  ------------------------------------------------------------------------

  component RS232_TX
    port (
      Clk   : in  std_logic;
      Reset : in  std_logic;
      Start : in  std_logic;
      Data  : in  std_logic_vector(7 downto 0);
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



begin  -- RTL

  

  Transmitter: RS232_TX
    port map (
      Clk   => Clk,
      Reset => Reset,
      Start => tx_start_reg,
      Data  => data_in,
      EOT   => EOT, ---ToDo: RQ DMA, IRQ CORE, BIT STATE. debe durar 1 ciclo
      TX    => TX);

  Receiver: RS232_RX   -- Add enable and baudrate, add more config options 
    port map (
      Clk       => Clk,
      Reset     => Reset,
      LineRD_in => RX,
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

tx_en_bit <= dev_mem(TO_INTEGER(RS232_CONF - RS232_BASE))(tx_en);
rx_en_bit <= dev_mem(TO_INTEGER(RS232_CONF - RS232_BASE))(rx_en);

LOGIC: process( dev_mem, Address_s, EOT, EOR, data_out,InBus_s, WE_s, RE_s) is
begin
    DMA_RX_reg_n <= '0';
    IRQ_RX_reg_n <= '0';
    DMA_TX_reg_n <= '0';
    IRQ_TX_reg_n <= '0';
    OutBus_s_reg   <= (others => 'Z') ;
    dev_mem_n <= dev_mem;
    
    data_in <= dev_mem(TO_INTEGER(RS232_TX_DATA - RS232_BASE));
    
    if ( EOT = '1' ) then
        dev_mem_n(TO_INTEGER(RS232_CONF - RS232_BASE))(tx_en)   <= '0'  ;
        dev_mem_n(TO_INTEGER(RS232_STATUS - RS232_BASE))(tx_en) <= '1';
        
        if (dev_mem(TO_INTEGER(RS232_CONF - RS232_BASE))(tx_dma_en) = '1') then
            DMA_TX_reg_n  <= '1';
        end if;
        if (dev_mem(TO_INTEGER(RS232_CONF - RS232_BASE))(tx_irq_en) = '1') then
            IRQ_TX_reg_n  <= '1';
        end if;
        
    elsif (dev_mem(TO_INTEGER(RS232_CONF - RS232_BASE))(tx_en) = '1' ) then
        dev_mem_n(TO_INTEGER(RS232_STATUS - RS232_BASE))(tx_en) <= '0';
        DMA_TX_reg_n  <= '0';
        IRQ_TX_reg_n  <= '0';
    end if;
    
    if ( EOR = '1' ) then
        dev_mem_n(TO_INTEGER(RS232_CONF - RS232_BASE))(rx_en)     <= '0';
        dev_mem_n(TO_INTEGER(RS232_STATUS - RS232_BASE))(rx_en)   <= '1';
        dev_mem_n(TO_INTEGER(RS232_RX_DATA - RS232_BASE)) <= data_out;
        
        if (dev_mem(TO_INTEGER(RS232_CONF - RS232_BASE))(rx_dma_en) = '1') then
            DMA_RX_reg_n  <= '1';
        end if;
        if (dev_mem(TO_INTEGER(RS232_CONF - RS232_BASE))(rx_irq_en) = '1') then
            IRQ_RX_reg_n  <= '1';
        end if;
        
    elsif ( dev_mem(TO_INTEGER(RS232_CONF - RS232_BASE))(rx_en) = '1' ) then
        dev_mem_n(TO_INTEGER(RS232_STATUS - RS232_BASE))(rx_en) <= '0';
        DMA_RX_reg_n  <= '0';
        IRQ_RX_reg_n  <= '0';
    end if;
    
   
    if ( unsigned(Address_s(7 downto 4)) = DEV_MEM_BASE(7 downto 4) )  then
        if( WE_s = '1' ) then
            dev_mem_n( TO_INTEGER(UNSIGNED(Address_s(3 downto 0))) ) <= InBus_s;
            
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

