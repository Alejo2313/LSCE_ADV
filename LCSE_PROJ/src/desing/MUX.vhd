
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MUX is
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
end MUX;

architecture Behavioral of MUX is

    SIGNAL core_access : STD_LOGIC;
    SIGNAL DMA_access : STD_LOGIC;
    SIGNAL outBus_n   : STD_LOGIC_VECTOR (7 downto 0);
    SIGNAL Address_n   : STD_LOGIC_VECTOR (7 downto 0);       
    SIGNAL inBus_DMA_n : STD_LOGIC_VECTOR (7 downto 0);     
begin

    core_access <= WE_CORE OR RE_CORE;
    DMA_access  <= WE_DMA OR RE_DMA;
    
    Address <= Address_core when ( core_access = '1' ) else
               Address_DMA   when ( DMA_access = '1' )   else
               (others => '0');
                
    
    outBus <= outBus_CORE when ( core_access = '1' ) else
              outBus_DMA   when ( DMA_access = '1' )   else
              (others => 'Z');  
    
    
    inBus_core <= inBus when ( core_access = '1' ) else
                  (others => 'Z');
    
    inBus_DMA <= inBus when ( DMA_access = '1' ) else
                 (others => 'Z');   
                             
                    
     WE <=  WE_CORE when ( core_access = '1' ) else
            WE_DMA  when (  DMA_access = '1' ) else
            '0';             
            
     RE <=  RE_CORE when ( core_access = '1' ) else
            RE_DMA  when ( DMA_access = '1' ) else
            '0';             
                
     busAccess <= not core_access;
              
end Behavioral;