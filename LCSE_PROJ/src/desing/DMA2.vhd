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
        Event_RQ    : in  STD_LOGIC_VECTOR (2 downto 0);     -- Trigger source vector
        DMA_IRQ     : out STD_LOGIC_VECTOR (2 downto 0);
        
        -- Slave buses
        Addess_s    : in  STD_LOGIC_VECTOR (7 downto 0);    -- Slave Address bus
        InBus_s     : in  STD_LOGIC_VECTOR (7 downto 0);    -- Slave input bus
        OutBus_s    : out STD_LOGIC_VECTOR (7 downto 0);    -- slave outpur bus
        WE_s        : in  STD_LOGIC;                        -- slave write enablr
        RE_s        : in  STD_LOGIC);                       -- slave read enable 
end DMA2;
   


architecture Behavioral of DMA2 is
    
    type dev_mem_8 is array (0 to 15) of std_logic_vector(7 downto 0);
    type DMA_STATE_T is (IDLE, FETCH, WAIT_FETCH, WRITE, WAIT_WRITE);
    
  
    
    constant MEM2MEM : std_logic_vector(1 downto 0) := "00";
    constant MEM2PER : std_logic_vector(1 downto 0) := "01";
    constant PER2MEM : std_logic_vector(1 downto 0) := "10";
    

    CONSTANT irq_en_bit : integer := 4;
    
    constant DMA_CONF_CH1_OFF      : UNSIGNED( 3 downto 0 ) := X"0";
    constant DMA_SRC_CH1_OFF       : UNSIGNED( 3 downto 0 ) := X"1";
    constant DMA_DEST_CH1_OFF      : UNSIGNED( 3 downto 0 ) := X"2";
    constant DMA_CNT_CH1_OFF       : UNSIGNED( 3 downto 0 ) := X"3";
    
    constant DMA_CONF_CH2_OFF      : UNSIGNED( 3 downto 0 ) := X"4";
    constant DMA_SRC_CH2_OFF       : UNSIGNED( 3 downto 0 ) := X"5";
    constant DMA_DEST_CH2_OFF      : UNSIGNED( 3 downto 0 ) := X"6";
    constant DMA_CNT_CH2_OFF       : UNSIGNED( 3 downto 0 ) := X"7";
        
    constant DMA_CONF_CH3_OFF      : UNSIGNED( 3 downto 0 ) := X"8";
    constant DMA_SRC_CH3_OFF       : UNSIGNED( 3 downto 0 ) := X"9";
    constant DMA_DEST_CH3_OFF      : UNSIGNED( 3 downto 0 ) := X"A";
    constant DMA_CNT_CH3_OFF       : UNSIGNED( 3 downto 0 ) := X"B";
    
    
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

    -- Internal memory register
    signal dev_mem, dev_mem_n               : dev_mem_8                     :=(others => (others => '0'));
    -- FSM state
    signal dma_state_reg, dma_state_reg_n   : DMA_STATE_T;
    -- Outpur registers
    signal OutBus_s_reg, OutBus_s_reg_n     : STD_LOGIC_VECTOR (7 downto 0);    -- Slave outpur bus
    signal OutBus_m_reg, OutBus_m_reg_n     : STD_LOGIC_VECTOR (7 downto 0);    -- Master output bus
    signal Address_m_reg, Address_m_reg_n   : STD_LOGIC_VECTOR (7 downto 0);    -- Master Address outpur
    signal WE_m_reg, WE_m_reg_n             : STD_LOGIC;                        -- Master write enable
    signal RE_m_reg, RE_m_reg_n             : STD_LOGIC;                        -- Master read enable 
    signal inBus_m_reg, inBus_m_reg_n       : STD_LOGIC_VECTOR (7 downto 0);    -- Inbus reg
    signal dma_irq_reg, dma_irq_reg_n       : STD_LOGIC_VECTOR (2 downto 0);    -- IRQ 
    -- Auxiliar registers    
    signal ch_conf_reg, ch_conf_reg_n       : UNSIGNED( 3 downto 0 )        := X"0";
    signal ch_src_reg, ch_src_reg_n         : UNSIGNED( 3 downto 0 )        := X"0";
    signal ch_dest_reg, ch_dest_reg_n       : UNSIGNED( 3 downto 0 )        := X"0";
    signal ch_couter_reg, ch_couter_reg_n   : UNSIGNED( 3 downto 0 )        := X"0";
    signal index_irq_reg, index_irq_reg_n   : UNSIGNED( 1 downto 0 );
    signal src1, src1_n                     : STD_LOGIC_VECTOR(7 downto 0);
    signal src2, src2_n                     : STD_LOGIC_VECTOR(3 downto 0);
    

