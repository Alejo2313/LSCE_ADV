----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  Alejandro Gomez Molina
-- Engineer:  Luis Felipe Velez Flores
-- Create Date: 20.09.2020 12:03:30
-- Design Name: 
-- Module Name: RS232_RX - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- RS232_RX FSM. The frequency clock is 20MHz and the tx baudrate is 115200, so the length
-- of a bit must be 20000000/115200, rounded 174.
-- Dependencies: 
-- Use LCSE_P1.all that constains some constants : pulse width, word length and fsm states.
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.LCSE_PKG.all;


entity RS232_RX is
    Port ( Clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           LineRD_in : in STD_LOGIC;
           Conf : in STD_LOGIC_VECTOR (7 DOWNTO 0);
           
           Valid_out : out STD_LOGIC;
           Code_out : out STD_LOGIC;
           Store_out : out STD_LOGIC);
end RS232_RX;

architecture Behavioral of RS232_RX is



type RX_STATE_T is (IDLE, START_BIT, RVCDATA, STOP_BIT);
constant MAX_CNT                    : integer := 4167; -- COUNTER MAX, corresponds to 4800 bps.
-- signal

signal state_reg, state_reg_n           : RX_STATE_T;
signal counter_reg, counter_reg_n       : UNSIGNED(log2c(MAX_CNT) -1 downto 0);
signal bit_reg, bit_reg_n               : UNSIGNED(log2c(WORD_LENGTH) downto 0);
signal config_r, config_n           : STD_LOGIC_VECTOR (7 downto 0);
signal pulse_w                      : unsigned(log2c(MAX_CNT) -1 downto 0);      -- pulse width for the desired baud rate
signal midcnt_r, midcnt_n           : unsigned(2 downto 0);                      -- Middle wide counter
signal Valid_out_reg, Valid_out_reg_n   : STD_LOGIC;
signal Code_out_reg, Code_out_reg_n     : STD_LOGIC;
signal Store_out_reg, Store_out_reg_n   : STD_LOGIC;


begin


FFs: process ( clk, reset ) is 
begin
    if ( Reset = '1' ) then
        state_reg       <= IDLE;
   --     config_r        <= ( others => '0' );
        counter_reg     <= ( others => '0' );
        midcnt_r        <= ( others => '0' );
        Valid_out_reg   <= '0';
        bit_reg         <= ( others => '0' );
        Store_out_reg   <= '0';
        code_out_reg    <= '0';
        
    elsif ( Clk'event and Clk = '1' ) then
        state_reg       <= state_reg_n;
   --     config_r        <= config_n;
        counter_reg     <= counter_reg_n;
        midcnt_r        <= midcnt_n;
        Valid_out_reg   <= Valid_out_reg_n;
        bit_reg         <= bit_reg_n;
        Store_out_reg   <= Store_out_reg_n;
        code_out_reg    <= code_out_reg_n;
    
    end if;

end process;

NSL: process ( state_reg, LineRD_in, counter_reg, bit_reg,pulse_w, midcnt_r, conf) is

begin
    state_reg_n <= state_reg;
    case state_reg is 
        when IDLE =>
            if ( LineRD_in = '0' ) then
                state_reg_n <= START_BIT;
            end if;
            
        when START_BIT =>
            if ( counter_reg = PULSE_W ) then
                state_reg_n <= RVCDATA;
            end if;
            
        when RVCDATA =>
            if ( bit_reg = WORD_LENGTH ) then
                state_reg_n <= STOP_BIT;
            end if;
        
        when STOP_BIT =>
            if (conf(3 downto 2) = "00" and midcnt_r = "010") then
                state_reg_n <= IDLE;
            elsif (conf(3 downto 2) = "01" and midcnt_r = "011") then
                state_reg_n <= IDLE;
            elsif(conf(3 downto 2) = "10" and midcnt_r = "100") then
                state_reg_n <= IDLE;
            else
                state_reg_n <= STOP_BIT;
            end if;  
    end case;

end process;


LOGIC: process ( LineRD_in, code_out_reg, state_reg, counter_reg, bit_reg,conf,pulse_w,midcnt_r,Conf ) is

begin
    counter_reg_n   <= counter_reg + 1;
    bit_reg_n       <= bit_reg;
    code_out_reg_n  <= code_out_reg;
    Valid_out_reg_n <= '0';
    store_out_reg_n <= '0';
   -- config_n        <= config_r;
    midcnt_n        <= midcnt_r;
    
    case state_reg is 
        when IDLE =>
            counter_reg_n <= ( others => '0' );
            midcnt_n      <= ( others => '0' );
            
        when START_BIT =>
            if ( counter_reg = PULSE_W ) then
                counter_reg_n   <= ( others => '0' );
                bit_reg_n       <= ( others => '0' );  
                
            end if;
        
        when RVCDATA =>
            
            if ( counter_reg  = pulse_w/2 ) then
                code_out_reg_n <= LineRD_in;
                
            elsif ( counter_reg = pulse_w ) then
                Valid_out_reg_n <= '1';
                counter_reg_n <= ( others => '0' );
                bit_reg_n     <= bit_reg + 1;
                
            else
                Valid_out_reg_n <= '0';
            end if;
            
        
        when STOP_BIT =>
            
            if ( counter_reg  = pulse_w/2 ) then
                store_out_reg_n <= LineRD_in;
                midcnt_n <= midcnt_r + 1;
            else
                Valid_out_reg_n <= '0';
            end if;
            if ( counter_reg = PULSE_W -1 ) then
                midcnt_n <= midcnt_r + 1;
                counter_reg_n   <= (others => '0');
            end if;
    
    end case;

end process;

-- BAUD RATE CONFIGURATION
pulse_w <= TO_UNSIGNED(174,13)   when conf(4 downto 3) = "00" else  -- 4800
           TO_UNSIGNED(521,13)   when conf(4 downto 3) = "01" else  -- 9600
           TO_UNSIGNED(2084,13)  when conf(4 downto 3) = "10" else  -- 38400
           TO_UNSIGNED(4167,13);                                        -- 115200

-- Output
Valid_out   <= Valid_out_reg;
code_out    <= code_out_reg;
store_out   <= store_out_reg_n;

end Behavioral;