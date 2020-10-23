----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.10.2020 15:52:03
-- Design Name: 
-- Module Name: display - Behavioral
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

entity display is
    Port ( Clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Address_s : in STD_LOGIC_VECTOR (7 downto 0);
           InBus_s : in STD_LOGIC_VECTOR (7 downto 0);
           outBus_s : out STD_LOGIC_VECTOR (7 downto 0);
           WE_s : in STD_LOGIC;
           RE_s : in STD_LOGIC);
end display;

architecture Behavioral of display is
    type dev_mem_8 is array (0 to 4) of std_logic_vector(7 downto 0);
    
    
    
    --Components
    component decod7s 
        Port ( D : in  STD_LOGIC_VECTOR (3 downto 0);					
               S : out  STD_LOGIC_VECTOR (7 downto 0));   	
    end component;
    
    signal S                    : STD_LOGIC_VECTOR (7 downto 0);
    signal D                    : STD_LOGIC_VECTOR (3 downto 0);    
begin

    decoder: decod7s 
        port map ( D => D,
                   S => S);

end Behavioral;
