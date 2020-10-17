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
           EOT : out STD_LOGIC;
           TX : out STD_LOGIC);
end RS232_TX;



architecture Behavioral of RS232_TX is


type TX_STATE_T is (IDLE, START_BIT, SEND_DATA, STOP_BIT);

--Signals
signal state_reg, state_reg_n       : TX_STATE_T;   -- Actual and next state
signal tx_reg, tx_reg_n             : STD_LOGIC;    -- TX output registers
signal eot_reg, eot_reg_n           : STD_LOGIC;    -- End of transmition registers
signal data_reg, data_reg_n         : STD_LOGIC_VECTOR (7 downto 0);    -- Data shift register
signal bit_reg, bit_reg_n           : unsigned(log2c(WORD_LENGTH) - 1 downto 0); -- Sended bit counter
signal counter_reg, counter_reg_n   : unsigned(log2c(PULSE_W) -1 downto 0); -- Clock counter


begin

-- Register process
FFs: process ( Clk, Reset ) is
begin
    -- Async reset
    if ( Reset = '1' ) then
        state_reg   <= IDLE;
        tx_reg      <= '1';
        eot_reg     <= '0';
        data_reg    <= ( others => '0' );
        bit_reg     <= ( others => '0' );
    -- clock event       
    elsif ( Clk'event and Clk = '1' ) then
        counter_reg <= counter_reg_n;
        state_reg   <= state_reg_n;
        tx_reg      <= tx_reg_n;
        eot_reg     <= eot_reg_n;
        data_reg    <= data_reg_n;
        bit_reg     <= bit_reg_n;
    end if;

end process;


-- Next state logic
NSL: process (bit_reg, start, counter_reg, state_reg ) is

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
            if ( counter_reg = PULSE_W ) then
                state_reg_n <= IDLE;
            else
                state_reg_n <= STOP_BIT;
            end if;
            
        when others =>
        
    end case;
end process;


logic: process (eot_reg, tx_reg, state_reg, start, data, counter_reg, bit_reg, data_reg) is

begin
    -- Avoid latches 
    counter_reg_n   <= counter_reg + 1;
    eot_reg_n       <= eot_reg;
    data_reg_n      <= data_reg;
    tx_reg_n        <= tx_reg;
    bit_reg_n       <= bit_reg;
    eot_reg_n       <= '0';
    
    case state_reg is
        when IDLE   =>
            counter_reg_n   <= (others => '0');
            bit_reg_n       <= (others => '0');
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
             end if;
            
        when SEND_DATA  =>
            tx_reg_n    <=  data_reg(0);
            
            if ( counter_reg = PULSE_W ) then
                bit_reg_n       <= bit_reg + 1;
                data_reg_n      <= '1'&data_reg(log2c(PULSE_W) -1 downto 1); 
                counter_reg_n   <= (others => '0');

            end if;
        
        when STOP_BIT   =>
            tx_reg_n <= '1';
            if ( counter_reg = PULSE_W -1 ) then
                eot_reg_n   <= '1';
            end if;
        when others =>
            
    end case;

end process;


-- output

EOT <= eot_reg;
TX  <= tx_reg;


end Behavioral;