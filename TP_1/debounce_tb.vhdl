library ieee;
use ieee.std_logic_1164.all;

entity debounce_tb is
end entity debounce_tb;

architecture sim of debounce_tb is
	-- valor pequeno so para simular: amostra a cada 20 ciclos = 400 ns
	-- (na placa use algo como 100000)
	constant DEBOUNCE_TIME : positive := 20;

	signal clk    : std_logic := '0';
	signal rst_n  : std_logic := '0';
	signal btn    : std_logic := '0';
	signal btn_db : std_logic;
begin
	uut: entity work.debounce
		generic map (
			DEBOUNCE_TIME => DEBOUNCE_TIME
		)
		port map (
			i_clk    => clk,
			i_rst_n  => rst_n,
			i_btn    => btn,
			o_btn_db => btn_db
		);

	clk_process: process
	begin
		clk <= not clk;
		wait for 10 ns;
	end process;

	stim_proc: process
	begin
		rst_n <= '0';
		btn   <= '0';
		wait for 40 ns;

		rst_n <= '1';
		wait for 200 ns;

		-- aperto com bounce (~160 ns oscilando, menor que o periodo de 400 ns)
		btn <= '1'; wait for 30 ns;
		btn <= '0'; wait for 20 ns;
		btn <= '1'; wait for 40 ns;
		btn <= '0'; wait for 30 ns;
		btn <= '1'; wait for 20 ns;
		btn <= '0'; wait for 20 ns;
		btn <= '1';

		-- botao pressionado e estavel
		wait for 1500 ns;

		-- soltura com bounce
		btn <= '0'; wait for 30 ns;
		btn <= '1'; wait for 20 ns;
		btn <= '0'; wait for 40 ns;
		btn <= '1'; wait for 30 ns;
		btn <= '0'; wait for 20 ns;
		btn <= '1'; wait for 20 ns;
		btn <= '0';

		-- botao solto e estavel
		wait for 1500 ns;

		wait;
	end process;
end architecture sim;
