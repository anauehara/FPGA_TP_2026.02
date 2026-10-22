quit -sim

if {[file exists work]} {
	vdel -all -lib work
}
vlib work

vcom debounce.vhdl
vcom debounce_tb.vhdl

vsim -t 1ns work.debounce_tb

add wave -divider Inputs:
add wave -color yellow uut/i_clk
add wave -color yellow uut/i_rst_n
add wave -color yellow uut/i_btn

add wave -divider Internal:
add wave uut/s_btn_sync1
add wave uut/s_btn_sync2

add wave -divider Outputs:
add wave -color green uut/o_btn_db

run 4000 ns
