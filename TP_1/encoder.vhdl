library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encoder is
    generic (
        register_size : positive := 10
    );
    port (
        i_clk      : in  std_logic;
        i_rst_n    : in  std_logic;
        i_a        : in  std_logic;
        i_b        : in  std_logic;
        o_position : out std_logic_vector(register_size - 1 downto 0)
    );
end entity encoder;

architecture rtl of encoder is
    -- synchronization registers
    signal r_a1 : std_logic := '0';
    signal r_a2 : std_logic := '0';
    signal r_b1 : std_logic := '0';
    signal r_b2 : std_logic := '0';

    -- edge detection
    signal s_rising_a  : std_logic;
    signal s_falling_a : std_logic;
    signal s_rising_b  : std_logic;
    signal s_falling_b : std_logic;

    -- position register
    signal r_position : signed(register_size - 1 downto 0) := (others => '0');
begin

    -- synchronize the asynchronous inputs i_a and i_b
    process(i_clk, i_rst_n)
    begin
        if (i_rst_n = '0') then
            r_a1 <= '0';
            r_a2 <= '0';
            r_b1 <= '0';
            r_b2 <= '0';
        elsif rising_edge(i_clk) then
            r_a1 <= i_a;
            r_a2 <= r_a1;
            r_b1 <= i_b;
            r_b2 <= r_b1;
        end if;
    end process;

    -- detect rising and falling edges of A and B
    s_rising_a  <= r_a1 AND (NOT r_a2);
    s_falling_a <= (NOT r_a1) AND r_a2;
    s_rising_b  <= r_b1 AND (NOT r_b2);
    s_falling_b <= (NOT r_b1) AND r_b2;

    -- update the position based on the edges detected
    process(i_clk, i_rst_n)
    begin
        if (i_rst_n = '0') then
            r_position <= (others => '0');
        elsif rising_edge(i_clk) then
            if ((s_rising_a = '1') and (r_b1 = '0')) or ((s_falling_a = '1') and (r_b1 = '1')) then
                r_position <= r_position + 1;
            elsif ((s_rising_b = '1') and (r_a1 = '0')) or ((s_falling_b = '1') and (r_a1 = '1')) then
                r_position <= r_position - 1;
            end if;
        end if;
    end process;

    o_position <= std_logic_vector(r_position);

end architecture rtl;