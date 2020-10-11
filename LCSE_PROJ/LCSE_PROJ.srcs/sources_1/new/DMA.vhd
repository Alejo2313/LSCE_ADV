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


signal rxCounter, rxCounter_n           : UNSIGNED(1 downto 0);
signal txCounter, txCounter_n           : STD_LOGIC;
signal mode_reg, mode_reg_n             : STD_LOGIC;  -- Operation mode: '1' RAM to RS232 '0' RS232 to RAM


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
        txCounter       <= '0';
        rxCounter       <= (others => '0');
        mode_reg        <= '0';
        Address_reg     <= (others => 'Z');
        Databus_reg     <= (others => 'Z');
        
    elsif ( Clk = '1' and Clk'event) then
        DMA_state_reg   <= DMA_state_reg_n;
        
        Data_Read_reg   <= Data_Read_reg_n;
        Valid_D_reg     <= Valid_D_reg_n;
        TX_Data_reg     <= TX_Data_reg_n;
        Write_en_reg    <= Write_en_reg_n;
        OE_reg          <= OE_reg_n;
        DMA_RQ_reg      <= DMA_RQ_reg_n;
        READY_reg       <= READY_reg_n;
        txCounter       <= txCounter_n;
        rxCounter       <= rxCounter_n;
        mode_reg        <= mode_reg_n;
        Address_reg     <= Address_reg_n;
        Databus_reg     <= Databus_reg_n;
    
    end if;
end process;


NSL2: process ( DMA_state_reg, Send_comm, rxCounter, TX_RDY, RX_Empty ) is
begin

    case DMA_state_reg is
        when IDLE =>
            --     sendComm event   or  RX data       or  second TX byte 
            if ( Send_comm = '1' or RX_Empty = '1' or ( txCounter = '1' and TX_RDY = '1' ) ) then
                DMA_state_reg_n <= FETCH;
            end if;
            
       when FETCH =>   -- Fetch data from source
            if ( DMA_ACK = '1' ) then  -- Wait for bus access
                 DMA_state_reg_n <= WRITE;
            end if;
            
        when WRITE =>  -- Load data to destination
            if ( mode_reg = '0' ) then  -- If TX mode, send one byte and return to idle (Non-blocking mode)
                if (TX_RDY = '1' ) then
                    DMA_state_reg_n <= IDLE;
                end if;
            else
                if ( rxCounter = 3 ) then -- if RX, send all bytes and return to idle (burst mode)
                    DMA_state_reg_n <= IDLE;
                else
                    DMA_state_reg_n <= FETCH;
                end if;
            end if;
                  
    end case;


end process;

LP: process ( DMA_state_reg, Send_comm, txCounter, TX_RDY, RX_Empty, DMA_ACK) is

begin
    -- Set bus lines to high impedance 
    Address_reg_n   <= (others => 'Z');
    databus_reg_n   <= (others => 'Z');
    Write_en_reg_n  <= 'Z';
    OE_reg_n        <= 'Z';
    
    -- Set default values, avoid latches 
    DMA_RQ_reg_n    <= '0';
    READY_reg_n     <= '0';
    mode_reg_n      <= '0';
    DMA_RQ_reg_n    <= '0';   
    Data_Read_reg_n <= '0'; 
    Valid_D_reg_n   <= '0';
    TX_Data_reg_n   <= TX_Data_reg;
    txCounter_n     <= txCounter;
    rxCounter_n     <= rxCounter;
    
    case DMA_state_reg is
        when IDLE =>
        
            READY_reg_n     <= '1';     -- DMA Ready
            DMA_RQ_reg_n <= '0';     -- Clean request flag
            -- SendComm event
            if ( Send_comm = '1'  or ( txCounter = '1' and TX_RDY = '1' ) ) then
                mode_reg_n   <= '0';   -- Mem to peri mode
                DMA_RQ_reg_n <= '1';   -- Request bus
           
            -- RX FIFO no empty
            elsif ( RX_Empty = '0' ) then
                mode_reg_n    <= '1';    -- Peri to mem mode
                DMA_RQ_reg_n  <= '1';   -- Request bus
            end if;
            
       when FETCH =>
            if ( DMA_ACK = '1' ) then
                if ( mode_reg = '0' ) then
                    if ( txCounter = '0' ) then
                        Address_reg_n <= STD_LOGIC_VECTOR(DMA_TX_MSB);
                        OE_reg_n <= '1';
                        txCounter_n <= '1';
                    else 
                        Address_reg_n <= STD_LOGIC_VECTOR(DMA_TX_LSB);
                        OE_reg_n <= '1';
                        txCounter_n <= '0';
                    end if; 
                else
                    Data_Read_reg_n <= '1';
                    Write_en_reg_n  <= '0';
                end if;
            end if;
            
        when WRITE =>
            if ( mode_reg = '0' ) then
                OE_reg_n <= '0';
                DMA_RQ_reg_n   <= '0';
                
                if ( TX_RDY = '1' ) then
                    TX_Data_reg   <= databus;
                    Valid_D_reg_n <= '1';
                end if;
            else
            
                if ( rxCounter = 3 ) then
                    Address_reg_n <= STD_LOGIC_VECTOR(NEW_INST);
                    Write_en_reg_n  <= '1';
                    databus_reg_n <= X"FF";
                    rxCounter_n   <= (others => '0');
                else
                    Address_reg_n <= STD_LOGIC_VECTOR(DMA_RX_MSB + rxCounter);
                    Write_en_reg  <= '1';
                    databus_reg_n <= RCVD_Data;
                    rxCounter_n   <= rxCounter + 1;
                end if;
            end if;                     
    end case;   

end process;

-- Output
Data_Read   <= Data_Read_reg;
Valid_D     <= Valid_D_reg;
TX_Data     <= TX_Data_reg;
Write_en    <= Write_en_reg;
OE          <= OE_reg;
DMA_RQ      <= DMA_RQ_reg;
READY       <= READY_reg;
Address     <= Address_reg;
Databus     <= Databus_reg;



end Behavioral;
