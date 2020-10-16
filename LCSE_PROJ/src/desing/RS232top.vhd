
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   
entity RS232top is

  port (
    Reset       : in  std_logic;   -- Low_level-active asynchronous reset
    Clk         : in  std_logic;   -- System clock (20MHz), rising edge used
    
    TX          : out std_logic;
    RX          : in  std_logic;
    
    -- Slave buses
    Address_s    : in  STD_LOGIC_VECTOR (7 downto 0);    -- Slave Address bus
    InBus_s     : in  STD_LOGIC_VECTOR (7 downto 0);    -- Slave input bus
    OutBus_s    : out STD_LOGIC_VECTOR (7 downto 0);    -- slave outpur bus
    WE_s        : in  STD_LOGIC;                        -- slave write enablr
    RE_s        : in  STD_LOGIC);                       -- slave read enable 

end RS232top;

architecture RTL of RS232top is

    CONSTANT    sRS232          :  UNSIGNED( 7 downto 0 ):= X"D0";
    CONSTANT    RS232_BASE      :  UNSIGNED( 7 downto 0 ):= sRS232;
        CONSTANT RS232_CONF     : UNSIGNED( 7 downto 0 ) := RS232_BASE + 0;
        CONSTANT RS232_STATUS   : UNSIGNED( 7 downto 0 ) := RS232_BASE + 1;
        CONSTANT RS232_TX_DATA  : UNSIGNED( 7 downto 0 ) := RS232_BASE + 2;
        CONSTANT RS232_RX_DATA  : UNSIGNED( 7 downto 0 ) := RS232_BASE + 3; 
    CONSTANT    eRS232          :  UNSIGNED( 7 downto 0 ):= RS232_BASE + 3; 
    constant DEV_MEM_BASE       : UNSIGNED( 7 downto 0 ) := RS232_BASE;

    type dev_mem_rs is array (to_integer(eRS232 - sRS232 - 1) to 0) of std_logic_vector(7 downto 0);

    signal dev_mem, dev_mem_n : dev_mem_rs :=(others => (others => '0'));
    signal OutBus_s_reg, OutBus_s_reg_n : STD_LOGIC_VECTOR (7 downto 0);
    
    signal tx_start : std_logic;
    signal rx_start : std_logic;

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

  reset_p <= not(Reset);		  -- active high reset
  
    tx_start <= dev_mem(TO_INTEGER(RS232_CONF - RS232_BASE))(6);
    rx_start <= dev_mem(TO_INTEGER(RS232_CONF - RS232_BASE))(7);
    
  Transmitter: RS232_TX
    port map (
      Clk   => Clk,
      Reset => Reset,
      Start => tx_start,
      Data  => dev_mem(TO_INTEGER(RS232_TX_DATA - RS232_BASE)),
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
      Q      => dev_mem(TO_INTEGER(RS232_RX_DATA - RS232_BASE)));

  sinit <= not reset;
  

LOGIC: process( dev_mem ) is
begin
    if ( EOT = '1' ) then
        dev_mem(TO_INTEGER(RS232_CONF - RS232_BASE))(6) <= '0'  ;
        dev_mem(TO_INTEGER(RS232_STATUS - RS232_BASE))(6) <= '1';
    elsif ( tx_start = '1' ) then
        dev_mem(TO_INTEGER(RS232_STATUS - RS232_BASE))(6) <= '0';
    end if;
    
    
    if ( EOR = '1' ) then
        dev_mem(TO_INTEGER(RS232_CONF - RS232_BASE))(7) <= '0';
        dev_mem(TO_INTEGER(RS232_STATUS - RS232_BASE))(7) <= '1';
    elsif ( rx_start = '1' ) then
        dev_mem(TO_INTEGER(RS232_STATUS - RS232_BASE))(7) <= '0';
    end if;
    
 
    
    
    if ( unsigned(Address_s(7 downto 4)) = DEV_MEM_BASE(7 downto 4) )  then
        if( WE_s = '1' ) then
            dev_mem_n( TO_INTEGER(UNSIGNED(Address_s(3 downto 0))) ) <= InBus_s;
            
        elsif ( RE_s = '1' ) then
            OutBus_s_reg_n <= dev_mem( TO_INTEGER(UNSIGNED(Address_s(3 downto 0))) );
        end if;
    end if;

end process;


end RTL;

