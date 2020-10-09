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
package LCSE_P1 is
    CONSTANT PULSE_W : INTEGER := 174;
    constant HALFCOUNT      : integer := PULSE_W/2;
    CONSTANT WORD_LENGTH :  integer := 8;
    type TX_STATE_T is (IDLE, START_BIT, SEND_DATA, STOP_BIT);
    type RX_STATE_T is (IDLE, START_BIT, RVCDATA, STOP_BIT);
    function log2c (n: integer) return integer;
end LCSE_P1;

-- package body
package body LCSE_P1 is
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
end LCSE_P1;
