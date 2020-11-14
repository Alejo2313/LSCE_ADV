----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  Alejandro Gomez Molina
-- Engineer:  Luis Felipe Velez Flores
-- Create Date: 20.09.2020 12:01:18
-- Design Name: 
-- Module Name: RS232_TX - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- RS232_TX FSM. The frequency clock is 20MHz and the tx baudrate is 115200, so the length
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RS232_TX is
    Port ( Clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Start : in STD_LOGIC;
           Data : in STD_LOGIC_VECTOR (7 downto 0);
           Conf : in STD_LOGIC_VECTOR (7 DOWNTO 0);
           EOT : out STD_LOGIC;
           TX : out STD_LOGIC);
end RS232_TX;



architecture Behavioral of RS232_TX is

type TX_STATE_T is (IDLE, START_BIT, SEND_DATA, STOP_BIT);

constant MAX_CNT                    : integer := 4167; -- COUNTER MAX, corresponds to 4800 bps.
--Signals
signal state_reg, state_reg_n       : TX_STATE_T;   -- Actual and next state
signal tx_reg, tx_reg_n             : STD_LOGIC;    -- TX output registers
signal eot_reg, eot_reg_n           : STD_LOGIC;    -- End of transmition registers
signal data_reg, data_reg_n         : STD_LOGIC_VECTOR (7 downto 0);    -- Data shift register
signal config_r, config_n           : STD_LOGIC_VECTOR (7 downto 0);
signal pulse_w                      : unsigned(log2c(MAX_CNT) -1 downto 0);      -- pulse width for the desired baud rate
signal bit_reg, bit_reg_n           : unsigned(log2c(WORD_LENGTH) - 1 downto 0); -- Sended bit counter
signal counter_reg, counter_reg_n   : unsigned(log2c(MAX_CNT) -1 downto 0); -- Clock counter
signal midcnt_r, midcnt_n           : unsigned(2 downto 0);                 -- Middle wide counter

begin

-- Register process
FFs: process ( Clk, Reset ) is
begin
    -- Async reset
    if ( Reset = '1' ) then
        config_r    <= (others =>  '0');
        counter_reg <= (others => '0');
        state_reg   <= IDLE;
        tx_reg      <= '1';
        eot_reg     <= '0';
        data_reg    <= ( others => '0' );
        bit_reg     <= ( others => '0' );
        midcnt_r    <= ( others => '0' );
        
    -- clock event       
    elsif ( Clk'event and Clk = '1' ) then 
        config_r    <= config_n;
        counter_reg <= counter_reg_n;
        state_reg   <= state_reg_n;
        tx_reg      <= tx_reg_n;
        eot_reg     <= eot_reg_n;
        data_reg    <= data_reg_n;
        bit_reg     <= bit_reg_n;
        midcnt_r    <= midcnt_n;
    end if;

end process;


-- Next state logic
NSL: process (bit_reg, start, counter_reg, state_reg , pulse_w,midcnt_r,config_r) is

begin
    -- Avoid latches
    state_reg_n <= state_reg;
    
    case state_reg is
        when IDLE   =>
            if ( start = '1') then
                state_reg_n <= START_BIT;
            else
                state_reg_n <= IDLE;
            end if;
            
        when START_BIT  =>
        if ( counter_reg = PULSE_W ) then 
            state_reg_n <= SEND_DATA;
        else
            state_reg_n <= START_BIT;
        end if;
                
        when SEND_DATA  =>
            if ( bit_reg = WORD_LENGTH -1 and counter_reg = PULSE_W ) then  -- All bits sended
                state_reg_n <= STOP_BIT;
            else
                state_reg_n <= SEND_DATA;
            end if;
            
        when STOP_BIT   =>
            if (config_r(3 downto 2) = "00" and midcnt_r = "010") then
                state_reg_n <= IDLE;
            elsif (config_r(3 downto 2) = "01" and midcnt_r = "011") then
                state_reg_n <= IDLE;
            elsif(config_r(3 downto 2) = "10" and midcnt_r = "100") then
                state_reg_n <= IDLE;
            else
                state_reg_n <= STOP_BIT;
            end if;            
        when others =>
        
    end case;
end process;


logic: process (eot_reg, tx_reg, state_reg, start, data, counter_reg, bit_reg, data_reg,config_r,pulse_w,midcnt_r,Conf) is

begin
    -- Avoid latches 
    config_n        <= config_r;
    counter_reg_n   <= counter_reg + 1;
    eot_reg_n       <= eot_reg;
    data_reg_n      <= data_reg;
    tx_reg_n        <= tx_reg;
    bit_reg_n       <= bit_reg;
    eot_reg_n       <= '0';
    midcnt_n        <= midcnt_r;
    
    case state_reg is
        when IDLE   =>
            counter_reg_n   <= (others => '0');
            bit_reg_n       <= (others => '0');
            midcnt_n        <= (others => '0');
            tx_reg_n        <= '1';
             
            if ( start = '1' ) then
                eot_reg_n   <= '0';
            end if;
            
        when START_BIT  =>
            tx_reg_n        <= '0';
            if ( counter_reg = PULSE_W ) then
                counter_reg_n   <= (others => '0');
                bit_reg_n       <= (others => '0');
                data_reg_n      <= data;
                config_n        <= Conf;
             end if;
            
        when SEND_DATA  =>
            tx_reg_n    <=  data_reg(0);
            
            if ( counter_reg = PULSE_W ) then
                bit_reg_n       <= bit_reg + 1;
                data_reg_n      <= '1'&data_reg(7 downto 1);
                counter_reg_n   <= (others => '0');

            end if;
        
        when STOP_BIT   =>
            tx_reg_n <= '1';
            if (counter_reg = PULSE_W/2) then
                midcnt_n <= midcnt_r + 1;
            end if;
            if ( counter_reg = PULSE_W ) then
                eot_reg_n   <= '1';
                counter_reg_n   <= (others => '0');
                midcnt_n <= midcnt_r + 1;
            end if;
        when others =>
            
    end case;
    
end process;

-- BAUD RATE CONFIGURATION
pulse_w <= TO_UNSIGNED(174,13)   when config_r(4 downto 3) = "00" else  -- 4800
           TO_UNSIGNED(521,13)   when config_r(4 downto 3) = "01" else  -- 9600
           TO_UNSIGNED(2084,13)  when config_r(4 downto 3) = "10" else  -- 38400
           TO_UNSIGNED(4167,13);                                        -- 115200

-- output

EOT <= eot_reg;
TX  <= tx_reg;

end Behavioral;