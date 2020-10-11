----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.10.2020 16:50:17
-- Design Name: 
-- Module Name: DMA - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use work.LCSE_PKG.all;

entity DMA is
    Port ( Reset        : in    STD_LOGIC;                      -- System reset
           Clk          : in    STD_LOGIC;                      -- System Clock
           --RS232 RX Signals 
           RCVD_Data    : in    STD_LOGIC_VECTOR (7 downto 0);  -- RS232 RX byte
           RX_Full      : in    STD_LOGIC;                      -- Internal FIFO state
           RX_Empty     : in    STD_LOGIC;                      -- Internal FIFO state
           Data_Read    : out   STD_LOGIC;                      -- Data read request
           
           -- RS232 TX signals
           ACK_out      : in    STD_LOGIC;                      -- TX byte validation 
           TX_RDY       : in    STD_LOGIC;                      -- TX internal state
           Valid_D      : out   STD_LOGIC;                      -- Input byte validation 
           TX_Data      : out   STD_LOGIC_VECTOR (7 downto 0);  -- Sended byte
           
           -- RAM Signals
           Address      : out   STD_LOGIC_VECTOR (7 downto 0);  -- Address bus
           Databus      : inout STD_LOGIC_VECTOR (7 downto 0);  -- Data bus
           Write_en     : out   STD_LOGIC;                      -- Write enable 
           OE           : out   STD_LOGIC;                      -- Read enalbe 
           
           -- Control Signals 
           DMA_ACK      : in    STD_LOGIC;                      -- Data bus state
           Send_comm    : in    STD_LOGIC;                      -- Start transmission 
           DMA_RQ       : out   STD_LOGIC;                      -- Data bus Request
           READY        : out   STD_LOGIC);                     -- DMA state.
           
end DMA;

architecture Behavioral of DMA is


type DMA_STATE_T is (IDLE, FETCH, TAKE_BUS, WRITE);

signal rxCounter, rxCounter_n : UNSIGNED(1 downto 0);
signal txCounter, txCounter_n : UNSIGNED(0 downto 0);

signal mode_reg, mode_reg_n   : STD_LOGIC;  -- Operation mode: '1' RAM to RS232 '0' RS232 to RAM
-- DMA State regd
signal DMA_state_reg, DMA_state_reg_n   : DMA_STATE_T;

-- Output registered signals
signal Data_Read_reg, Data_Read_reg_n   : STD_LOGIC;
signal Valid_D_reg, Valid_D_reg_n       : STD_LOGIC;
signal TX_Data_reg, TX_Data_reg_n       : STD_LOGIC_VECTOR (7 downto 0);
signal Write_en_reg, Write_en_reg_n     : STD_LOGIC;
signal OE_reg, OE_reg_n                 : STD_LOGIC;
signal DMA_RQ_reg, DMA_RQ_reg_n         : STD_LOGIC;
signal READY_reg, READY_reg_n           : STD_LOGIC;
signal Address_reg, Address_reg_n       : STD_LOGIC_VECTOR (7 downto 0);
signal Databus_reg, Databus_reg_n       : STD_LOGIC_VECTOR (7 downto 0);


begin