begin

    FF: process (clk, reset) is 
    begin
        if( Reset = '1' ) then
            -- Reset registers
            dma_state_reg <= IDLE; 
            
            dev_mem       <= (others => (others => '0'));
            
            OutBus_m_reg  <= (others => '0');
            WE_m_reg      <= '0';
            RE_m_reg      <= '0';
            inBus_m_reg   <= (others => '0');
            
            ch_conf_reg   <= (others => '0');
            ch_src_reg    <= (others => '0');
            ch_dest_reg   <= (others => '0');
            ch_couter_reg <= (others => '0');   
            src1          <= (others => '0');
            src2          <= (others => '0');
            index_irq_reg <= (others => '0');
            dma_irq_reg   <= (others => '0');
            
        elsif (Clk'event and Clk = '1' ) then
            -- Update registers
            dma_state_reg <= dma_state_reg_n;
            
            dev_mem       <= dev_mem_n;
            
            OutBus_m_reg  <= OutBus_m_reg_n;
            WE_m_reg      <= WE_m_reg_n;
            RE_m_reg      <= RE_m_reg_n;
            inBus_m_reg   <= inBus_m_reg_n;
            
            ch_conf_reg   <= ch_conf_reg_n;
            ch_src_reg    <= ch_src_reg_n;
            ch_dest_reg   <= ch_dest_reg_n;
            ch_couter_reg <= ch_couter_reg_n;
            src1          <= src1_n;
            src2          <= src2_n;
            index_irq_reg <= index_irq_reg_n;
            dma_irq_reg   <= dma_irq_reg_n;
            
        end if;
    
    end process;
    
    NSL: process( dma_state_reg, Event_RQ, dev_mem, Access_m) is 
    begin
    
        dma_state_reg_n <= dma_state_reg;
        
        case dma_state_reg is
            when IDLE => -- Check for enable channel with active events
                if( Event_RQ(2) = '1' and dev_mem(TO_INTEGER(DMA_CONF_CH1_OFF))(7) = '1') then
                    dma_state_reg_n <= FETCH;
                elsif( Event_RQ(1) = '1' and dev_mem(TO_INTEGER(DMA_CONF_CH2_OFF))(7) = '1') then
                    dma_state_reg_n <= FETCH;
                elsif( Event_RQ(0) = '1' and dev_mem(TO_INTEGER(DMA_CONF_CH3_OFF))(7) = '1') then
                    dma_state_reg_n <= FETCH;
                end if;
                  
            when FETCH =>  -- Fetch data from source
                dma_state_reg_n <= WAIT_FETCH;
                    
            when WAIT_FETCH => --Wait for read (shared bus)
                if ( access_m = '1') then
                    dma_state_reg_n <= WRITE;
                end if;
            when WRITE => --Write data to drestination 
                    dma_state_reg_n <= WAIT_WRITE;
            when WAIT_WRITE => -- Wait for write
                if ( access_m = '1') then
                    dma_state_reg_n <= IDLE;
                end if;    
        end case;
    end process;
    
    LOGIC: process( dma_state_reg, Event_RQ,InBus_m,dev_mem, Access_m, Addess_s, 
                    InBus_s, WE_s, RE_s,ch_conf_reg, ch_src_reg,ch_dest_reg, ch_couter_reg, 
                    src1, src2, inBus_m_reg, outBus_m_reg, index_irq_reg) is
    begin
        -- Default default values to avoid latches
        dev_mem_n       <= dev_mem;
        inBus_m_reg_n   <= inBus_m_reg;
        OutBus_m_reg_n  <= (others => 'Z');
        OutBus_s_reg    <= (others => 'Z');
        ch_conf_reg_n   <= ch_conf_reg;
        ch_src_reg_n    <= ch_src_reg;
        ch_dest_reg_n   <= ch_dest_reg;
        ch_couter_reg_n <= ch_couter_reg;
        Address_m_reg_n <= (others => '0');   
        OutBus_m_reg_n  <= (others => '0');                   
        WE_m_reg_n      <= '0';
        RE_m_reg_n      <= '0';
        dma_irq_reg_n   <= (others => '0');
        index_irq_reg_n <=index_irq_reg;
        src1_n          <= (others => '0');
        src2_n          <= (others => '0');
        
        case dma_state_reg is
            when IDLE =>
                ch_conf_reg_n   <= (others => '0');
                ch_src_reg_n    <= (others => '0');
                ch_dest_reg_n   <= (others => '0');
                ch_couter_reg_n <= (others => '0');
                index_irq_reg_n <= (others => '0');
                -- Select the active channel with higher priority
                if( Event_RQ(2) = '1' and dev_mem(TO_INTEGER(DMA_CONF_CH1_OFF))(7) = '1') then
                    ch_conf_reg_n   <= DMA_CONF_CH1_OFF;
                    ch_src_reg_n    <= DMA_SRC_CH1_OFF;
                    ch_dest_reg_n   <= DMA_DEST_CH1_OFF;
                    ch_couter_reg_n <= DMA_CNT_CH1_OFF;
                    index_irq_reg_n <= "00";
                elsif( Event_RQ(1) = '1' and dev_mem(TO_INTEGER(DMA_CONF_CH2_OFF))(7) = '1') then
                    ch_conf_reg_n   <= DMA_CONF_CH2_OFF;
                    ch_src_reg_n    <= DMA_SRC_CH2_OFF;
                    ch_dest_reg_n   <= DMA_DEST_CH2_OFF;
                    ch_couter_reg_n <= DMA_CNT_CH2_OFF;
                    index_irq_reg_n <= "01";
                elsif( Event_RQ(0) = '1' and dev_mem(TO_INTEGER(DMA_CONF_CH3_OFF))(7) = '1') then
                    ch_conf_reg_n   <= DMA_CONF_CH3_OFF;
                    ch_src_reg_n    <= DMA_SRC_CH3_OFF;
                    ch_dest_reg_n   <= DMA_DEST_CH3_OFF;
                    ch_couter_reg_n <= DMA_CNT_CH3_OFF;
                    index_irq_reg_n <= "10";
                end if;
                
                  
            when FETCH =>
                -- Calculate fetch address according with the operation mode
                case dev_mem( TO_INTEGER(ch_conf_reg))(6 downto 5) is         
                    when MEM2MEM =>  -- Source address is incremented using the counter
                        src1_n <= dev_mem( TO_INTEGER(ch_src_reg));
                        src2_n <= dev_mem( TO_INTEGER(ch_couter_reg))(7 downto 4);
                        RE_m_reg_n <= '1';
                    when MEM2PER =>  -- Source address is incremented
                        src1_n <= dev_mem( TO_INTEGER(ch_src_reg));
                        src2_n <= dev_mem( TO_INTEGER(ch_couter_reg))(7 downto 4);
                        RE_m_reg_n <= '1';
                    when PER2MEM => -- Source address no change                   
                        src1_n <= dev_mem( TO_INTEGER(ch_src_reg));
                        src2_n <= (others => '0');
                        RE_m_reg_n <= '1';
                    when others => 
                        src1_n <= (others => '0');
                        src2_n <= (others => '0');
                        RE_m_reg_n <= '0';
                end case;
                 
            when WAIT_FETCH =>
                 src1_n <= src1;
                 src2_n <= src2;
                 RE_m_reg_n <= '1';
                 
                if( access_m = '1' ) then
                    inBus_m_reg_n <= inBus_m;
                    RE_m_reg_n <= '0';
                end if;
               
            when WRITE =>
                -- Calculate write address according with the operation mode
                case dev_mem( TO_INTEGER(ch_conf_reg))(6 downto 5) is         
                    when MEM2MEM =>  -- Write address is incremented using the counter
                        src1_n <= dev_mem( TO_INTEGER(ch_dest_reg)); 
                        src2_n <= dev_mem( TO_INTEGER(ch_couter_reg))(7 downto 4);
                        WE_m_reg_n <= '1';
                    when MEM2PER => -- Write address no change
                        src1_n <= dev_mem( TO_INTEGER(ch_dest_reg));
                        src2_n <= (others => '0');
                        WE_m_reg_n <= '1';
                    when PER2MEM =>  -- Write address is incremented using the counter                   
                        src1_n <= dev_mem( TO_INTEGER(ch_dest_reg));
                        src2_n <= dev_mem( TO_INTEGER(ch_couter_reg))(7 downto 4);
                        WE_m_reg_n <= '1';
                        WE_m_reg_n <= '1';
                    when others =>
                        src1_n <= (others => '0');
                        src2_n <= (others => '0');
                        WE_m_reg_n <= '0';
                end case;       
                -- Store the data present in the input bus as result of the fetch transaction.
                -- This data will be written in the output bus when access is garanted  
                OutBus_m_reg_n <= inBus_m_reg;     
            when WAIT_WRITE =>
                 src1_n <= src1;
                 src2_n <= src2;
                 WE_m_reg_n <= '1';
                OutBus_m_reg_n <= OutBus_m_reg;
                
                if( access_m = '1' ) then
                    WE_m_reg_n <= '0';
                    
                    dev_mem_n( TO_INTEGER(ch_couter_reg))(7 downto 4) <= dev_mem( TO_INTEGER(ch_couter_reg))(7 downto 4) + 1;
                    if ( dev_mem( TO_INTEGER(ch_couter_reg))(7 downto 4) = dev_mem( TO_INTEGER(ch_couter_reg))(3 downto 0)) then
                        dev_mem_n( TO_INTEGER(ch_couter_reg))(7 downto 4) <= (others => '0');
                        dev_mem_n(TO_INTEGER(ch_conf_reg))(7) <= '0';
                        
                        if( dev_mem( TO_INTEGER(ch_conf_reg))(irq_en_bit) = '1' ) then
                            dma_irq_reg_n( TO_INTEGER(index_irq_reg) ) <= '1';
                        end if;                    
                    end if;
                end if;         
        end case;
        
        -- Calculate address using only one adder 
        Address_m_reg <= src1 + src2;
        
        -- Internal register configuration.
        -- Check the address base        
        if ( unsigned(Addess_s(7 downto 4)) = DMA_MEM_BASE(7 downto 4) )  then
            if( WE_s = '1' ) then
                -- Write into memory
                dev_mem_n( conv_integer(Addess_s(3 downto 0)) ) <= InBus_s;
            elsif ( RE_s = '1' ) then
                -- Write to the bus
                OutBus_s_reg <= dev_mem( conv_integer(Addess_s(3 downto 0) ));
            end if;
        end if;
    
    end process;
    
    OutBus_s <= OutBus_s_reg;
    OutBus_m <= OutBus_m_reg;
    Address_m <= Address_m_reg;
    WE_m <= WE_m_reg;
    RE_m <= RE_m_reg;
    DMA_IRQ <= dma_irq_reg;

end Behavioral;