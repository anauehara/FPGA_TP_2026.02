library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encoder is
    generic (
        register_size : positive := 10;
        DEBOUNCE_TIME : positive := 27000
    );
    port (
        i_clk      : in  std_logic;
        i_rst_n    : in  std_logic;
        i_a        : in  std_logic;
        i_b        : in  std_logic;
        i_pb       : in  std_logic;
        o_position : out std_logic_vector(register_size - 1 downto 0);
        o_pb       : out std_logic
    );
end entity encoder;

architecture rtl of encoder is

    component debounce is
        generic (
            DEBOUNCE_TIME : positive := 100000
        );
        port (
            i_clk    : in  std_logic;
            i_rst_n  : in  std_logic;
            i_btn    : in  std_logic;
            o_btn_db : out std_logic
        );
    end component;

    signal s_a_db  : std_logic;
    signal s_b_db  : std_logic;
    signal s_pb_db : std_logic;

    signal r_a1 : std_logic := '0';
    signal r_a2 : std_logic := '0';
    signal r_b1 : std_logic := '0';
    signal r_b2 : std_logic := '0';

    signal s_rising_a  : std_logic;
    signal s_falling_a : std_logic;
    signal s_rising_b  : std_logic;
    signal s_falling_b : std_logic;

    signal r_position : signed(register_size - 1 downto 0) := (others => '0');
begin

    debounce_a : component debounce
        generic map (DEBOUNCE_TIME => DEBOUNCE_TIME)
        port map (
            i_clk    => i_clk,
            i_rst_n  => i_rst_n,
            i_btn    => i_a,
            o_btn_db => s_a_db
        );

    debounce_b : component debounce
        generic map (DEBOUNCE_TIME => DEBOUNCE_TIME)
        port map (
            i_clk    => i_clk,
            i_rst_n  => i_rst_n,
            i_btn    => i_b,
            o_btn_db => s_b_db
        );

    debounce_pb : component debounce
        generic map (DEBOUNCE_TIME => DEBOUNCE_TIME)
        port map (
            i_clk    => i_clk,
            i_rst_n  => i_rst_n,
            i_btn    => i_pb,
            o_btn_db => s_pb_db
        );

    process(i_clk, i_rst_n)
    begin
        if (i_rst_n = '0') then
            r_a1 <= '0';
            r_a2 <= '0';
            r_b1 <= '0';
            r_b2 <= '0';
        elsif rising_edge(i_clk) then
            r_a1 <= s_a_db;
            r_b1 <= s_b_db;

            r_a2 <= r_a1;
            r_b2 <= r_b1;
        end if;
    end process;

    s_rising_a  <= r_a1 AND (NOT r_a2);
    s_falling_a <= (NOT r_a1) AND r_a2;
    s_rising_b  <= r_b1 AND (NOT r_b2);
    s_falling_b <= (NOT r_b1) AND r_b2;

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

    o_pb <= s_pb_db;

    o_position <= std_logic_vector(r_position);

end architecture rtl;
