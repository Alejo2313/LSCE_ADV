----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.10.2020 16:39:58
-- Design Name: 
-- Module Name: GPIO - Behavioral
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
use work.LCSE_PKG.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity GPIO is
    Port ( Clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Address_s : in STD_LOGIC_VECTOR (7 downto 0);
           inBus_s : in STD_LOGIC_VECTOR (7 downto 0);
           outBus_s : out STD_LOGIC_VECTOR (7 downto 0);
           WE_s : in STD_LOGIC;
           RE_s : in STD_LOGIC;
           
           IRQA  : out STD_LOGIC;
           IRQB  : out STD_LOGIC;
           
           GPIOA : inout STD_LOGIC_VECTOR (7 downto 0);
           GPIOB : inout STD_LOGIC_VECTOR (7 downto 0));
end GPIO;

architecture Behavioral of GPIO is

type dev_mem_8 is array ( 0 to TO_INTEGER(eGPIO - sGPIO) ) of std_logic_vector(7 downto 0);

signal dev_mem, dev_mem_n : dev_mem_8;

signal IRQA_reg, IRQA_reg_n :STD_LOGIC;
signal IRQB_reg, IRQB_reg_n :STD_LOGIC;
signal GPIOA_reg, GPIOB_reg : std_logic_vector(7 downto 0);

signal OutBus_s_reg : std_logic_vector(7 downto 0);

signal gpioa_mode   : std_logic_vector(15 downto 0);
signal gpiob_mode   : std_logic_vector(15 downto 0);
signal irqMaskA     : std_logic_vector(7 downto 0);
signal irqMaskB     : std_logic_vector(7 downto 0);
signal irqModeA     : std_logic_vector(7 downto 0);
signal irqModeB     : std_logic_vector(7 downto 0);



constant irqMaskA_offset : integer := TO_INTEGER(GPIO_IRQA_MASK - GPIO_BASE);
constant irqMaskB_offset : integer := TO_INTEGER(GPIO_IRQB_MASK - GPIO_BASE);

constant irqModeA_offset : integer := TO_INTEGER(GPIO_IRQMODEA_MASK - GPIO_BASE);
constant irqModeB_offset : integer := TO_INTEGER(GPIO_IRQMODEB_MASK - GPIO_BASE);

constant modeA1_offset : integer := TO_INTEGER(GPIO_MODEA_REG1 - GPIO_BASE);
constant modeA2_offset : integer := TO_INTEGER(GPIO_MODEA_REG2 - GPIO_BASE);

constant modeB1_offset : integer := TO_INTEGER(GPIO_MODEB_REG1 - GPIO_BASE);
constant modeB2_offset : integer := TO_INTEGER(GPIO_MODEB_REG2 - GPIO_BASE);

constant gpioa_offset  : integer := TO_INTEGER(GPIO_A - GPIO_BASE);
constant gpiob_offset  : integer := TO_INTEGER(GPIO_B - GPIO_BASE);



    
begin

gpioa_mode <= dev_mem(modeA1_offset)&dev_mem(modeA2_offset);
gpiob_mode <= dev_mem(modeB1_offset)&dev_mem(modeB2_offset);

irqMaskA   <= dev_mem(irqMaskA_offset);
irqMaskB   <= dev_mem(irqMaskB_offset);

irqModeA   <= dev_mem(irqModeA_offset);
irqModeB   <= dev_mem(modeA2_offset);



FF: process( Clk, Reset) is 
begin
    if(Reset = '1' ) then
        IRQA_reg <= '0';
        IRQB_reg <= '0';
        dev_mem <= (others => (others => '0'));
        dev_mem(gpioa_offset) <= (others => 'Z');
        dev_mem(gpiob_offset) <= (others => 'Z');
   elsif (Clk'event and clk = '1' ) then
        IRQA_reg <= IRQA_reg_n;
        IRQB_reg <= IRQA_reg_n;
        dev_mem <= dev_mem_n;
   end if;     
    
    
end process;

GPIO:process( GPIOA, dev_mem, GPIOA, GPIOB, irqMaskA, irqMaskB, irqModeA, irqModeB, Address_s, WE_s, RE_s, InBus_s,gpioa_mode, gpiob_mode) is
begin
    IRQA_reg_n <= '0';
    IRQB_reg_n <= '0';
    dev_mem_n <= dev_mem;
    GPIOA_reg <= GPIOA;
    GPIOB_reg <= GPIOB;
    OutBus_s_reg <= (others => 'Z');
    
    port_A: for k in (GPIOA'length -1) downto 0 loop
        case gpioa_mode(k*2 + 1 downto k*2) is
            when "01" =>  --output
                GPIOA_reg(GPIOA'length - k -1) <= dev_mem(gpioa_offset)(GPIOA'length - k -1);
            when "10" =>  --Input
                dev_mem_n(gpioa_offset)(GPIOA'length - k -1) <= GPIOA(GPIOA'length - k -1);
                GPIOA_reg(GPIOA'length - k -1) <= 'Z';
                if ( GPIOA(GPIOA'length - k -1) /= dev_mem(gpioa_offset)(GPIOA'length - k -1) ) then 
                    if ( irqMaskA( GPIOA'length - k -1 ) = '1' AND dev_mem(gpioa_offset)(GPIOA'length - k -1) = irqModeA(GPIOA'length - k -1)) then
                        IRQA_reg_n <= '1';
                    end if;
                end if;
            when others =>   
                GPIOA_reg(GPIOA'length - k -1) <= 'Z';
        end case;      
    end loop;
    
    port_B: for k in (GPIOB'length -1) downto 0 loop
        case gpiob_mode(k*2 + 1 downto k*2) is
            when "01" =>
                GPIOB_reg(GPIOB'length - k -1) <= dev_mem(gpiob_offset)(GPIOB'length - k -1);
            when "10" =>
                dev_mem_n(gpiob_offset)(GPIOB'length - k -1) <= GPIOB(GPIOB'length - k -1);
                GPIOB_reg(GPIOB'length - k -1) <= 'Z';
                if (  GPIOB(GPIOB'length - k -1) /= dev_mem(gpiob_offset)(GPIOB'length - k -1) ) then 
                    if ( irqMaskB( GPIOB'length - k -1 ) = '1' AND dev_mem(gpiob_offset)(GPIOB'length - k -1) = irqModeB(GPIOB'length - k -1)) then
                        IRQB_reg_n <= '1';
                    end if;
                end if;                              
            when others =>   
                GPIOB_reg(GPIOB'length - k -1) <= '0';
        end case;      
    end loop;  
    
    if ( unsigned(Address_s(7 downto 4)) = GPIO_BASE(7 downto 4) )  then
        if( WE_s = '1' ) then
            dev_mem_n( TO_INTEGER(unsigned(Address_s(3 downto 0))) ) <= InBus_s;
            
        elsif ( RE_s = '1' ) then
            OutBus_s_reg <= dev_mem(TO_INTEGER(unsigned(Address_s(3 downto 0)) ));
        end if;
    end if;    
end process;


IRQA  <= IRQA_reg;
IRQB  <= IRQB_reg;  
GPIOA <= GPIOA_reg;
GPIOB <= GPIOB_reg;
outBus_s <= OutBus_s_reg;

end Behavioral;
