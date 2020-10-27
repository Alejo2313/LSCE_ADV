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
use IEEE.NUMERIC_STD.ALL;


entity GPIO is
    Port ( Clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           -- Bus access
           Address_s : in STD_LOGIC_VECTOR (7 downto 0);
           inBus_s : in STD_LOGIC_VECTOR (7 downto 0);
           outBus_s : out STD_LOGIC_VECTOR (7 downto 0);
           WE_s : in STD_LOGIC;
           RE_s : in STD_LOGIC;
           -- Interrupt vectors
           IRQA  : out STD_LOGIC;
           IRQB  : out STD_LOGIC;
           -- IO ports 
           GPIOA : inout STD_LOGIC_VECTOR (7 downto 0);
           GPIOB : inout STD_LOGIC_VECTOR (7 downto 0));
end GPIO;

architecture Behavioral of GPIO is

    type dev_mem_8 is array ( 0 to TO_INTEGER(eGPIO - sGPIO) ) of std_logic_vector(7 downto 0);
    
    signal dev_mem, dev_mem_n   : dev_mem_8;
    
    -- IRQ and GPIO registers
    signal IRQA_reg, IRQA_reg_n : STD_LOGIC;
    signal IRQB_reg, IRQB_reg_n : STD_LOGIC;
    signal GPIOA_reg, GPIOB_reg : std_logic_vector(7 downto 0);
    
    signal OutBus_s_reg         : std_logic_vector(7 downto 0);
    
    -- Auxiliar signals 
    signal gpioa_mode           : std_logic_vector(15 downto 0);
    signal gpiob_mode           : std_logic_vector(15 downto 0);
    signal irqMaskA             : std_logic_vector(7 downto 0);
    signal irqMaskB             : std_logic_vector(7 downto 0);
    signal irqModeA             : std_logic_vector(7 downto 0);
    signal irqModeB             : std_logic_vector(7 downto 0);
    
    
    -- Constants
    constant irqMaskA_offset    : integer := TO_INTEGER(GPIO_IRQA_MASK - GPIO_BASE);
    constant irqMaskB_offset    : integer := TO_INTEGER(GPIO_IRQB_MASK - GPIO_BASE);
    constant irqModeA_offset    : integer := TO_INTEGER(GPIO_IRQMODEA_MASK - GPIO_BASE);
    constant irqModeB_offset    : integer := TO_INTEGER(GPIO_IRQMODEB_MASK - GPIO_BASE);
    constant modeA1_offset      : integer := TO_INTEGER(GPIO_MODEA_REG1 - GPIO_BASE);
    constant modeA2_offset      : integer := TO_INTEGER(GPIO_MODEA_REG2 - GPIO_BASE);
    constant modeB1_offset      : integer := TO_INTEGER(GPIO_MODEB_REG1 - GPIO_BASE);
    constant modeB2_offset      : integer := TO_INTEGER(GPIO_MODEB_REG2 - GPIO_BASE);
    constant gpioa_offset       : integer := TO_INTEGER(GPIO_A - GPIO_BASE);
    constant gpiob_offset       : integer := TO_INTEGER(GPIO_B - GPIO_BASE);
    
    constant INPUT_MODE         : std_logic_vector(1 downto 0) := "01";
    constant OUTPUT_MODE        : std_logic_vector(1 downto 0) := "10";
    constant AF_MODE            : std_logic_vector(1 downto 0) := "11";
   
     
begin
    
    -- Common used signals.
    -- GPIO mode vectors joined to simplify processing
    gpioa_mode <= dev_mem(modeA1_offset)&dev_mem(modeA2_offset);
    gpiob_mode <= dev_mem(modeB1_offset)&dev_mem(modeB2_offset);
    -- GPIO IRQ mask registers
    irqMaskA   <= dev_mem(irqMaskA_offset);
    irqMaskB   <= dev_mem(irqMaskB_offset);
    -- GPIO IRQ mode
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
            IRQB_reg <= IRQB_reg_n;
            dev_mem <= dev_mem_n;
       end if;     
        
        
    end process;
    
    GPIO:process( GPIOA, dev_mem, GPIOA, GPIOB, irqMaskA, irqMaskB, irqModeA, irqModeB, Address_s, WE_s, RE_s, InBus_s,gpioa_mode, gpiob_mode) is
    begin
        -- Set deafult values
        IRQA_reg_n <= '0';
        IRQB_reg_n <= '0';
        dev_mem_n <= dev_mem;
        GPIOA_reg <= GPIOA;
        GPIOB_reg <= GPIOB;
        OutBus_s_reg <= (others => 'Z');
        
        -- GPIO logic
        port_A: for k in (GPIOA'length -1) downto 0 loop
            case gpioa_mode(k*2 + 1 downto k*2) is  -- check GPIO mode
                when INPUT_MODE =>  --output
                    GPIOA_reg(k) <= dev_mem(gpioa_offset)(k);   --Set the stored value
                when OUTPUT_MODE =>  --Input
                    dev_mem_n(gpioa_offset)(k) <= GPIOA(k);     -- Store input value
                    GPIOA_reg(k) <= 'Z'; -- Set to high impedance to avoid collision                 
                    if ( GPIOA(k) /= dev_mem(gpioa_offset)(k) ) then  -- Look for signal change
                        -- Check for enabled IRQ
                        if ( irqMaskA(k) = '1' AND dev_mem(gpioa_offset)(k) = irqModeA(k)) then
                            IRQA_reg_n <= '1';
                        end if;
                    end if;
                when others =>   
                    GPIOA_reg(k) <= 'Z';
            end case;      
        end loop;
        
        port_B: for k in (GPIOB'length -1) downto 0 loop
            case gpiob_mode(k*2 + 1 downto k*2) is
                when INPUT_MODE =>  -- Output
                    GPIOB_reg(k) <= dev_mem(gpiob_offset)(k); -- Set the stored value
                when OUTPUT_MODE =>  -- Input 
                    dev_mem_n(gpiob_offset)(k) <= GPIOB(k);
                    GPIOB_reg(k) <= 'Z'; -- Set to high impedance to avoid collision
                    if (  GPIOB(k) /= dev_mem(gpiob_offset)(k) ) then 
                        -- Check for enabled IRQ
                        if ( irqMaskB(k) = '1' AND dev_mem(gpiob_offset)(k) = irqModeB(k)) then
                            IRQB_reg_n <= '1';
                        end if;
                    end if;                              
                when others =>   
                    GPIOB_reg(k) <= 'Z';
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
