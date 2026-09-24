library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encoder is
    port (
        i_clk      : in  std_logic;
        i_rst_n    : in  std_logic;
        i_a        : in  std_logic;
        i_b        : in  std_logic;
        o_position : out integer range -32768 to 32767
    );
end entity encoder;

architecture rtl of encoder is
    
begin



end architecture rtl;
