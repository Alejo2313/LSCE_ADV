-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 13.10.2020 12:44:34 UTC

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.LCSE_PKG.all; 
  
  
  
  
entity tb_DMA2 is
end tb_DMA2;
   
architecture tb of tb_DMA2 is    

    CONSTANT sRAM       : UNSIGNED( 7 downto 0) := X"10" ;
    CONSTANT eRAM       : UNSIGNED( 7 downto 0) := X"1F" ;
    
    constant DMA_MEM_BASE       : UNSIGNED( 7 downto 0 ) := X"C0";
    
    
    constant DMA_CH1_OFF       : UNSIGNED( 3 downto 0 ) := X"0";
        constant DMA_CONF_CH1      : UNSIGNED( 3 downto 0 ) := DMA_CH1_OFF + X"0";
        constant DMA_SRC_CH1       : UNSIGNED( 3 downto 0 ) := DMA_CH1_OFF + X"1";
        constant DMA_DEST_CH1      : UNSIGNED( 3 downto 0 ) := DMA_CH1_OFF + X"2";
        constant DMA_CNT_CH1       : UNSIGNED( 3 downto 0 ) := DMA_CH1_OFF + X"3";
         
    constant DMA_CH2_OFF       : UNSIGNED( 3 downto 0 ) := X"4";
        constant DMA_CONF_CH2      : UNSIGNED( 3 downto 0 ) := DMA_CH2_OFF + X"0";
        constant DMA_SRC_CH2       : UNSIGNED( 3 downto 0 ) := DMA_CH2_OFF + X"1";
        constant DMA_DEST_CH2      : UNSIGNED( 3 downto 0 ) := DMA_CH2_OFF + X"2";
        constant DMA_CNT_CH2      : UNSIGNED( 3 downto 0 ) := DMA_CH2_OFF + X"3"; 
        
    constant DMA_CH3_OFF       : UNSIGNED( 3 downto 0 ) := X"8";
        constant DMA_CONF_CH3      : UNSIGNED( 3 downto 0 ) := DMA_CH3_OFF + X"0";
        constant DMA_SRC_CH3       : UNSIGNED( 3 downto 0 ) := DMA_CH3_OFF + X"1";
        constant DMA_DEST_CH3      : UNSIGNED( 3 downto 0 ) := DMA_CH3_OFF + X"2";
        constant DMA_CNT_CH3       : UNSIGNED( 3 downto 0 ) := DMA_CH3_OFF + X"3"; 
        
    constant DMA_CONF_OFF      : UNSIGNED( 3 downto 0 ) := X"0";
    constant DMA_SRC_OFF       : UNSIGNED( 3 downto 0 ) := X"1";
    constant DMA_DEST_OFF      : UNSIGNED( 3 downto 0 ) := X"2";
    constant DMA_CNT_OFF       : UNSIGNED( 3 downto 0 ) := X"3";
     
     
     constant DEV_MEM_BASE       : UNSIGNED( 7 downto 0 ) := DMA_MEM_BASE;
     
    component DMA2
        port (clk       : in std_logic;
              Reset     : in std_logic;
              Address_m : out std_logic_vector (7 downto 0);
              InBus_m   : in std_logic_vector (7 downto 0);
              OutBus_m  : out std_logic_vector (7 downto 0);
              WE_m      : out std_logic;
              RE_m      : out std_logic;
              Access_m  : in std_logic;
              Event_RQ  : in std_logic_vector (2 downto 0);
              Addess_s  : in std_logic_vector (7 downto 0);
              InBus_s   : in std_logic_vector (7 downto 0);
              OutBus_s  : out std_logic_vector (7 downto 0);
              WE_s      : in std_logic;
              RE_s      : in std_logic);
    end component;
    
    component ram 
        PORT (
           Clk      : in    std_logic;
           Reset    : in    std_logic;
           write_en : in    std_logic;
           oe       : in    std_logic;
           address  : in    std_logic_vector(7 downto 0);
           inBus    : in std_logic_vector(7 downto 0);
           outBus   : out std_logic_vector(7 downto 0));
    END component;
    
    component MUX 
        Port ( Address_core : in STD_LOGIC_VECTOR (7 downto 0);
               inBus_core : out STD_LOGIC_VECTOR (7 downto 0);
               outBus_CORE : in STD_LOGIC_VECTOR (7 downto 0);
               WE_CORE : in STD_LOGIC;
               RE_CORE : in STD_LOGIC;
               
               
               Address_DMA : in STD_LOGIC_VECTOR (7 downto 0);
               inBus_DMA : out STD_LOGIC_VECTOR (7 downto 0);
               outBus_DMA : in STD_LOGIC_VECTOR (7 downto 0);
               WE_DMA : in STD_LOGIC;
               RE_DMA : in STD_LOGIC; 
               busAccess : out STD_LOGIC;
               
               
               Address : out STD_LOGIC_VECTOR (7 downto 0);
               inBus : in STD_LOGIC_VECTOR (7 downto 0);
               outBus : out STD_LOGIC_VECTOR (7 downto 0);
               WE : out STD_LOGIC;
               RE : out STD_LOGIC);
    end component;
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
    signal clk       : std_logic;
    signal Reset     : std_logic;
    
    signal Address_core : std_logic_vector (7 downto 0);
    signal InBus_core   : std_logic_vector (7 downto 0);
    signal OutBus_core  : std_logic_vector (7 downto 0);
    signal WE_core      : std_logic;
    signal RE_core      : std_logic;
    signal Access_core  : std_logic;
    
    signal Address_m : std_logic_vector (7 downto 0);
    signal InBus_m   : std_logic_vector (7 downto 0);
    signal OutBus_m  : std_logic_vector (7 downto 0);
    signal WE_m      : std_logic;
    signal RE_m      : std_logic;
    signal Access_m  : std_logic;
    
    signal Event_RQ  : std_logic_vector (2 downto 0);
    signal Addess_s  : std_logic_vector (7 downto 0);
    signal InBus_s   : std_logic_vector (7 downto 0);
    signal OutBus_s  : std_logic_vector (7 downto 0);
    signal WE_s      : std_logic;
    signal RE_s      : std_logic;
    
    

    signal TX        : std_logic;
    signal RX        : std_logic;
    signal DMA_TX    : std_logic;
    signal DMA_RX    : std_logic;
    signal IRQ_TX    : std_logic;
    signal IRQ_RX    : std_logic;

    constant TbPeriod : time := 20 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    DMA : DMA2
    port map (clk       => clk,
              Reset     => Reset,
              Address_m => Address_m,
              InBus_m   => InBus_m,
              OutBus_m  => OutBus_m,
              WE_m      => WE_m,
              RE_m      => RE_m,
              Access_m  => Access_m,
              Event_RQ  => Event_RQ,
              Addess_s  => Addess_s,
              InBus_s   => InBus_s,
              OutBus_s  => OutBus_s,
              WE_s      => WE_s,
              RE_s      => RE_s);
              
    MUX_M: MUX
    port map ( Address_core => Address_core,
               inBus_core   => inBus_core,
               outBus_CORE  => outBus_CORE,
               WE_CORE      => WE_CORE,
               RE_CORE      => RE_CORE,
               
               
               Address_DMA => Address_m, 
               inBus_DMA   => InBus_m,
               outBus_DMA  => OutBus_m,
               WE_DMA      => WE_m,
               RE_DMA      => RE_m,
               busAccess   => Access_m,
               
               
               Address  => Addess_s,
               inBus    => OutBus_s,
               outBus   => inBus_s,
               WE       => WE_s,
               RE       => RE_s);
               
    RAM_M: RAM
    port map ( Clk      => Clk,
               Reset    => Reset,
               write_en => WE_s,
               oe       => RE_s,
               address  => Addess_s,
               inBus    => inBus_s,
               outBus   => outBus_s);
    dut : RS232top
    port map (Reset     => Reset,
              Clk       => Clk,
              TX        => TX,
              RX        => RX,
              DMA_TX    => DMA_TX,
              DMA_RX    => DMA_RX,
              IRQ_TX    => IRQ_TX,
              IRQ_RX    => IRQ_RX,
              Address_s => Addess_s,
              InBus_s   => InBus_s,
              OutBus_s  => OutBus_s,
              WE_s      => WE_s,
              RE_s      => RE_s);
    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;
    Event_RQ(2) <= DMA_TX;
    Event_RQ(1 downto 0) <= "00";
    stimuli : process
    begin
        
        -- EDIT Adapt initialization as needed
        InBus_core <= (others => '0');
     --   Event_RQ <= (others => '0');
        WE_core <= '0';
        RE_core <= '0';
        RX <= '1';
        -- Reset generation
        -- EDIT: Check that Reset is really your reset signal
        Reset <= '1';
        wait for 90 ns;
        Reset <= '0';
        wait for 100 ns;
        
        Address_core <= std_logic_vector(sRAM  + 0);
        outBus_core  <= X"A1";
        WE_core <= '1';
        wait for 20 ns;
