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
    signal r_cnt : natural range 0 to DEBOUNCE_TIME - 1 := 0;
    signal r_stable : std_logic := '0';
    signal r_last : std_logic := '0';
    signal r_in_sync : std_logic := '0';

begin

    process(i_clk, i_rst_n)
    begin
        if (i_rst_n = '0') then
            r_cnt <= 0;
            r_stable <= '0';
            r_last <= '0';
            r_in_sync <= '0';
        elsif rising_edge(i_clk) then
            r_in_sync <= i_btn;
            r_last <= r_in_sync;
            if (r_last /= r_in_sync) then
                r_cnt <= 0;
            elsif (r_cnt >= DEBOUNCE_TIME - 1) then
                    r_stable <= r_last;
            else
                r_cnt <= r_cnt + 1;
            end if;
        end if;
    end process;

    o_btn_db <= r_stable;


end architecture rtl;
