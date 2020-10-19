----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Alejandro Gomez Molina
-- Engineer: Luis Felipe Velez Flores
-- Create Date: 04.10.2020 23:39:40
-- Design Name: 
-- Module Name: LCSE_P1 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- Package that contains constants and useful functions.
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

--package declaration
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;


package LCSE_PKG is
-------------------------------------------------------------------------------
-- MEMORY MAP
-------------------------------------------------------------------------------


    CONSTANT sRAM       : UNSIGNED( 7 downto 0) := X"10" ;
    CONSTANT eRAM       : UNSIGNED( 7 downto 0) := X"1F" ;
    
    constant DMA_MEM_BASE       : UNSIGNED( 7 downto 0 ) := X"C0";
    constant DMA_CH1_OFF       : UNSIGNED( 3 downto 0 ) := X"0";
        constant DMA_CONF_CH1      : UNSIGNED( 3 downto 0 ) := DMA_CH1_OFF + X"0";
        constant DMA_SRC_CH1       : UNSIGNED( 3 downto 0 ) := DMA_CH1_OFF + X"1";
        constant DMA_DEST_CH1      : UNSIGNED( 3 downto 0 ) := DMA_CH1_OFF + X"2";
        constant DMA_CNT_CH1       : UNSIGNED( 3 downto 0 ) := DMA_CH1_OFF + X"3";
         
    constant DMA_CH2_OFF       : UNSIGNED( 3 downto 0 ) := X"4";
        constant DMA_CONF_CH2      : UNSIGNED( 3 downto 0 ) := DMA_CH2_OFF + X"0";
        constant DMA_SRC_CH2       : UNSIGNED( 3 downto 0 ) := DMA_CH2_OFF + X"1";
        constant DMA_DEST_CH2      : UNSIGNED( 3 downto 0 ) := DMA_CH2_OFF + X"2";
        constant DMA_CNT_CH2      : UNSIGNED( 3 downto 0 ) := DMA_CH2_OFF + X"3"; 
        
    constant DMA_CH3_OFF       : UNSIGNED( 3 downto 0 ) := X"8";
        constant DMA_CONF_CH3      : UNSIGNED( 3 downto 0 ) := DMA_CH3_OFF + X"0";
        constant DMA_SRC_CH3       : UNSIGNED( 3 downto 0 ) := DMA_CH3_OFF + X"1";
        constant DMA_DEST_CH3      : UNSIGNED( 3 downto 0 ) := DMA_CH3_OFF + X"2";
        constant DMA_CNT_CH3       : UNSIGNED( 3 downto 0 ) := DMA_CH3_OFF + X"3"; 
        
    constant DMA_CONF_OFF      : UNSIGNED( 3 downto 0 ) := X"0";
    constant DMA_SRC_OFF       : UNSIGNED( 3 downto 0 ) := X"1";
    constant DMA_DEST_OFF      : UNSIGNED( 3 downto 0 ) := X"2";
    constant DMA_CNT_OFF       : UNSIGNED( 3 downto 0 ) := X"3";
    
    
    CONSTANT    sRS232          :  UNSIGNED( 7 downto 0 ):= X"D0";
    CONSTANT    RS232_BASE      :  UNSIGNED( 7 downto 0 ):= sRS232;
        CONSTANT RS232_CONF     : UNSIGNED( 7 downto 0 ) := RS232_BASE + 0;
        CONSTANT RS232_STATUS   : UNSIGNED( 7 downto 0 ) := RS232_BASE + 1;
        CONSTANT RS232_TX_DATA  : UNSIGNED( 7 downto 0 ) := RS232_BASE + 2;
        CONSTANT RS232_RX_DATA  : UNSIGNED( 7 downto 0 ) := RS232_BASE + 3; 
    CONSTANT    eRS232          :  UNSIGNED( 7 downto 0 ):= RS232_BASE + 3; 
 
  
  

    CONSTANT PULSE_W        : INTEGER := 174;
    CONSTANT HALFCOUNT      : INTEGER := PULSE_W/2;
    CONSTANT WORD_LENGTH    : INTEGER := 8;
        
    SUBTYPE item_array8_ram IS std_logic_vector (7 downto 0);
    TYPE array8_ram IS array (integer range <>) of item_array8_ram;
    
    function log2c (n: integer) return integer;
end LCSE_PKG;

-- package body
package body LCSE_PKG is
    function log2c (n: integer) return integer is
        variable m, p : integer;
        begin
        m := 0;
        p := 1;
        while p < n loop
            m := m +1 ;
            p := p*2;
        end loop;
        return m;
    end log2c;
end LCSE_PKG;