--        WE_core <= '0';
--        wait for 10 ns;
        
        Address_core <= std_logic_vector(sRAM  + 1);
        outBus_core  <= X"2A";
        WE_core <= '1';
        wait for 20 ns;
--        WE_core <= '0';
--        wait for 10 ns;
        
        Address_core <= std_logic_vector(sRAM  + 2);
        outBus_core  <= X"A3";
        WE_core <= '1';
        wait for 20 ns;
        WE_core <= '0';
        wait for 20 ns;
        
        Address_core <= std_logic_vector(sRAM  + 3);
        outBus_core  <= X"A4";
        WE_core <= '1';
        wait for 20 ns;
        WE_core <= '0';
        wait for 20 ns;        

        
        Address_core <= std_logic_vector(DMA_MEM_BASE + DMA_CONF_CH1);
        outBus_core  <= X"A0";
        WE_core <= '1';
--        wait for 10 ns;
--        WE_core <= '0';
        wait for 20 ns;
        
        Address_core <= std_logic_vector(DMA_MEM_BASE + DMA_SRC_CH1);
        outBus_core  <= std_logic_vector(sRAM  + 1);
        WE_core <= '1';
--        wait for 10 ns;
--        WE_core <= '0';
        wait for 20 ns;
        
        Address_core <= std_logic_vector(DMA_MEM_BASE + DMA_DEST_CH1);
        outBus_core  <= std_logic_vector(RS232_TX_DATA);
        WE_core <= '1';
--        wait for 10 ns;
--        WE_core <= '0';
        wait for 20 ns;
        
        Address_core <= std_logic_vector(DMA_MEM_BASE + DMA_CNT_CH1);
        outBus_core  <= X"02";
        WE_core <= '1';
        wait for 20 ns;
        WE_core <= '0';
        wait for 20 ns;  
        
        
       Address_core <= std_logic_vector(RS232_TX_DATA);
       outBus_core    <= X"A1";
       WE_core     <= '1';
       wait for TbPeriod; 
       WE_core     <= '0';
       wait for TbPeriod;
       
       Address_core <= std_logic_vector(RS232_CONF);
       outBus_core    <= "01001111";
       WE_core     <= '1';
       wait for TbPeriod; 
       WE_core     <= '0';
       wait for TbPeriod;    
        
        wait for 20 ns;
        
        wait for 60 ns;
        
        Address_core <= std_logic_vector(sRAM  + 2);
        outBus_core  <= X"FF";
        WE_core <= '1';
        wait for 20 ns;
        WE_core <= '0';
        wait for 20 ns; 

        -- Stop the clock and hence terminate the simulation
        wait; 
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

