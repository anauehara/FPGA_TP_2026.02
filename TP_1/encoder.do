quit -sim

if {[file exists work]} {
	vdel -all -lib work
}
vlib work

vcom encoder.vhdl
vcom encoder_tb.vhdl

vsim -t 1ns work.encoder_tb

add wave -divider Inputs:
add wave -color yellow uut/i_clk
add wave -color yellow uut/i_rst_n
add wave -color yellow uut/i_a
add wave -color yellow uut/i_b

add wave -divider Internal:
add wave -radix unsigned uut/r_count
add wave uut/r_enable
add wave uut/r_a_sync
add wave uut/r_b_sync
add wave uut/r_a1
add wave uut/r_a2
add wave uut/r_b1
add wave uut/r_b2
add wave uut/s_rising_a
add wave uut/s_falling_a
add wave uut/s_rising_b
add wave uut/s_falling_b
add wave -radix decimal uut/r_position

add wave -divider Outputs:
add wave -color green -radix decimal uut/o_position

run 23000 ns
# adjust the run length above to whatever actually exercises this module's behavior
