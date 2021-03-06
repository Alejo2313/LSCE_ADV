----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Alejandro Gomez Molina
-- Engineer: Luis Felipe Velez Flores
-- Create Date: 22.10.2020 15:52:03
-- Design Name: 
-- Module Name: display - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- Display configured with 6 registers of 8 bits. One for enable the entire device, another for activate the desired anode
-- (0 is for select), and the rest for passing the value in BCD (in each register there are two BDC words).
-- Dependencies: use LCSE_PKG in order to get the constanst needed and numeric_Std for math operations.
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.LCSE_PKG.all;

use IEEE.NUMERIC_STD.ALL;

entity display is
    Port ( Clk          : in  STD_LOGIC;
           Reset        : in  STD_LOGIC;
           Address_s    : in  STD_LOGIC_VECTOR (7 downto 0);
           InBus_s      : in  STD_LOGIC_VECTOR (7 downto 0);
           outBus_s     : out STD_LOGIC_VECTOR (7 downto 0);
           WE_s         : in  STD_LOGIC;
           RE_s         : in  STD_LOGIC;
           out_display  : out STD_LOGIC_VECTOR(7 downto 0);
           anode        : out STD_LOGIC_VECTOR(7 downto 0));
end display;

architecture Behavioral of display is
    type dev_mem_8 is array (0 to TO_INTEGER(eDISPLAY - sDISPLAY) ) of std_logic_vector(7 downto 0);
    
    -- Constants 
    
    constant IEN_offset             : integer := TO_INTEGER(DISPLAY_IEN - DISPLAY_BASE);   --Individual enable
    constant EN_offset              : integer := TO_INTEGER(DISPLAY_EN  - DISPLAY_BASE);    -- General enable
    constant DREG01_offset          : integer := TO_INTEGER(DISPLAY_01  - DISPLAY_BASE);   
    constant DREG23_offset          : integer := TO_INTEGER(DISPLAY_23  - DISPLAY_BASE);  
    constant DREG45_offset          : integer := TO_INTEGER(DISPLAY_45  - DISPLAY_BASE);   
    constant DREG67_offset          : integer := TO_INTEGER(DISPLAY_67  - DISPLAY_BASE);  
  
    --Signals
    
    signal mem_r,mem_n              : dev_mem_8;
    signal outBus_r                 : STD_LOGIC_VECTOR(7 downto 0);
    signal anode_r,anode_n          : STD_LOGIC_VECTOR(7 downto 0);
    signal cnt_r, cnt_n             : UNSIGNED(log2c(50000)-1 downto 0);    
    signal index_r, index_n         : UNSIGNED(log2c(8) -1 downto 0);  
    signal d_r, d_n                 : STD_LOGIC_VECTOR (3 downto 0);
    signal S                        : STD_LOGIC_VECTOR (7 downto 0);
    signal D                        : STD_LOGIC_VECTOR (3 downto 0);    
    signal disp_vector              : STD_LOGIC_VECTOR (31 downto 0);
    
    --Components
     
    component decod7s 
        Port ( D : in  STD_LOGIC_VECTOR (3 downto 0);					
               S : out  STD_LOGIC_VECTOR (7 downto 0));   	
    end component;
    

    
    
begin

    decoder: decod7s 
        port map ( D => d_r,
                   S => S);

 FF: process (Clk, Reset) is
 begin
    if (Reset = '1') then
        mem_r       <= (others => (others => '0'));
        index_r     <= (others => '0');
        cnt_r       <= (others => '0');
        anode_r     <= (others => '1');
        d_r         <= (others => '0');
        
        
    elsif (Clk'event and Clk = '1') then
        mem_r       <= mem_n; 
        cnt_r       <= cnt_n;
        index_r     <= index_n;
        anode_r     <= anode_n;
        d_r         <= d_n;
        
    end if;
    
 end process;
 
disp_vector <=  mem_r(DREG67_offset)&
                mem_r(DREG45_offset)&
                mem_r(DREG23_offset)&
                mem_r(DREG01_offset);


logic: process(     cnt_r, index_r, d_r, anode_r, mem_r, WE_s, 
                    RE_s,disp_vector, Address_s, InBus_s ) is
begin
    outBus_r    <= (others => 'Z');
    mem_n       <= mem_r;
    
    cnt_n       <= cnt_r;
    index_n     <= index_r;
    anode_n     <= (others => '1');
    d_n         <= d_r;
    
    if(mem_r(EN_offset)(7) = '1' ) then
        cnt_n       <= cnt_r + 1;
    end if;
    
    if(cnt_r = 50000) then
        index_n  <= index_r + 1;
        cnt_n <= (others => '0');
    end if;

    for k in 0 to 7 loop
        if ( k = index_r and mem_r(EN_offset)(7) = '1') then
            d_n <= disp_vector(4*k+3 downto 4*k);
            anode_n(k) <= not ( mem_r(IEN_offset)(TO_INTEGER(index_r) ));
        end if;
    end loop;
    
    
    if( UNSIGNED(Address_s(7 downto 3)) = DISPLAY_BASE(7 downto 3)) then
        if (WE_s = '1') then
            mem_n(TO_INTEGER(UNSIGNED(Address_s) - DISPLAY_BASE)) <= InBus_s;
        elsif (RE_s = '1') then
            outBus_r <= mem_r(TO_INTEGER(UNSIGNED(Address_s) - DISPLAY_BASE));
        end if; 
    end if;
end process;


anode       <= anode_r ;  
outBus_s    <= outBus_r;  
out_display <= S; 

end Behavioral;