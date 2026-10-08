library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity encoder_tb is
end entity encoder_tb;

architecture sim of encoder_tb is
	constant register_size : positive := 10;
	-- valor pequeno so para simular: amostra A/B a cada 4 ciclos = 80 ns
	constant DEBOUNCE_TIME : positive := 4;
	-- tempo estavel entre transicoes de A/B (bem maior que os 80 ns de amostragem)
	constant STEP          : time     := 200 ns;
	-- numero de voltas completas em cada sentido (cada volta = +2 ou -2)
	constant N_TURNS       : positive := 8;

	signal clk      : std_logic := '0';
	signal rst_n    : std_logic := '0';
	signal a        : std_logic := '0';
	signal b        : std_logic := '0';
	signal pb       : std_logic := '1';
	signal position : std_logic_vector(register_size - 1 downto 0);
begin
	uut: entity work.encoder
		generic map (
			register_size => register_size,
			DEBOUNCE_TIME => DEBOUNCE_TIME
		)
		port map (
			i_clk      => clk,
			i_rst_n    => rst_n,
			i_a        => a,
			i_b        => b,
			i_pb       => pb,
			o_position => position
		);

	clk_process: process
	begin
		clk <= not clk;
		wait for 10 ns;
	end process;

	stim_proc: process
		variable seed1 : positive := 42;
		variable seed2 : positive := 7;

		-- leva o sinal ao valor final com bounce aleatorio:
		-- 2 a 5 oscilacoes, cada pulso de 1 a 6 ns (no maximo ~60 ns no total,
		-- menor que o periodo de amostragem de 80 ns), depois fica estavel
		procedure noisy_set(signal s : out std_logic; constant val : in std_logic) is
			variable r : real;
			variable n : integer;
		begin
			uniform(seed1, seed2, r);
			n := 2 + integer(trunc(r * 4.0));
			for k in 1 to n loop
				s <= val;
				uniform(seed1, seed2, r);
				wait for 1 ns + r * 5 ns;
				s <= not val;
				uniform(seed1, seed2, r);
				wait for 1 ns + r * 5 ns;
			end loop;
			s <= val;
			wait for STEP;
		end procedure;

		procedure check(constant expected : in integer) is
		begin
			assert to_integer(signed(position)) = expected
				report "position = " & integer'image(to_integer(signed(position)))
					& ", esperado " & integer'image(expected)
				severity error;
		end procedure;
	begin
		a     <= '0';
		b     <= '0';
		rst_n <= '0';
		wait for 20 ns;

		rst_n <= '1';
		-- 25 ns: desloca os estimulos para nao mudarem em cima da borda do clock
		wait for 25 ns;

		-- para frente: a adianta b (00 -> 10 -> 11 -> 01 -> 00), position sobe
		for i in 1 to N_TURNS loop
			noisy_set(a, '1');
			noisy_set(b, '1');
			noisy_set(a, '0');
			noisy_set(b, '0');
		end loop;
		check(2 * N_TURNS);

		-- para tras: b adianta a (00 -> 01 -> 11 -> 10 -> 00), position desce
		for i in 1 to N_TURNS loop
			noisy_set(b, '1');
			noisy_set(a, '1');
			noisy_set(b, '0');
			noisy_set(a, '0');
		end loop;
		check(0);

		-- vai e volta: meia volta para frente, meia para tras, varias vezes
		for i in 1 to 4 loop
			noisy_set(a, '1');
			noisy_set(b, '1');
			noisy_set(b, '0');
			noisy_set(a, '0');
		end loop;
		check(0);

		report "fim da simulacao" severity note;
		wait;
	end process;
end architecture sim;
