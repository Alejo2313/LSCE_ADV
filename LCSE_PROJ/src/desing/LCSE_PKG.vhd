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

    procedure send_string
        (  cmd : in string;
           signal tx : out std_logic);
-------------------------------------------------------------------------------
-- MEMORY MAP
-------------------------------------------------------------------------------

    CONSTANT sIRQ                   : UNSIGNED( 7 downto 0) := X"00" ;
    CONSTANT IRQ_BASE               : UNSIGNED( 7 downto 0) := sIRQ ;
    CONSTANT eIRQ                   : UNSIGNED( 7 downto 0) := X"00" ;
    
    CONSTANT sRAM                   : UNSIGNED( 7 downto 0) := X"10" ;
    CONSTANT eRAM                   : UNSIGNED( 7 downto 0) := X"BF" ;
    
    constant sDMA                   : UNSIGNED( 7 downto 0 ) := X"C0";
    constant DMA_MEM_BASE           : UNSIGNED( 7 downto 0 ) := sDMA;
    constant DMA_CH1_BASE           : UNSIGNED( 7 downto 0 ) := DMA_MEM_BASE + 0;
        constant DMA_CONF_CH1       : UNSIGNED( 7 downto 0 ) := DMA_CH1_BASE + 0;
        constant DMA_SRC_CH1        : UNSIGNED( 7 downto 0 ) := DMA_CH1_BASE + 1;
        constant DMA_DEST_CH1       : UNSIGNED( 7 downto 0 ) := DMA_CH1_BASE + 2;
        constant DMA_CNT_CH1        : UNSIGNED( 7 downto 0 ) := DMA_CH1_BASE + 3;
         
    constant DMA_CH2_BASE           : UNSIGNED( 7 downto 0 ) := DMA_MEM_BASE + 4;
        constant DMA_CONF_CH2       : UNSIGNED( 7 downto 0 ) := DMA_CH2_BASE + 0;
        constant DMA_SRC_CH2        : UNSIGNED( 7 downto 0 ) := DMA_CH2_BASE + 1;
        constant DMA_DEST_CH2       : UNSIGNED( 7 downto 0 ) := DMA_CH2_BASE + 2;
        constant DMA_CNT_CH2        : UNSIGNED( 7 downto 0 ) := DMA_CH2_BASE + 3; 
        
    constant DMA_CH3_BASE           : UNSIGNED( 7 downto 0 ) := DMA_MEM_BASE + 8;
        constant DMA_CONF_CH3       : UNSIGNED( 7 downto 0 ) := DMA_CH3_BASE + 0;
        constant DMA_SRC_CH3        : UNSIGNED( 7 downto 0 ) := DMA_CH3_BASE + 1;
        constant DMA_DEST_CH3       : UNSIGNED( 7 downto 0 ) := DMA_CH3_BASE + 2;
        constant DMA_CNT_CH3        : UNSIGNED( 7 downto 0 ) := DMA_CH3_BASE + 3; 
    constant eDMA                   : UNSIGNED( 7 downto 0 ) := X"CF";    
    
    
    CONSTANT sRS232                 : UNSIGNED( 7 downto 0 ) := X"D0";
    CONSTANT RS232_BASE             : UNSIGNED( 7 downto 0 ) := sRS232;
        CONSTANT RS232_CONF         : UNSIGNED( 7 downto 0 ) := RS232_BASE + 0;
        CONSTANT RS232_STATUS       : UNSIGNED( 7 downto 0 ) := RS232_BASE + 1;
        CONSTANT RS232_TX_DATA      : UNSIGNED( 7 downto 0 ) := RS232_BASE + 2;
        CONSTANT RS232_RX_DATA      : UNSIGNED( 7 downto 0 ) := RS232_BASE + 3; 
    CONSTANT    eRS232              : UNSIGNED( 7 downto 0 ) := X"D7"; 
 
    CONSTANT sDISPLAY               : UNSIGNED( 7 downto 0 ) := X"D8";
        CONSTANT DISPLAY_BASE       : UNSIGNED( 7 downto 0 ) := sDISPLAY;
        CONSTANT DISPLAY_EN         : UNSIGNED( 7 downto 0 ) := DISPLAY_BASE + 0;
        CONSTANT DISPLAY_IEN        : UNSIGNED( 7 downto 0 ) := DISPLAY_BASE + 1;
        CONSTANT DISPLAY_01         : UNSIGNED( 7 downto 0 ) := DISPLAY_BASE + 2;
        CONSTANT DISPLAY_23         : UNSIGNED( 7 downto 0 ) := DISPLAY_BASE + 3;
        CONSTANT DISPLAY_45         : UNSIGNED( 7 downto 0 ) := DISPLAY_BASE + 4;
        CONSTANT DISPLAY_67         : UNSIGNED( 7 downto 0 ) := DISPLAY_BASE + 5;
    CONSTANT eDISPLAY               : UNSIGNED( 7 downto 0 ) := X"DF";
    
    CONSTANT sGPIO                  : UNSIGNED( 7 downto 0 ) := X"E0";
    CONSTANT GPIO_BASE              : UNSIGNED( 7 downto 0 ) := sGPIO;
        CONSTANT GPIO_IRQA_MASK     : UNSIGNED( 7 downto 0 ) := GPIO_BASE + 0;
        CONSTANT GPIO_IRQB_MASK     : UNSIGNED( 7 downto 0 ) := GPIO_BASE + 1;
        CONSTANT GPIO_IRQMODEA_MASK : UNSIGNED( 7 downto 0 ) := GPIO_BASE + 2;
        CONSTANT GPIO_IRQMODEB_MASK : UNSIGNED( 7 downto 0 ) := GPIO_BASE + 3;
        CONSTANT GPIO_MODEA_REG1    : UNSIGNED( 7 downto 0 ) := GPIO_BASE + 4;
        CONSTANT GPIO_MODEA_REG2    : UNSIGNED( 7 downto 0 ) := GPIO_BASE + 5;
        CONSTANT GPIO_MODEB_REG1    : UNSIGNED( 7 downto 0 ) := GPIO_BASE + 6;
        CONSTANT GPIO_MODEB_REG2    : UNSIGNED( 7 downto 0 ) := GPIO_BASE + 7;
        CONSTANT GPIO_AFMODEA_REG   : UNSIGNED( 7 downto 0 ) := GPIO_BASE + 8;
        CONSTANT GPIO_AFMODEB_REG   : UNSIGNED( 7 downto 0 ) := GPIO_BASE + 9;
        CONSTANT GPIO_A             : UNSIGNED( 7 downto 0 ) := GPIO_BASE + 10;
        CONSTANT GPIO_B             : UNSIGNED( 7 downto 0 ) := GPIO_BASE + 11;
    CONSTANT eGPIO                  : UNSIGNED( 7 downto 0 ) := X"EF";
    
    
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
    
    
    procedure send_string (   cmd : in string;
                             signal tx : out std_logic) is
                             
        variable tmp : std_logic_vector(7 downto 0);
    begin 
       
        for i in cmd'range  loop
            wait for 8.68us;
            tmp := std_logic_vector(to_unsigned(character'pos(cmd(i)), 8))  AND X"7F";
            
            tx <= '0';
            wait for 8.68us;
            for i in 0 to (tmp'length -1) loop
                tx <= tmp(i);
                wait for 8.68us;
            end loop;
            tx <= '1';
            wait for 8.68us;
        end loop;
     
        
    end send_string;
    

end LCSE_PKG;
