----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  Alejandro Gomez Molina
-- 
-- Create Date: 20.09.2020 12:03:30
-- Design Name: 
-- Module Name: RS232_RX - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RS232_RX is
    Port ( Clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           LineRD_in : in STD_LOGIC;
           Valid_out : out STD_LOGIC;
           Code_out : out STD_LOGIC;
           Store_out : out STD_LOGIC);
end RS232_RX;

architecture Behavioral of RS232_RX is

type RX_STATE_T is (IDLE, START_BIT, RVCDATA, STOP_BIT);


Constant MAXCOUNT       : integer := 174;
constant HALFCOUNT      : integer := 87;

-- signal

signal state_reg, state_reg_n           : RX_STATE_T;
signal counter_reg, counter_reg_n       : UNSIGNED(7 downto 0);
signal bit_reg, bit_reg_n               : UNSIGNED(3 downto 0);
signal Valid_out_reg, Valid_out_reg_n   : STD_LOGIC := '0';
signal Code_out_reg, Code_out_reg_n     : STD_LOGIC := '0';
signal Store_out_reg, Store_out_reg_n   : STD_LOGIC := '0';


begin


FFs: process ( clk, reset ) is 
begin
    if ( Reset = '0' ) then
        state_reg       <= IDLE;
        counter_reg     <= ( others => '0' );
        Valid_out_reg   <= '0';
        bit_reg         <= ( others => '0' );
        Store_out_reg   <= '0';
        code_out_reg    <= '0';
        
    elsif ( Clk'event and Clk = '1' ) then
        state_reg       <= state_reg_n;
        counter_reg     <= counter_reg_n;
        Valid_out_reg   <= Valid_out_reg_n;
        bit_reg         <= bit_reg_n;
        Store_out_reg   <= Store_out_reg_n;
        code_out_reg    <= code_out_reg_n;
    
    end if;

end process;

NSL: process ( state_reg, LineRD_in, counter_reg, bit_reg ) is

begin
    state_reg_n <= state_reg;
    case state_reg is 
        when IDLE =>
            if ( LineRD_in = '0' ) then
                state_reg_n <= START_BIT;
            end if;
            
        when START_BIT =>
            if ( counter_reg = MAXCOUNT ) then
                state_reg_n <= RVCDATA;
            end if;
            
        when RVCDATA =>
            if ( bit_reg = 8 ) then
                state_reg_n <= STOP_BIT;
            end if;
        
        when STOP_BIT =>
            if ( counter_reg = MAXCOUNT ) then
                state_reg_n <= IDLE;
            end if;  
    end case;

end process;


LOGIC: process (LineRD_in, code_out_reg, state_reg, counter_reg, bit_reg ) is

begin
    counter_reg_n   <= counter_reg + 1;
    bit_reg_n       <= bit_reg;
    code_out_reg_n  <= code_out_reg;
    Valid_out_reg_n <= '0';
    store_out_reg_n <= '0';
    
    case state_reg is 
        when IDLE =>
            counter_reg_n <= ( others => '0' );
        when START_BIT =>
            if ( counter_reg = MAXCOUNT ) then
                counter_reg_n   <= ( others => '0' );
                bit_reg_n       <= ( others => '0' );  
            end if;
        
        when RVCDATA =>
            
            if ( counter_reg  = HALFCOUNT ) then
                code_out_reg_n <= LineRD_in;
                
            elsif ( counter_reg = MAXCOUNT ) then
                Valid_out_reg_n <= '1';
                counter_reg_n <= ( others => '0' );
                bit_reg_n     <= bit_reg + 1;
                
            else
                Valid_out_reg_n <= '0';
            end if;
            
        
        when STOP_BIT =>
            
            if ( counter_reg  = HALFCOUNT ) then
                store_out_reg_n <= LineRD_in;
            else
                Valid_out_reg_n <= '0';
            end if;
    
    end case;

end process;


Valid_out   <= Valid_out_reg;
code_out    <= code_out_reg;
store_out   <= store_out_reg_n;

end Behavioral;
