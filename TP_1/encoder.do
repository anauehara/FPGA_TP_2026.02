quit -sim

if {[file exists work]} {
	vdel -all -lib work
}
vlib work

# debounce first: the encoder instantiates it
vcom debounce.vhdl
vcom encoder.vhdl
vcom encoder_tb.vhdl

vsim -t 1ns work.encoder_tb

# show only the signal name, not the whole hierarchy path
configure wave -signalnamewidth 1

# Signals keep the names they have in encoder.vhdl.
# Yellow = raw input (with bounce), pink = clean output.
add wave -divider Clock
add wave -color yellow /encoder_tb/uut/i_clk

add wave -divider Reset
add wave -color yellow /encoder_tb/uut/i_rst_n

add wave -divider {Channel A}
add wave -color yellow /encoder_tb/uut/i_a
add wave -color pink /encoder_tb/uut/s_a_db

add wave -divider {Channel B}
add wave -color yellow /encoder_tb/uut/i_b
add wave -color pink /encoder_tb/uut/s_b_db

add wave -divider Button
add wave -color yellow /encoder_tb/uut/i_pb
add wave -color pink /encoder_tb/uut/o_pb

add wave -divider Position
add wave -color pink -radix decimal /encoder_tb/uut/o_position

run 10500 ns
wave zoom full
# the testbench finishes at about 10300 ns; adjust if STEP or N_TURNS change
