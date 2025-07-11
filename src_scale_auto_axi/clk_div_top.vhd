----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/01/2024 04:13:11 PM
-- Design Name: 
-- Module Name: clk_div_top - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clk_div_top is
    generic (
       THRESHOLD : integer := 16
    );
    Port ( 
           rst_n : in STD_LOGIC;
           pps_clk : in STD_LOGIC;
           sys_clk : in STD_LOGIC;
           out_ready : out STD_LOGIC;
           out_clk : out STD_LOGIC;
           clk_lost : out STD_LOGIC;
           SCALE : in UNSIGNED (31 downto 0);
           -- Debug ports
           rst_n_monitor : out STD_LOGIC;
           pps_clk_monitor : out STD_LOGIC;
           sys_cnt0_bit : out STD_LOGIC;
           sys_cnt1_bit : out STD_LOGIC;
           sys_cnt2_bit : out STD_LOGIC;
           sys_cnt3_bit : out STD_LOGIC;
           set_cnt_0 : out std_logic;
           set_cnt_1 : out std_logic);
end clk_div_top;

architecture Behavioral of clk_div_top is
    -- signals needed to count sys_clk
    signal M : UNSIGNED (31 downto 0);
    signal m_cnt : UNSIGNED (31 downto 0) := TO_UNSIGNED(0, 32);
    signal sys_cnt0 : UNSIGNED (31 downto 0) := TO_UNSIGNED(0, 32);
    signal sys_cnt1 : UNSIGNED (31 downto 0) := TO_UNSIGNED(0, 32);
    signal sys_cnt2 : UNSIGNED (31 downto 0) := TO_UNSIGNED(0, 32);
    signal sys_cnt3 : UNSIGNED (31 downto 0) := TO_UNSIGNED(0, 32);
    signal r_sys_cnt0 : UNSIGNED (31 downto 0) := TO_UNSIGNED(0, 32);
    signal r_sys_cnt1 : UNSIGNED (31 downto 0) := TO_UNSIGNED(0, 32);
    signal r_sys_cnt2 : UNSIGNED (31 downto 0) := TO_UNSIGNED(0, 32);
    signal r_sys_cnt3 : UNSIGNED (31 downto 0) := TO_UNSIGNED(0, 32);
    signal sys_cnt_vct : STD_LOGIC_VECTOR (31 downto 0);
    signal set_cnt : UNSIGNED (1 downto 0) := TO_UNSIGNED(0, 2);
    signal r_pps : STD_LOGIC;
    signal r_rst_n : STD_LOGIC;
    
    -- signal that compares divisor and prev_divisor so we can use threshold
    signal newLarger : boolean;
    signal comparator : UNSIGNED (31 downto 0);
    
    -- signal that indicates clk_ratio is ready
    signal prep_ready : STD_LOGIC;
    signal r_out_ready : STD_LOGIC;
    signal r_out_clk : STD_LOGIC;
      
    -- signals used to scale the sys_clk
    signal divisor_by_2 : STD_LOGIC_VECTOR (31 downto 0);
    signal divisor : STD_LOGIC_VECTOR (31 downto 0);
    signal prev_divisor : STD_LOGIC_VECTOR (31 downto 0);
    signal div_cnt : UNSIGNED (31 downto 0) := TO_UNSIGNED(0, 32);
    
    -- Signals for edge_detector instance
    signal edge_pulse : STD_LOGIC;
    
    -- Component declaration for the lower-level entity (edge_detector)
    component edge_detector is
        generic (use_neg_edge_of_clock: boolean := false;
                 detect_falling_edge: boolean := false);
        port ( clk : in STD_LOGIC;
               reset_n : in STD_LOGIC;
               edge_in : in STD_LOGIC;
               edge_pulse : out STD_LOGIC);
    end component;
