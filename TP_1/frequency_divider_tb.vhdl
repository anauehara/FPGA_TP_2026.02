library ieee;
use ieee.std_logic_1164.all;

entity frequency_divider_tb is
end entity frequency_divider_tb;

architecture sim of frequency_divider_tb is
	constant DIVISOR : natural := 2;

	signal clk   : std_logic := '0';
	signal rst_n : std_logic := '0';
	signal o_clk : std_logic;
begin
	uut: entity work.frequency_divider
		generic map (
			DIVISOR => DIVISOR
		)
		port map (
			i_clk   => clk,
			i_rst_n => rst_n,
			o_clk   => o_clk
		);

	clk_process: process
	begin
		clk <= not clk;
		wait for 10 ns;
	end process;

	stim_proc: process
	begin
		rst_n <= '0';
		wait for 20 ns;

		rst_n <= '1';

		wait;
	end process;
end architecture sim;
