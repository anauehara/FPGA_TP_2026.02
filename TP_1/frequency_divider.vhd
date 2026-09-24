library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frequency_divider is
    generic (
        DIVISOR : natural := 2
    );
    port (
        i_clk   : in  std_logic;
        i_rst_n : in  std_logic;
        o_clk   : out std_logic
    );
end entity frequency_divider;

architecture rtl of frequency_divider is
    signal counter : natural range 0 to DIVISOR - 1 := 0;
    signal clk_out : std_logic := '0';
begin

    process(i_clk, i_rst_n)
    begin
        if (i_rst_n = '0') then
            counter <= 0;
            clk_out <= '0';
        elsif rising_edge(i_clk) then
            if counter = DIVISOR - 1 then
                counter <= 0;
                clk_out <= not clk_out;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    o_clk <= clk_out;

end architecture rtl;