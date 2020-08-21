----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.08.2020 01:22:55
-- Design Name: 
-- Module Name: datapath - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity datapath is
    Port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_data : out std_logic_vector (7 downto 0);
        r1_load : in std_logic;
        r2_load : in std_logic;
        r3_load : in std_logic;
        o_end : out std_logic);
end datapath;

architecture Behavioral of datapath is
signal o_reg1 : std_logic_vector (7 downto 0);
signal o_reg2 : std_logic_vector (7 downto 0);
signal o_reg3 : std_logic_vector (7 downto 0);
signal o_reg4 : std_logic_vector (7 downto 0);
signal sub : std_logic_vector (7 downto 0);
signal d_sel : std_logic;
begin
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

    o_reg4 <= ('1' & o_reg3(6 downto 0)) when (o_reg3 /= "00001000"
                        and ((sub = "00000000") or
                            (sub = "00000001") or
                            (sub = "00000010") or
                            (sub = "00000011")));
    
        o_reg4 <= (o_reg1) when(o_reg3 = "00000111" and
                            (sub >= "00000011" or
                            sub <= "00000000"));
end Behavioral;
