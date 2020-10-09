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

entity DMA is
    Port ( Reset : in STD_LOGIC;
           Clk : in STD_LOGIC;
           RCVD_Data : in STD_LOGIC_VECTOR (7 downto 0);
           RX_Full : in STD_LOGIC;
           RX_Empty : in STD_LOGIC;
           Data_Read : out STD_LOGIC;
           ACK_out : in STD_LOGIC;
           TX_RDY : in STD_LOGIC;
           Valid_D : out STD_LOGIC;
           TX_Data : out STD_LOGIC_VECTOR (7 downto 0);
           Address : out STD_LOGIC_VECTOR (7 downto 0);
           Databus : inout STD_LOGIC_VECTOR (7 downto 0);
           Write_en : out STD_LOGIC;
           OE : out STD_LOGIC;
           DMA_RQ : out STD_LOGIC;
           DMA_ACK : in STD_LOGIC;
           Send_comm : in STD_LOGIC;
           READY : out STD_LOGIC);
end DMA;

architecture Behavioral of DMA is

begin


end Behavioral;
