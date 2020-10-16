----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.10.2020 09:53:28
-- Design Name: 
-- Module Name: DMA2 - Behavioral
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
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.std_logic_unsigned.all;
use work.LCSE_PKG.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity DMA2 is
    Port ( 
        clk         : in STD_LOGIC;
        Reset       : in STD_LOGIC;
        -- Master buses
        Address_m   : out STD_LOGIC_VECTOR (7 downto 0);    -- Master Address bus
        InBus_m     : in  STD_LOGIC_VECTOR (7 downto 0);    -- Master Input data bus
        OutBus_m    : out STD_LOGIC_VECTOR (7 downto 0);    -- Master outpur data bus
        WE_m        : out STD_LOGIC;                        -- Master write enable
        RE_m        : out STD_LOGIC;                        -- Master read enable
        Access_m    : in  STD_LOGIC;                        -- Bus access flag
        
         -- Event trigger
        Event_RQ    : in STD_LOGIC_VECTOR (2 downto 0);     -- Trigger source vector
        
        -- Slave buses
        Addess_s    : in  STD_LOGIC_VECTOR (7 downto 0);    -- Slave Address bus
        InBus_s     : in  STD_LOGIC_VECTOR (7 downto 0);    -- Slave input bus
        OutBus_s    : out STD_LOGIC_VECTOR (7 downto 0);    -- slave outpur bus
        WE_s        : in  STD_LOGIC;                        -- slave write enablr
        RE_s        : in  STD_LOGIC);                       -- slave read enable 
end DMA2;



architecture Behavioral of DMA2 is

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
     
     
     constant DEV_MEM_BASE       : UNSIGNED( 7 downto 0 ) := DMA_MEM_BASE;
    
    type dev_mem_8 is array (0 to 15) of std_logic_vector(7 downto 0);
    type DMA_STATE_T is (IDLE, FETCH, WAIT_FETCH, WRITE, WAIT_WRITE);
    
    
    signal dma_state_reg, dma_state_reg_n : DMA_STATE_T;
    
    -- Configurarion registers
--              CHANNEL CONFIGURARION REGISTER   
--    7_____6_________________3_______________________0
--    |     |                                         |    
--    | EN  |              RESERVED                   |    
--    |_____|__________________ ______________________| 
--    |                                               |    
--    |                  SOURCE ADDRESS               |    
--    |_______________________________________________|
--    |                                               |    
--    |                  DEST ADDRESS                 |    
--    |_______________________________________________|         
--    |                       |                       |    
--    |    OP. COUNTER        |     Nº OPERATIONS     |    
--    |_______________________|_______________________| 


    signal dev_mem, dev_mem_n : dev_mem_8:=(others => (others => '0'));
    
    signal OutBus_s_reg, OutBus_s_reg_n : STD_LOGIC_VECTOR (7 downto 0);
    signal OutBus_m_reg, OutBus_m_reg_n : STD_LOGIC_VECTOR (7 downto 0);
    signal Address_m_reg, Address_m_reg_n : STD_LOGIC_VECTOR (7 downto 0);
    signal WE_m_reg, WE_m_reg_n : STD_LOGIC;
    signal RE_m_reg, RE_m_reg_n : STD_LOGIC;
    signal inBus_m_reg, inBus_m_reg_n : STD_LOGIC_VECTOR (7 downto 0);
    
    
    signal evenIndex : STD_LOGIC_VECTOR (2 downto 0);
    
    signal ch_conf_reg, ch_conf_reg_n  : UNSIGNED( 3 downto 0 ) := X"0";
    signal ch_src_reg, ch_src_reg_n   : UNSIGNED( 3 downto 0 ) := X"0";
    signal ch_dest_reg, ch_dest_reg_n  : UNSIGNED( 3 downto 0 ) := X"0";
    signal ch_couter_reg, ch_couter_reg_n  : UNSIGNED( 3 downto 0 ) := X"0";
    
    
    signal test : integer := 0;
    signal test2 : STD_LOGIC_VECTOR (7 downto 0);
    
    component pEncoder
        generic( data_width : integer := 3);
        port (	
            data_in : in  STD_LOGIC_VECTOR(data_width - 1 downto 0);
            data_out: out STD_LOGIC_VECTOR(log2c(data_width + 1) - 1 downto 0)
        );
    end component;

