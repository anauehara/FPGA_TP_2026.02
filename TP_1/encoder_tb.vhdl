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
	-- tempo estavel entre transicoes de A/B (maior que a latencia do debounce)
	constant STEP          : time     := 200 ns;
	-- numero de voltas completas para frente (cada volta = +2 ou -2)
	constant N_TURNS       : positive := 2;

	signal clk      : std_logic := '0';
	signal rst_n    : std_logic := '0';
	signal a        : std_logic := '0';
	signal b        : std_logic := '0';
	signal pb       : std_logic := '1';   -- botao ativo em '0': solto = '1'
	signal position : std_logic_vector(register_size - 1 downto 0);
	signal pb_db    : std_logic;

	-- contadores de transicoes do botao: antes e depois do debounce
	signal pb_raw_edges : natural := 0;
	signal pb_db_edges  : natural := 0;
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
			o_position => position,
			o_pb       => pb_db
		);

	clk_process: process
	begin
		clk <= not clk;
		wait for 10 ns;
	end process;

	-- conta quantas vezes o botao muda antes e depois do debounce
	raw_edge_proc: process(pb)
	begin
		if pb'event then
			pb_raw_edges <= pb_raw_edges + 1;
		end if;
	end process;

	db_edge_proc: process(pb_db)
	begin
		if pb_db'event then
			pb_db_edges <= pb_db_edges + 1;
		end if;
	end process;

	stim_proc: process
		variable seed1 : positive := 42;
		variable seed2 : positive := 7;
		variable v_raw0 : natural;
		variable v_db0  : natural;

		-- leva o sinal ao valor final com trepidacao (bounce) aleatoria:
		-- 2 a 5 oscilacoes, cada pulso de 20 a 40 ns (1 a 2 periodos de clock,
		-- entao o debounce enxerga o ruido), depois fica estavel por STEP.
		-- O bounce dura menos que a janela de estabilidade do debounce em cada
		-- pulso (4 ciclos = 80 ns), por isso a saida filtrada so muda uma vez.
		procedure noisy_set(signal s : out std_logic; constant val : in std_logic) is
			variable r : real;
			variable n : integer;
		begin
			uniform(seed1, seed2, r);
			n := 2 + integer(trunc(r * 4.0));
			for k in 1 to n loop
				s <= val;
				uniform(seed1, seed2, r);
				wait for 20 ns + r * 20 ns;
				s <= not val;
				uniform(seed1, seed2, r);
				wait for 20 ns + r * 20 ns;
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

		procedure check_pb(constant expected : in std_logic) is
		begin
			assert pb_db = expected
				report "o_pb = " & std_logic'image(pb_db)
					& ", esperado " & std_logic'image(expected)
				severity error;
		end procedure;
	begin
		a     <= '0';
		b     <= '0';
		pb    <= '1';
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

		-- para tras (uma volta): b adianta a (00 -> 01 -> 11 -> 10 -> 00), position desce
		noisy_set(b, '1');
		noisy_set(a, '1');
		noisy_set(b, '0');
		noisy_set(a, '0');
		check(2 * N_TURNS - 2);

		-- reset no meio da simulacao: position volta a zero
		wait until rising_edge(clk);
		wait for 5 ns;
		rst_n <= '0';
		wait for 60 ns;
		rst_n <= '1';
		wait for STEP;
		check(0);

		-- logo depois do reset: aperta e solta o botao (ativo em '0'), com trepidacao
		v_raw0 := pb_raw_edges;
		v_db0  := pb_db_edges;

		noisy_set(pb, '0');
		check_pb('0');

		noisy_set(pb, '1');
		check_pb('1');

		report "botao: " & integer'image(pb_raw_edges - v_raw0)
			& " transicoes brutas -> " & integer'image(pb_db_edges - v_db0)
			& " transicoes depois do debounce";
		assert (pb_db_edges - v_db0) = 2
			report "o debounce deveria deixar so 2 transicoes (apertar e soltar)"
			severity error;

		-- depois do reset a contagem recomeca do zero: uma volta para frente
		noisy_set(a, '1');
		noisy_set(b, '1');
		noisy_set(a, '0');
		noisy_set(b, '0');
		check(2);

		-- duas voltas para tras: position passa por zero e fica negativa
		for i in 1 to 2 loop
			noisy_set(b, '1');
			noisy_set(a, '1');
			noisy_set(b, '0');
			noisy_set(a, '0');
		end loop;
		check(-2);

		report "fim da simulacao em " & time'image(now) severity note;
		wait;
	end process;
end architecture sim;
