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
        r3_load : in std_logic;
        o_end : out std_logic);
end component;

-- State machine signal
signal r1_load : std_logic;
signal r2_load : std_logic;
signal r3_load : std_logic;
signal o_end : std_logic;
signal temp : std_logic_vector (15 downto 0);

-- Datapath signal
signal o_reg1 : std_logic_vector (7 downto 0);
signal o_reg2 : std_logic_vector (7 downto 0);
signal o_reg3 : std_logic_vector (7 downto 0);
--signal o_reg4 : std_logic_vector (7 downto 0);
signal sub : std_logic_vector (7 downto 0);
signal d_sel : std_logic;

type S is (S0, S1, S2, S3);
signal cur_state, next_state : S;

begin

--Datapath process
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
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg2 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r2_load = '1') then
                o_reg2 <= i_data;
            end if;
            if(r3_load = '1') then
                o_reg3 <= i_data;
            end if;
        end if;
    end process;
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg3 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r3_load = '1') then
                o_reg3 <= i_data;
            end if;
        end if;
    end process;
    
    sub <= o_reg1 - o_reg2;
    
    o_end <= '1' when ((o_reg3 /= "00001000"
                        and ((sub = "00000000") or
                            (sub = "00000001") or
                            (sub = "00000010") or
                            (sub = "00000011")))
                        or (o_reg3 = "00000111" and
                            (sub >= "00000011" or
                            sub <= "00000000"))) else '0';

    d_sel <= '0' when (o_reg3 /= "00001000"
                        and ((sub = "00000000") or
                            (sub = "00000001") or
                            (sub = "00000010") or
                            (sub = "00000011")));

    d_sel <= '1' when(o_reg3 = "00000111" and
                            (sub >= "00000011" or
                            sub <= "00000000"));

    o_data <= ('1' & o_reg3(2 downto 0) & "0001") when (o_reg3 /= "00001000"
                            and (sub = "00000000"));

    o_data <= ('1' & o_reg3(2 downto 0) & "0010") when (o_reg3 /= "00001000"
                            and (sub = "00000001"));
                            
    o_data <= ('1' & o_reg3(2 downto 0) & "0100") when (o_reg3 /= "00001000"
                            and (sub = "00000010"));
                            
    o_data <= ('1' & o_reg3(2 downto 0) & "1000") when (o_reg3 /= "00001000"
                            and (sub = "00000011"));
    
    o_data <= (o_reg1) when(o_reg3 = "00000111" and
                            (sub > "00000011" or
                            sub < "00000000"));

--    with d_sel select
--        o_data <=   when '0',
--                   when '1',
--                   "XXXXXXXXXX" when others;


--State machine process
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= S0;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;
    
    process(cur_state, i_start, o_end)
    begin
        next_state <= cur_state;
        case cur_state is
            when S0 =>
                if i_start = '1' then
                next_state <= S1;
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
                next_state <= S0;
        end case;
    end process;
    
    process(cur_state)
    begin
        r1_load <= '0';
        r2_load <= '0';
        r3_load <= '0';
        o_address <= "0000000000001000";
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';
        case cur_state is
            when S0 =>
            when S1 =>
                o_address <= "0000000000001000";
                temp <= "0000000000001000";
                o_en <= '1';
                o_we <= '0';
                r1_load <= '1';
                r2_load <= '0';
            when S2 =>
                if (temp = "0000000000001000") then
                    o_address <= "0000000000000000";
                    temp <= "0000000000000000";
                else
                    o_address <= std_logic_vector(unsigned(temp) + 1);
                    temp <= std_logic_vector(unsigned(temp) + 1);
                end if;
                o_en <= '1';
                o_we <= '0';
                r1_load <= '0';
                r2_load <= '1';
            when S3 =>
                o_address <= "0000000000001001";
                o_en <= '1';
                o_we <= '1';
                r1_load <= '0';
                r2_load <= '0';
        end case;
    end process;
end Behavioral;