begin





FF: process (clk, reset) is 
begin
    if( Reset = '1' ) then
        dma_state_reg <= IDLE;
    
        OutBus_s_reg <= (others => 'Z');
        OutBus_m_reg <= (others => '0');
        Address_m_reg <= (others => '0');
        WE_m_reg <= '0';
        RE_m_reg <= '0';
        dev_mem  <=  (others => (others => '0'));
        
        
    elsif (Clk'event and Clk = '1' ) then
        dma_state_reg <= dma_state_reg_n;
        
        OutBus_s_reg <= OutBus_s_reg_n;
        OutBus_m_reg <= OutBus_m_reg_n;
        Address_m_reg <= Address_m_reg_n;
        WE_m_reg <= WE_m_reg_n;
        RE_m_reg <= RE_m_reg_n;
        dev_mem  <= dev_mem_n;
        inBus_m_reg <= inBus_m_reg_n;
        
        ch_conf_reg  <= ch_conf_reg_n;
        ch_src_reg   <= ch_src_reg_n;
        ch_dest_reg   <= ch_dest_reg_n;
        ch_couter_reg <= ch_couter_reg_n;
        
    end if;

end process;

NSL: process( dma_state_reg, Event_RQ, dev_mem, Access_m) is 
begin
    dma_state_reg_n <= dma_state_reg;
    case dma_state_reg is
        when IDLE =>
            test2 <= dev_mem(TO_INTEGER(DMA_CONF_CH1));    
            if( Event_RQ(2) = '1' and dev_mem(TO_INTEGER(DMA_CONF_CH1))(7) = '1') then
                dma_state_reg_n <= FETCH;
            elsif( Event_RQ(1) = '1' and dev_mem(TO_INTEGER(DMA_CONF_CH2))(7) = '1') then
                dma_state_reg_n <= FETCH;
            elsif( Event_RQ(0) = '1' and dev_mem(TO_INTEGER(DMA_CONF_CH3))(7) = '1') then
                dma_state_reg_n <= FETCH;
            end if;
 
              
        when FETCH =>
            dma_state_reg_n <= WAIT_FETCH;
                
        when WAIT_FETCH =>
            if ( access_m = '1') then
                dma_state_reg_n <= WRITE;
            end if;
        when WRITE =>
                dma_state_reg_n <= WAIT_WRITE;
        when WAIT_WRITE =>
            if ( access_m = '1') then
                dma_state_reg_n <= IDLE;
            end if;    
    end case;
end process;

LOGIC: process(dma_state_reg, Event_RQ,InBus_m, dev_mem, Access_m, Addess_s, InBus_s, WE_s, RE_s) is
    variable tmp : unsigned(7 downto 0 ) := (others => '0');
begin
    --dev_mem_n <= dev_mem;
    OutBus_m_reg_n <= (others => 'Z');
    OutBus_s_reg_n <= (others => 'Z');
    ch_conf_reg_n   <= ch_conf_reg;
    ch_src_reg_n    <= ch_src_reg;
    ch_dest_reg_n   <= ch_dest_reg;
    ch_couter_reg_n <= ch_couter_reg;
    Address_m_reg_n <= (others => '0');   
    OutBus_m_reg_n  <= (others => '0');                   
    WE_m_reg_n      <= '0';
    RE_m_reg_n      <= '0';
    
    case dma_state_reg is
        when IDLE =>
            ch_conf_reg_n   <= (others => '0');
            ch_src_reg_n    <= (others => '0');
            ch_dest_reg_n   <= (others => '0');
            ch_couter_reg_n <= (others => '0');
            
            if( Event_RQ(2) = '1' and dev_mem(TO_INTEGER(DMA_CONF_CH1))(7) = '1') then
                ch_conf_reg_n   <= DMA_CONF_CH1;
                ch_src_reg_n    <= DMA_SRC_CH1;
                ch_dest_reg_n   <= DMA_DEST_CH1;
                ch_couter_reg_n <= DMA_CNT_CH1;
            
            elsif( Event_RQ(1) = '1' and dev_mem(TO_INTEGER(DMA_CONF_CH2))(7) = '1') then
                ch_conf_reg_n   <= DMA_CONF_CH2;
                ch_src_reg_n    <= DMA_SRC_CH2;
                ch_dest_reg_n   <= DMA_DEST_CH2;
                ch_couter_reg_n <= DMA_CNT_CH2;
            
            elsif( Event_RQ(0) = '1' and dev_mem(TO_INTEGER(DMA_CONF_CH3))(7) = '1') then
                ch_conf_reg_n   <= DMA_CONF_CH3;
                ch_src_reg_n    <= DMA_SRC_CH3;
                ch_dest_reg_n   <= DMA_DEST_CH3;
                ch_couter_reg_n <= DMA_CNT_CH3;
            end if;
            
              
        when FETCH =>
            Address_m_reg_n <= dev_mem( TO_INTEGER(ch_src_reg)) +
                               dev_mem( TO_INTEGER(ch_couter_reg_n))(7 downto 4);
            RE_m_reg_n <= '1';
            
                  
        when WAIT_FETCH =>
             Address_m_reg_n <= Address_m_reg;
             RE_m_reg_n <= '1';
            if( access_m = '1' ) then
                inBus_m_reg_n <= inBus_m;
                RE_m_reg_n <= '0';
            end if;
           
        when WRITE =>
            Address_m_reg_n <= dev_mem( TO_INTEGER(ch_dest_reg)) +
                               dev_mem( TO_INTEGER(ch_couter_reg_n))(7 downto 4);
                               
            OutBus_m_reg_n <= inBus_m_reg;                   
            WE_m_reg_n <= '1';
            
            if ( Access_m = '1' ) then
                dev_mem_n( TO_INTEGER(ch_couter_reg_n))(7 downto 4) <= dev_mem( TO_INTEGER(ch_couter_reg_n))(7 downto 4) + 1;
                if ( dev_mem( TO_INTEGER(ch_couter_reg_n))(7 downto 4) = dev_mem( TO_INTEGER(ch_couter_reg_n))(3 downto 0)) then
                    dev_mem_n( TO_INTEGER(ch_couter_reg_n))(7 downto 4) <= (others => '0');
                    dev_mem_n(TO_INTEGER(DMA_CONF_CH1))(7) <= '0';
                end if;
            end if;
            
        when WAIT_WRITE =>
            Address_m_reg_n <= Address_m_reg;
            WE_m_reg_n <= '1';
            OutBus_m_reg_n <= OutBus_m_reg;
            
            if( access_m = '1' ) then
                WE_m_reg_n <= '0';
            end if;
            
    end case;
        
    if ( unsigned(Addess_s(7 downto 4)) = DEV_MEM_BASE(7 downto 4) )  then
        if( WE_s = '1' ) then
            dev_mem_n( conv_integer(Addess_s(3 downto 0)) ) <= InBus_s;
            
        elsif ( RE_s = '1' ) then
            OutBus_m_reg_n <= dev_mem( conv_integer(Addess_s(3 downto 0) ));
        end if;
    end if;

end process;




OutBus_s <= OutBus_s_reg;
OutBus_m <= OutBus_m_reg;
Address_m <= Address_m_reg;
WE_m <= WE_m_reg;
RE_m <= RE_m_reg;

end Behavioral;



