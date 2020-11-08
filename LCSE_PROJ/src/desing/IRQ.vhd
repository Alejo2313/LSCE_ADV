----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.10.2020 19:19:06
-- Design Name: 
-- Module Name: IRQ - Behavioral
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

entity IRQ is
    Port ( Clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Address_s : in STD_LOGIC_VECTOR (7 downto 0);
           InBus_s : in STD_LOGIC_VECTOR (7 downto 0);
           outBus_s : out STD_LOGIC_VECTOR (7 downto 0);
           WE_s : in STD_LOGIC;
           RE_s : in STD_LOGIC;
           IRQV : in STD_LOGIC_VECTOR (7 downto 0);
           IRQ_E : out STD_LOGIC);
end IRQ;

architecture Behavioral of IRQ is

signal IRQV_reg, IRQV_reg_n :  STD_LOGIC_VECTOR (7 downto 0);
signal IRQ_E_reg, IRQ_E_reg_n  : STD_LOGIC;
signal OutBus_s_reg :  STD_LOGIC_VECTOR (7 downto 0);

begin

FF: process (Clk, Reset) is 
begin
    if ( Reset = '1' ) then
        IRQV_reg <= (others => '0');
        IRQ_E_reg <= '0';
    elsif (Clk'event and Clk = '1' ) then
        IRQV_reg <= IRQV_reg_n;
        IRQ_E_reg <= IRQ_E_reg_n;
    end if;
end process;

LOGIC: process ( IRQV_reg, Address_s, IRQV, Address_s, WE_s, RE_s, inBus_s) is
    variable tmp: std_logic;
begin
    OutBus_s_reg <= (others => 'Z');
    tmp := '0';
    
    for k in (IRQV_reg'length -1) downto 0 loop
        tmp:= IRQV_reg(k) or tmp;
    end loop;
    IRQ_E_reg_n <= tmp;
 
    IRQV_reg_n <= IRQV_reg or IRQV;
    
    if ( unsigned(Address_s(7 downto 4)) = IRQ_BASE(7 downto 4) )  then
        if( WE_s = '1' ) then
            IRQV_reg_n <= inBus_s or IRQV;
            IRQ_E_reg_n <= '0';
        elsif ( RE_s = '1' ) then
            OutBus_s_reg <= IRQV_reg;
        end if;
    end if;      
end process;

IRQ_E <= IRQ_E_reg;
outBus_s <= OutBus_s_reg;
end Behavioral;
