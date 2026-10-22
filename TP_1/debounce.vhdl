library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
    generic (
        DEBOUNCE_TIME : positive := 100000
    );
    port (
        i_clk : in std_logic;
        i_rst_n : in std_logic;
        i_btn : in std_logic;
        o_btn_db : out std_logic
    );
end entity debounce;

architecture rtl of debounce is
    signal s_btn_sync1 : std_logic := '0';
    signal s_btn_sync2 : std_logic := '0';

begin

    process(i_clk, i_rst_n)
        variable v_count : natural := 0;
    begin
        if (i_rst_n = '0') then
            v_count := 0;
            o_btn_db <= '0';
        elsif rising_edge(i_clk) then
            s_btn_sync1 <= i_btn;
            s_btn_sync2 <= s_btn_sync1;

            

            if (v_count = DEBOUNCE_TIME - 1) then
                o_btn_db <= s_btn_sync2;
                v_count := 0;
            else
                v_count := v_count + 1;
            end if;

        end if;
    
    end process;


end architecture rtl;
