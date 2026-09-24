library ieee;
use ieee.std_logic_1164.all;

entity hdmi_controler_tb is
end entity hdmi_controler_tb;

architecture sim of hdmi_controler_tb is
	constant h_res  : positive := 720;
	constant v_res  : positive := 480;
	constant h_sync : positive := 61;
	constant h_fp   : positive := 58;
	constant h_bp   : positive := 18;
	constant v_sync : positive := 5;
	constant v_fp   : positive := 30;
	constant v_bp   : positive := 9;

	signal clk           : std_logic := '0';
	signal rst_n         : std_logic := '0';
	signal hdmi_hs       : std_logic;
	signal hdmi_vs       : std_logic;
	signal hdmi_de       : std_logic;
	signal pixel_en      : std_logic;
	signal pixel_address : natural range 0 to h_res * v_res - 1;
	signal x_counter     : natural range 0 to h_res - 1;
	signal y_counter     : natural range 0 to v_res - 1;
begin
	uut: entity work.hdmi_controler
		generic map (
			h_res  => h_res,
			v_res  => v_res,
			h_sync => h_sync,
			h_fp   => h_fp,
			h_bp   => h_bp,
			v_sync => v_sync,
			v_fp   => v_fp,
			v_bp   => v_bp
		)
		port map (
			i_clk           => clk,
			i_rst_n         => rst_n,
			o_hdmi_hs       => hdmi_hs,
			o_hdmi_vs       => hdmi_vs,
			o_hdmi_de       => hdmi_de,
			o_pixel_en      => pixel_en,
			o_pixel_address => pixel_address,
			o_x_counter     => x_counter,
			o_y_counter     => y_counter
		);

	clk_process: process
	begin
		clk <= not clk;
		wait for 5 ns;
	end process;

	stim_proc: process
	begin
		rst_n <= '0';
		wait for 20 ns;

		rst_n <= '1';
		wait for 10 us;

		wait;
	end process;
end architecture sim;
