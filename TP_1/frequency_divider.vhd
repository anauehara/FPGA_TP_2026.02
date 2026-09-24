library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frequency_divider is
    port (
        i_clk      : in  std_logic;
        i_rst_n    : in  std_logic;
        o_clk      : out std_logic;
    );
end entity frequency_divider;

architecture rtl of frequency_divider is
    
begin

    process(i_clk, i_rst_n)
    begin
        if (i_rst_n = '0') then
            r_leds <= "0000000001";
        elsif (rising_edge(i_clk)) then
            if (r_led_enable = '1') then
                r_leds <= r_leds(8 downto 0) & r_leds(9);
            end if;
        end if;
    end process;

end architecture rtl;