library ieee;
use ieee.std_logic_1164.all;

entity encoder_clk is 
    port (
        i_clk: in std_logic;
        i_rst_n: in std_logic;
        i_a        : in  std_logic;
        i_b        : in  std_logic;
        i_pb       : in  std_logic;
        o_leds: out std_logic_vector(9 downto 0)
    );
end entity encoder_clk;

architecture rtl of encoder_clk is
    component frequency_divider is
        generic (
            DIVISOR : natural := 2
        );
        port (
            i_clk   : in  std_logic;
            i_rst_n : in  std_logic;
            o_clk   : out std_logic
        );
    end component;

    component encoder is 
        generic (
            register_size : positive := 10
        );
        port (
            i_clk      : in  std_logic;
            i_rst_n    : in  std_logic;
            i_a        : in  std_logic;
            i_b        : in  std_logic;
            i_pb       : in  std_logic;
            o_position : out std_logic_vector(register_size - 1 downto 0)
        );
    end component;

    signal s_clk : std_logic;
    signal s_position: std_logic_vector(9 downto 0);

begin 
    freq_div: component frequency_divider 
        generic map (
            DIVISOR => 1
        )
        port map (
            i_clk => i_clk,
            i_rst_n => i_rst_n,
            o_clk => s_clk
        );

    encoder0 : component encoder
        generic map (
            register_size => 10
        )
        port map (
            i_clk      => s_clk,
            i_rst_n    => i_rst_n,
            i_a        => i_a,
            i_b        => i_b,
            i_pb       => i_pb,
            o_position => s_position
        );
 
    o_leds <= s_position;

end architecture rtl;