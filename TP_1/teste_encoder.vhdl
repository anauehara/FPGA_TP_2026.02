library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity teste_encoder is
    genric (
        register_size : positive := 10
    );
    port (
        i_clk_50 : in  std_logic;
        i_rst_n  : in  std_logic;
        i_a      : in  std_logic;
        i_b      : in  std_logic;
        o_leds   : out std_logic_vector(register_size - 1 downto 0)
    );
end entity teste_encoder;

architecture rtl of teste_encoder is
    signal s_clk_div : std_logic;
    signal s_position : std_logic_vector(register_size - 1 downto 0);
begin

    u_div : entity work.frequency_divider
        generic map (
            DIVISOR => 2
        )
        port map (
            i_clk   => i_clk_50,
            i_rst_n => i_rst_n,
            o_clk   => s_clk_div
        );

    u_encoder : entity work.encoder
        generic map (
            register_size => register_size
        )
        port map (
            i_clk      => s_clk_div,
            i_rst_n    => i_rst_n,
            i_a        => i_a,
            i_b        => i_b,
            o_position => s_position
        );
    o_leds <= s_position;

end architecture rtl;
