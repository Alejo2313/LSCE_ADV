----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.10.2020 11:14:26
-- Design Name: 
-- Module Name: MCU - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MCU is
    Port ( Clk :   in STD_LOGIC;
           Reset : in STD_LOGIC;
           TX    : out STD_LOGIC;
           RX    : in STD_LOGIC;
           anode         : out STD_LOGIC_VECTOR(7 downto 0);
           out_display   : out STD_LOGIC_VECTOR(7 downto 0);
           GPIOA  : inout STD_LOGIC_VECTOR (7 downto 0);
           GPIOB  : inout STD_LOGIC_VECTOR (7 downto 0) );
end MCU;

architecture Behavioral of MCU is
  component kcpsm6 
    generic(                 hwbuild : std_logic_vector(7 downto 0) := X"00";
                    interrupt_vector : std_logic_vector(11 downto 0) := X"F80";
             scratch_pad_memory_size : integer := 64);
    port (                   address : out std_logic_vector(11 downto 0);
                         instruction : in std_logic_vector(17 downto 0);
                         bram_enable : out std_logic;
                             in_port : in std_logic_vector(7 downto 0);
                            out_port : out std_logic_vector(7 downto 0);
                             port_id : out std_logic_vector(7 downto 0);
                        write_strobe : out std_logic;
                      k_write_strobe : out std_logic;
                         read_strobe : out std_logic;
                           interrupt : in std_logic;
                       interrupt_ack : out std_logic;
                               sleep : in std_logic;
                               reset : in std_logic;
                                 clk : in std_logic);
  end component;

  component rom                            
    generic(             C_FAMILY : string := "7S"; 
                C_RAM_SIZE_KWORDS : integer := 1;
             C_JTAG_LOADER_ENABLE : integer := 0);
    Port (      address : in std_logic_vector(11 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                 enable : in std_logic;
                    rdl : out std_logic;                    
                    clk : in std_logic);
  end component;
     component ram 
        PORT ( Clk      : in    std_logic;
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
              DMA_IRQ     : out STD_LOGIC_VECTOR (2 downto 0);
              
              Addess_s  : in std_logic_vector (7 downto 0);
              InBus_s   : in std_logic_vector (7 downto 0);
              OutBus_s  : out std_logic_vector (7 downto 0);
              WE_s      : in std_logic;
              RE_s      : in std_logic);
    end component;    
    
    component display
        port (Clk           : in  std_logic;
              Reset         : in  std_logic;
              Address_s     : in  STD_LOGIC_VECTOR (7 downto 0);
              InBus_s       : in  STD_LOGIC_VECTOR (7 downto 0);
              outBus_s      : out STD_LOGIC_VECTOR (7 downto 0);
              WE_s          : in  std_logic;
              RE_s          : in  std_logic;
                
              anode         : out STD_LOGIC_VECTOR(7 downto 0);
              out_display   : out STD_LOGIC_VECTOR(7 downto 0));
    end component;
    
    component GPIO
        port (Clk       : in std_logic;
              Reset     : in std_logic;
              Address_s : in std_logic_vector (7 downto 0);
              inBus_s   : in std_logic_vector (7 downto 0);
              outBus_s  : out std_logic_vector (7 downto 0);
              WE_s      : in std_logic;
              RE_s      : in std_logic;
              IRQA      : out std_logic;
              IRQB      : out std_logic;
              GPIOA     : inout std_logic_vector (7 downto 0);
              GPIOB     : inout std_logic_vector (7 downto 0));
    end component;
    
    component IRQ
        port (Clk       : in std_logic;
              Reset     : in std_logic;
              Address_s : in std_logic_vector (7 downto 0);
              InBus_s   : in std_logic_vector (7 downto 0);
              outBus_s  : out std_logic_vector (7 downto 0);
              WE_s      : in std_logic;
              RE_s      : in std_logic;
              IRQV      : in std_logic_vector (7 downto 0);
              IRQ_E     : out std_logic);
    end component;      
    
       
    signal address : std_logic_vector(11 downto 0);
    signal instruction : std_logic_vector(17 downto 0);
    signal     bram_enable : std_logic;
    signal         in_port : std_logic_vector(7 downto 0);
    signal        out_port : std_logic_vector(7 downto 0);
    signal         port_id : std_logic_vector(7 downto 0);
    signal    write_strobe : std_logic;
    signal  k_write_strobe : std_logic;
    signal     read_strobe : std_logic;
    signal       interrupt : std_logic;
    signal   interrupt_ack : std_logic;
    signal    kcpsm6_sleep : std_logic;
    signal    kcpsm6_reset : std_logic;
  
  
  
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
    
    signal anode_s         : STD_LOGIC_VECTOR(7 downto 0);
    signal out_display_s   : STD_LOGIC_VECTOR(7 downto 0);
    
    
    signal DMA_TX    : std_logic;
    signal DMA_RX    : std_logic;
    signal IRQ_TX    : std_logic;
    signal IRQ_RX    : std_logic; 
    
   
    signal rdl       : std_logic;
    signal IRQV      : std_logic_vector (7 downto 0);
    signal IRQ_E     : std_logic;   
    
    
    signal GPIOA_IRQ, GPIOB_IRQ : std_logic;
    signal DMA_CH1_IRQ, DMA_CH2_IRQ, DMA_CH3_IRQ : std_logic := '0';
    Signal DAM_IRQ : std_logic_vector (2 downto 0);
    
    

begin

    IRQV(0) <= DAM_IRQ(0);
    IRQV(1) <= DAM_IRQ(1);
    IRQV(2) <= DAM_IRQ(2);
    IRQV(3) <= '0';
    IRQV(4) <= IRQ_TX;
    IRQV(5) <= IRQ_RX;
    IRQV(6) <= GPIOA_IRQ;
    IRQV(7) <= GPIOB_IRQ;
    
  processor: kcpsm6
    generic map(hwbuild => X"00",                 
                interrupt_vector        => X"F80",
                scratch_pad_memory_size => 64)
                
    port map(   address         => address,
                instruction     => instruction,
                bram_enable     => bram_enable,
                port_id         => Address_core,
                write_strobe    => WE_Core,
                k_write_strobe  => open,
                out_port        => outBus_core,
                read_strobe     => RE_core,
                in_port         => inBus_core,
                interrupt       => interrupt,
                interrupt_ack   => interrupt_ack,
                sleep           => kcpsm6_sleep,
                reset           => Reset,
                clk             => clk);
                       
                       
                       
  program_rom: rom              
    generic map(C_FAMILY             => "7S",   --Family 'S6', 'V6' or '7S'
                C_RAM_SIZE_KWORDS    => 4,      --Program size '1', '2' or '4'
                C_JTAG_LOADER_ENABLE => 0)      --Include JTAG Loader when set to '1' 
                
    port map(   address     => address,      
                instruction => instruction,
                enable      => bram_enable,
                rdl         => kcpsm6_reset,
                clk         => clk);                       
  
  
  kcpsm6_sleep <= '0';

 -- kcpsm6_reset <= Reset;

  
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
              DMA_IRQ   => DAM_IRQ,
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
               
    Event_RQ(2) <= DMA_TX;
    Event_RQ(1) <= DMA_RX;
    EVent_RQ(0) <= '0';
    
               
    RAM_M: RAM
    port map ( Clk      => Clk,
               Reset    => Reset,
               write_en => WE_s,
               oe       => RE_s,
               address  => Addess_s,
               inBus    => inBus_s,
               outBus   => outBus_s);

   GPIO_DEV : GPIO
    port map (Clk       => Clk,
              Reset     => Reset,
              Address_s => Addess_s,
              inBus_s   => inBus_s,
              outBus_s  => outBus_s,
              WE_s      => WE_s,
              RE_s      => RE_s,
              IRQA      => GPIOA_IRQ,
              IRQB      => GPIOB_IRQ,
              GPIOA     => GPIOA,
              GPIOB     => GPIOB);
                             
    RS232 : RS232top    
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
              
    DISP7 : display
    port map (Clk       => Clk,
              Reset     => Reset,
              Address_s => Addess_s,
              InBus_s   => InBus_s,
              outBus_s  => open,
              WE_s      => WE_s,
              RE_s      => RE_s,
              anode => anode,
              out_display => out_display);
              
              
    IRQ_DEV : IRQ
    port map (Clk       => Clk,
              Reset     => Reset,
              Address_s => Addess_s,
              InBus_s   => InBus_s,
              outBus_s  => outBus_s,
              WE_s      => WE_s,
              RE_s      => RE_s,
              IRQV      => IRQV,
              IRQ_E     => interrupt);                           
end Behavioral;

