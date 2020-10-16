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

    CONSTANT sDMA       :   UNSIGNED( 7 downto 0 ) := X"00";
        CONSTANT DMA_RX_MSB :   UNSIGNED( 7 downto 0 ) := X"00";
        CONSTANT DMA_RX     :   UNSIGNED( 7 downto 0 ) := X"00";
        CONSTANT DMA_RX_LSB :   UNSIGNED( 7 downto 0 ) := X"02";
        CONSTANT NEW_INST   :   UNSIGNED( 7 downto 0 ) := X"03";
        CONSTANT DMA_TX_MSB :   UNSIGNED( 7 downto 0 ) := X"04";
        CONSTANT DMA_TX_LSB :   UNSIGNED( 7 downto 0 ) := X"05";
    CONSTANT eDMA       :   UNSIGNED( 7 downto 0 ) := X"05";
    
    CONSTANT sRESERVED1 :   UNSIGNED( 7 downto 0 ) := X"06";
    CONSTANT eRESERVED1 :   UNSIGNED( 7 downto 0 ) := X"0F";
    
    CONSTANT sSWITCH    :   UNSIGNED( 7 downto 0 ) := X"10";
        CONSTANT SWITCH_0   :   UNSIGNED( 7 downto 0 ) := X"10";
        CONSTANT SWITCH_1   :   UNSIGNED( 7 downto 0 ) := X"11";
        CONSTANT SWITCH_2   :   UNSIGNED( 7 downto 0 ) := X"12";
        CONSTANT SWITCH_3   :   UNSIGNED( 7 downto 0 ) := X"13";
        CONSTANT SWITCH_4   :   UNSIGNED( 7 downto 0 ) := X"14";
        CONSTANT SWITCH_5   :   UNSIGNED( 7 downto 0 ) := X"15";
        CONSTANT SWITCH_6   :   UNSIGNED( 7 downto 0 ) := X"16";
        CONSTANT SWITCH_7   :   UNSIGNED( 7 downto 0 ) := X"17";
    CONSTANT eSWITCH    :   UNSIGNED( 7 downto 0 ) := X"17";    

    CONSTANT sRESERVED2 :   UNSIGNED( 7 downto 0 ) := X"18";
    CONSTANT eRESERVED2 :   UNSIGNED( 7 downto 0 ) := X"1F";
    
    CONSTANT sLEVER    :   UNSIGNED( 7 downto 0 ) := X"20";
        CONSTANT LEVER_0   :   UNSIGNED( 7 downto 0 ) := X"20";
        CONSTANT LEVER_1   :   UNSIGNED( 7 downto 0 ) := X"21";
        CONSTANT LEVER_2   :   UNSIGNED( 7 downto 0 ) := X"22";
        CONSTANT LEVER_3   :   UNSIGNED( 7 downto 0 ) := X"23";
        CONSTANT LEVER_4   :   UNSIGNED( 7 downto 0 ) := X"24";
        CONSTANT LEVER_5   :   UNSIGNED( 7 downto 0 ) := X"25";
        CONSTANT LEVER_6   :   UNSIGNED( 7 downto 0 ) := X"26";
        CONSTANT LEVER_7   :   UNSIGNED( 7 downto 0 ) := X"27";
        CONSTANT LEVER_8   :   UNSIGNED( 7 downto 0 ) := X"28";
        CONSTANT LEVER_9   :   UNSIGNED( 7 downto 0 ) := X"29";
    CONSTANT eLEVER    :   UNSIGNED( 7 downto 0 ) := X"29";
 
    CONSTANT sRESERVED3 :   UNSIGNED( 7 downto 0 ) := X"2A";
    CONSTANT eRESERVED3 :   UNSIGNED( 7 downto 0 ) := X"30";
    
    CONSTANT T_STAT     :   UNSIGNED( 7 downto 0 ) := X"31";
    
    CONSTANT sRESERVED4 :   UNSIGNED( 7 downto 0 ) := X"32";
    CONSTANT eRESERVED4 :   UNSIGNED( 7 downto 0 ) := X"3F";
    
    CONSTANT sGP_RAM :   UNSIGNED( 7 downto 0 ) := X"40";
    CONSTANT eGP_RAM :   UNSIGNED( 7 downto 0 ) := X"FF";
    
-------------------------------------------------------------------------------
-- Constants to define Type 1 instructions (ALU)
-------------------------------------------------------------------------------

  constant TYPE_1        : std_logic_vector(1 downto 0) := "00";
  constant ALU_ADD       : std_logic_vector(5 downto 0) := "000000";
  constant ALU_SUB       : std_logic_vector(5 downto 0) := "000001";
  constant ALU_SHIFTL    : std_logic_vector(5 downto 0) := "000010";
  constant ALU_SHIFTR    : std_logic_vector(5 downto 0) := "000011";
  constant ALU_AND       : std_logic_vector(5 downto 0) := "000100";
  constant ALU_OR        : std_logic_vector(5 downto 0) := "000101";
  constant ALU_XOR       : std_logic_vector(5 downto 0) := "000110";
  constant ALU_CMPE      : std_logic_vector(5 downto 0) := "000111";
  constant ALU_CMPG      : std_logic_vector(5 downto 0) := "001000";
  constant ALU_CMPL      : std_logic_vector(5 downto 0) := "001001";
  constant ALU_ASCII2BIN : std_logic_vector(5 downto 0) := "001010";
  constant ALU_BIN2ASCII : std_logic_vector(5 downto 0) := "001011";
  
  

    CONSTANT PULSE_W        : INTEGER := 174;
    CONSTANT HALFCOUNT      : INTEGER := PULSE_W/2;
    CONSTANT WORD_LENGTH    : INTEGER := 8;
    
    
    type TX_STATE_T is (IDLE, START_BIT, SEND_DATA, STOP_BIT);
    type RX_STATE_T is (IDLE, START_BIT, RVCDATA, STOP_BIT);
    
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
