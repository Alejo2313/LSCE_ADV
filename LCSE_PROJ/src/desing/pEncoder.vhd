----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.10.2020 10:12:59
-- Design Name: 
-- Module Name: pEncoder - Behavioral
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


entity pEncoder is
    generic( data_width : integer := 3);
            
    port (	
        data_in : in  STD_LOGIC_VECTOR(data_width - 1 downto 0);
        data_out: out STD_LOGIC_VECTOR(log2c(data_width + 1) - 1 downto 0)
    );
end pEncoder;

architecture Behavioral of pEncoder is

begin
    logic: process ( data_in ) is
        variable tmp : STD_LOGIC_VECTOR(log2c(data_width + 1) - 1 downto 0);   
    begin
        tmp := (others => '0');
        for I in data_in'low to data_in' high loop
            if ( data_in(I) = '1' ) then
                tmp := STD_LOGIC_VECTOR(TO_UNSIGNED(I, tmp'length));
            end if;
        end loop;
        
        data_out <= tmp;
    end process;
end Behavioral;
