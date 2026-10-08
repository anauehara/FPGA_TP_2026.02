library ieee;
use ieee.std_logic_1164.all;

entity encoder_tb is
end entity encoder_tb;

architecture sim of encoder_tb is
	constant register_size : positive := 10;

	signal clk      : std_logic := '0';
	signal rst_n    : std_logic := '0';
	signal a        : std_logic := '0';
	signal b        : std_logic := '0';
	signal position : std_logic_vector(register_size - 1 downto 0);
begin
	uut: entity work.encoder
		generic map (
			register_size => register_size
		)
		port map (
			i_clk      => clk,
			i_rst_n    => rst_n,
			i_a        => a,
			i_b        => b,
			o_position => position
		);

	clk_process: process
	begin
		clk <= not clk;
		wait for 10 ns;
	end process;

	stim_proc: process
	begin
		a     <= '0';
		b     <= '0';
		rst_n <= '0';
		wait for 20 ns;

		rst_n <= '1';
		wait for 20 ns;

		-- para frente: a adianta b (00 -> 10 -> 11 -> 01 -> 00), position sobe
		for i in 0 to 3 loop
			a <= '1';
			wait for 20 ns;
			b <= '1';
			wait for 20 ns;
			a <= '0';
			wait for 20 ns;
			b <= '0';
			wait for 20 ns;
		end loop;

		-- para tras: b adianta a (00 -> 01 -> 11 -> 10 -> 00), position desce
		for i in 0 to 3 loop
			b <= '1';
			wait for 20 ns;
			a <= '1';
			wait for 20 ns;
			b <= '0';
			wait for 20 ns;
			a <= '0';
			wait for 20 ns;
		end loop;

		wait;
	end process;
end architecture sim;