FF:process( Clk, Reset) is
begin
    if( Reset = '0' ) then
        DMA_state_reg   <= IDLE;
        
        Data_Read_reg   <= '0';
        Valid_D_reg     <= '0';
        TX_Data_reg     <= (others => '0');
        Write_en_reg    <= '0';
        OE_reg          <= '0';
        DMA_RQ_reg      <= '0';
        READY_reg       <= '0';
        txCounter       <= (others => '0');
        rxCounter       <= (others => '0');
        mode_reg        <= '0';
        
    elsif ( Clk = '1' and Clk'event) then
        DMA_state_reg   <= DMA_state_reg_n;
        
        mode_reg        <= mode_reg_n;
        Data_Read_reg   <= Data_Read_reg_n;
        Valid_D_reg     <= Valid_D_reg_n;
        TX_Data_reg     <= TX_Data_reg_n;
        Write_en_reg    <= Write_en_reg_n;
        OE_reg          <= OE_reg_n;
        DMA_RQ_reg      <= DMA_RQ_reg_n;
        txCounter       <= txCounter_n;
        rxCounter       <= rxCounter_n;
        READY_reg       <= READY_reg_n;
    
    end if;


end process;

NSL: process(RX_Empty, Send_comm, DMA_state_reg, TX_RDY, DMA_ACK) is

begin
    case DMA_state_reg is 
        when IDLE       =>                                      -- System reday. Waiting for events 
            -- Check if data available in FIFO   
            if ( RX_empty = '0' ) then                          
                DMA_state_reg <= FETCH;
                
            -- Look for send request    
            elsif ( Send_comm = '1' or txCounter = 1 ) then
                DMA_state_reg <= TAKE_BUS;
            end if;
        
        when FETCH =>
            -- If it's a MEM -> RS232 operation 
            if ( mode_reg = '1' ) then
                if ( DMA_ACK = '1' ) then       -- Wait for bus access
                    DMA_state_reg <= WRITE;     -- Go to writr
                end if;
                
            else
                DMA_state_reg <= TAKE_BUS;     
            end if;
            
        when TAKE_BUS =>
            if ( mode_reg = '1' ) then
                DMA_state_reg <= FETCH;
            else
                DMA_state_reg <= WRITE;     
            end if;
            
        when WRITE =>
           if ( mode_reg = '1' ) then
                if ( TX_RDY = '1' ) then        
                    DMA_state_reg <= IDLE; 
                end if;  
           else
                if ( DMA_ACK = '1' ) then
                    DMA_state_reg <= IDLE;
                end if;
           end if;
    end case;
end process;



LOGIC: process ( DMA_state_reg, DMA_ACK ) is

begin
    READY_reg_n     <= '0';
    DMA_RQ_reg_n    <= DMA_RQ_reg;
    
    Valid_D_reg_n   <= '0';
    Data_Read_reg_n <= '0';
    mode_reg_n      <= mode_reg;
    
    Address_reg_n   <= (others => 'Z' );
    Databus_reg_n   <= (others => 'Z' );
    Write_en_reg_n  <= 'Z';
    OE_reg_n        <= 'Z';
    
    
    case DMA_state_reg is 
        when IDLE       =>                                      -- System reday. Waiting for events 
            READY_reg_n <= '1';
            -- Check if data available in FIFO   
            if ( RX_empty = '0' ) then                          
                mode_reg_n <= '0';
                READY_reg_n <= '0';
            -- Look for send request    
            elsif ( Send_comm = '1' or txCounter = 1 ) then
                mode_reg_n <= '1';
                READY_reg_n <= '0';
            end if;
        
        when FETCH =>
            if ( mode_reg = '1' ) then
                if ( DMA_ACK = '1' ) then   -- Fetch data from RAM   
                    DMA_RQ_reg_n   <= '0';
                    Address_reg_n  <= STD_LOGIC_VECTOR( DMA_TX_MSB + txCounter );
                    OE_reg_n       <= '1';
                    txCounter_n <= txCounter + 1;
                end if;
                
            else
                Data_Read_reg_n <= '1';     -- Request FIFO data 
            end if;
            
            
        when TAKE_BUS =>
            DMA_RQ_reg_n <= '1';
            
        when WRITE =>
           if ( mode_reg = '1' ) then
                  if ( TX_RDY = '1' ) then
                    Valid_D_reg_n <= '1';
                    TX_Data_reg_n <= databus;
                  end if;
           else
                if ( DMA_ACK = '1' ) then
                    DMA_RQ_reg_n   <= '0';
                    Address_reg_n  <= STD_LOGIC_VECTOR( DMA_TX_MSB + rxCounter );
                    Write_en_reg_n <= '1';
                    Databus_reg_n  <= RCVD_Data;
                    
                    if (rxCounter = 2 ) then
                         rxCounter_n <= (others => '0');
                    else
                        rxCounter_n  <= rxCounter + 1;  
                    end if;
                end if;
           end if;
    end case;
        

end process;

Data_Read   <= Data_Read_reg;
Valid_D     <= Valid_D_reg;
TX_Data     <= TX_Data_reg;
Write_en    <= Write_en_reg;
OE          <= OE_reg;
DMA_RQ      <= DMA_RQ_reg;




end Behavioral;