begin

    -- Instantiate the edge_detector entity
    U_edge_detector: edge_detector
        generic map (
            use_neg_edge_of_clock => false,
            detect_falling_edge => false
        )
        port map (
            clk => sys_clk,
            reset_n => rst_n,
            edge_in => pps_clk,
            edge_pulse => edge_pulse
        );
        
    sys_cnt_vct <= std_logic_vector(r_sys_cnt0 + r_sys_cnt1 + r_sys_cnt2 + r_sys_cnt3);
    divisor_by_2 <= '0' & divisor(31 downto 1); -- divide by 2
    out_clk <= r_out_clk AND r_out_ready;
    out_ready <= r_out_ready;
    newLarger <= divisor>prev_divisor;
    comparator <= (unsigned(divisor) - unsigned(prev_divisor)) when newLarger
        else (unsigned(prev_divisor) - unsigned(divisor));
    
    rst_n_monitor <= rst_n;
    pps_clk_monitor <= pps_clk;
    
    sys_cnt0_bit <= sys_cnt0(0);
    sys_cnt1_bit <= sys_cnt1(0);
    sys_cnt2_bit <= sys_cnt2(0);
    sys_cnt3_bit <= sys_cnt3(0);
    
    set_cnt_0 <= set_cnt(0);
    set_cnt_1 <= set_cnt(1);
    
    M <= SCALE-1;
    
    process (sys_clk, pps_clk, rst_n)
    begin
        if (sys_clk'event and sys_clk = '1') then
          r_pps <= pps_clk;
          r_rst_n <= rst_n;
          
          if (r_rst_n = '1' AND rst_n = '0') then
            sys_cnt0 <= TO_UNSIGNED(0, 32);
            sys_cnt1 <= TO_UNSIGNED(0, 32);
            sys_cnt2 <= TO_UNSIGNED(0, 32);
            sys_cnt3 <= TO_UNSIGNED(0, 32);
            r_sys_cnt0 <= TO_UNSIGNED(0, 32);
            r_sys_cnt1 <= TO_UNSIGNED(0, 32);
            r_sys_cnt2 <= TO_UNSIGNED(0, 32);
            r_sys_cnt3 <= TO_UNSIGNED(0, 32);
            set_cnt <= TO_UNSIGNED(0, 2);
            divisor <= std_logic_vector(TO_UNSIGNED(0,32));
            prep_ready <= '0';
            r_out_ready <= '0';
            div_cnt <= TO_UNSIGNED(0, 32);
            clk_lost <= '0';
            m_cnt <= TO_UNSIGNED(0, 32);
          else 
              if (m_cnt < M) then
                m_cnt <= m_cnt+1;
              else
                m_cnt <= TO_UNSIGNED(0, 32);
              end if;
                       
              -- case statement for counting and getting stable divisor
              case (set_cnt) is
                when "00" =>
                  if (m_cnt = M) then
                    sys_cnt0 <= sys_cnt0 + 1;
                  end if;
                  if (sys_cnt0 > (sys_cnt3(30 downto 0) & '0')) AND (r_out_ready = '1') then
                      clk_lost <= '1';
                  end if;
                when "01" =>
                  if (m_cnt = M) then
                    sys_cnt1 <= sys_cnt1 + 1;
                  end if;
                  if (sys_cnt1 > (sys_cnt0(30 downto 0) & '0')) AND (r_out_ready = '1')then
                      clk_lost <= '1';
                  end if;
                when "10" =>
                  if (m_cnt = M) then
                    sys_cnt2 <= sys_cnt2 + 1;
                  end if;
                  if (sys_cnt2 > (sys_cnt1(30 downto 0) & '0')) AND (r_out_ready = '1')then
                      clk_lost <= '1';
                  end if;
                when others =>
                  if (m_cnt = M) then
                    sys_cnt3 <= sys_cnt3 + 1;
                  end if;
                  if (sys_cnt3 > (sys_cnt2(30 downto 0) & '0')) AND (r_out_ready = '1')then
                      clk_lost <= '1';
                  end if;
              end case;
              
              -- output out_clk when divisor is stable
              if (div_cnt >= (unsigned(divisor)-1)) OR (prep_ready = '1') then
                  div_cnt <= TO_UNSIGNED(0, 32);
                  if (prep_ready = '1') then
                      prep_ready <= '0';
                      r_out_ready <= '1';
                  end if;
              else
                  div_cnt <= div_cnt + 1;
              end if;
              
              if (div_cnt < unsigned(divisor_by_2)) then
                r_out_clk <= '1';
              else
                r_out_clk <= '0';
              end if;
        
              if (edge_pulse = '1') then--r_pps = '0' and pps_clk = '1') then
                -- increment set_cnt for pps_clk
                if (set_cnt = "11") then
                    set_cnt <= "00";
                else
                    set_cnt <= set_cnt + 1;
                end if;
                
                -- update registered counter
                -- and zero out unregister counter
                case (set_cnt) is
                  when "00" =>
                    r_sys_cnt3 <= sys_cnt3;
                    sys_cnt1 <= TO_UNSIGNED(0, 32);
                  when "01" =>
                    r_sys_cnt0 <= sys_cnt0;
                    sys_cnt2 <= TO_UNSIGNED(0, 32);
                  when "10" =>
                    r_sys_cnt1 <= sys_cnt1;
                    sys_cnt3 <= TO_UNSIGNED(0, 32);
                  when others =>
                    r_sys_cnt2 <= sys_cnt2;
                    sys_cnt0 <= TO_UNSIGNED(0, 32);
                end case;
                
                -- update divisor based on registered counter
                divisor <= "00" & sys_cnt_vct(31 downto 2);
                -- store previous divisor
                prev_divisor <= divisor;
              
                -- determine if we can start to output clock
                if (comparator < THRESHOLD) AND (r_sys_cnt0/=0 AND r_sys_cnt1/=0 AND r_sys_cnt2/=0 AND r_sys_cnt3/=0) AND (r_out_ready = '0') then
                      prep_ready <= '1';
                end if;
              end if;
        
            end if;
        end if;
    end process;
    

end Behavioral;
