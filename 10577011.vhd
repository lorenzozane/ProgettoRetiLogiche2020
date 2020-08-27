----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.08.2020 16:53:56
-- Design Name: 
-- Module Name: 10577011 - Behavioral
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
use ieee.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_start : in std_logic;
        i_rst : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_en : out std_logic;
        o_we : out std_logic;
        o_data : out std_logic_vector (7 downto 0)
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
component datapath is
    Port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_data : out std_logic_vector (7 downto 0);
        r1_load : in std_logic;
        r2_load : in std_logic;
        rDone : in std_logic;
        rCounter_load : in std_logic;
        rCounter_sel : in std_logic;
        o_end : out std_logic);
end component;

-- State machine signal
signal r1_load : std_logic;
signal r2_load : std_logic;
signal rDone : std_logic;
signal rCounter_load : std_logic;
signal rCounter_sel : std_logic;
signal o_end : std_logic;
signal temp : std_logic_vector (15 downto 0);

-- Datapath signal
signal o_reg1 : std_logic_vector (7 downto 0);
signal o_reg2 : std_logic_vector (7 downto 0);
signal mux_regCounter : std_logic_vector (15 downto 0);
signal add_regCounter : std_logic_vector (15 downto 0);
signal o_regCounter : std_logic_vector (15 downto 0);
signal sub : std_logic_vector (7 downto 0);

type S is (S0, S1, S2, S3, S4);
signal cur_state, next_state : S;

begin

--Datapath process
--    process(i_rst, i_start)
--    begin
--        if(i_rst = '1') then
--            o_we <= '1';
--            o_data <= "UUUUUUUU";
--        elsif (i_start = '1') then
--            o_we <= '0';
--        end if;
--    end process;

    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg1 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r1_load = '1') then
                o_reg1 <= i_data;
            end if;
        end if;
    end process;
    
    process(i_clk, i_rst, i_start)
    begin
        if(i_rst = '1' or i_start = '0') then --agg i_start = '0'
            o_reg2 <= "11000000";
        elsif i_clk'event and i_clk = '1' then
            if(r2_load = '1' and cur_state /= S0) then --agg cur_state per risolvere test 9)
                o_reg2 <= i_data;
            end if;
        end if;
    end process;
    
    sub <= o_reg1 - o_reg2 when cur_state /= S0 and cur_state /= S1
    else "11111111";
    
    o_end <= '1' when cur_state = S2 and ((o_regCounter /= "0000000000001000"
                                            and ((sub = "00000000") or
                                            (sub = "00000001") or
                                            (sub = "00000010") or
                                            (sub = "00000011")))
                        or (o_regCounter = "000000000000111" and
                            (sub > "00000011" or
                            sub < "00000000"))) 
                else '0';

    with rCounter_sel select
        mux_regCounter <= "0000000000000000" when '0',
                        add_regCounter when '1',
                        "XXXXXXXXXXXXXXXX" when others;

    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_regCounter <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if o_end = '0' and cur_state = S2 then
                add_regCounter <= o_regCounter + "0000000000000001";
                if(rCounter_load = '1') then
                    o_regCounter <= mux_regCounter;
                end if;
            elsif cur_state = S4 then
                o_regCounter <= "0000000000000000";
            end if;
        end if;
    end process;

--State machine process
    process(i_clk, i_rst, i_start) --aggiunta i start
    begin
        if(i_rst = '1' or i_start = '0') then
            cur_state <= S0;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;
    
    process(cur_state, i_start, o_end, i_rst, rDone) --agg rst, rDone, next_state
    begin
        next_state <= cur_state;
        case cur_state is
            when S0 =>
                if (i_start = '1' and i_rst = '0' and rDone /= '1' and cur_state = S0) then
                    next_state <= S1;
                elsif(i_start = '1' and i_rst = '1' and rDone /= '1' and cur_state = S0) then
                    next_state <= S0;
            end if;
            when S1 =>
                next_state <= S2;
            when S2 =>
                if o_end = '0' then
                    next_state <= S2;
                else
                    next_state <= S3;
                end if;
            when S3 =>
                next_state <= S4;
            when S4 =>
                next_state <= S0;
        end case;
    end process;
    
    process(cur_state, i_clk)
    begin
    if i_clk'event and i_clk = '1' then
        r1_load <= '0';
        r2_load <= '0';
        rCounter_load <= '0';
        rCounter_sel <= '0';
        o_address <= "0000000000001000";
        temp <= "0000000000001000";
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';
        rDone <= '0';
        case cur_state is
            when S0 =>
                o_address <= "0000000000001000";
                temp <= "0000000000001000";
                o_en <= '1';
                r1_load <= '1';
                if (i_start = '1' and i_rst = '0' and next_state = S1) then
                    o_address <= "0000000000000000";
                    temp <= "0000000000000000";
                end if;
                if (next_state = S1 and rDone /= '1' and r1_load /= '0' and temp /= "0000000000001000") then
                    r1_load <= '0';
                end if;
            when S1 =>
                o_address <= "0000000000000000";
                temp <= "0000000000000000";
                o_en <= '1';
                o_we <= '0';
                r1_load <= '0';
                r2_load <= '1';
            when S2 =>
                o_address <= std_logic_vector(unsigned(o_regCounter) + 1);
                temp <= std_logic_vector(unsigned(o_regCounter) + 1);
                o_en <= '1';
                o_we <= '0';
                r1_load <= '0';
                if(o_end = '0' ) then
                    r2_load <= '1';
                else
                    r2_load <= '0';
                    o_address <= "0000000000001001";
                    temp <= "0000000000001001";
                    o_we <= '1';
                end if;
                rCounter_load <= '1';
                rCounter_Sel <= '1';
            when S3 =>
                o_address <= "0000000000001001";
                temp <= "0000000000001001";
                o_en <= '1';
                o_we <= '1';
                r1_load <= '0';
                r2_load <= '0';
                if((o_regCounter /= "0000000000001000"
                            and (sub = "00000000"))) then
                    o_data <= ('1' & o_regCounter(2 downto 0) & "0001");
                
                elsif ((o_regCounter /= "0000000000001000"
                            and (sub = "00000001"))) then
                    o_data <= ('1' & o_regCounter(2 downto 0) & "0010");
                
                elsif (o_regCounter /= "0000000000001000"
                            and (sub = "00000010")) then
                    o_data <= ('1' & o_regCounter(2 downto 0) & "0100");
                     
                elsif (o_regCounter /= "0000000000001000"
                            and (sub = "00000011")) then            
                    o_data <= ('1' & o_regCounter(2 downto 0) & "1000");
    
                else
                    o_data <= (o_reg1);
                end if;  
            when S4 =>
                rDone <= '1';
                o_done <= '1';
                o_en <= '0';
                o_we <= '0';
                rCounter_sel <= '0';
        end case;
        end if;
    end process;
end Behavioral;
