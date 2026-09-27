quit -sim

if {[file exists work]} {
	vdel -all -lib work
}
vlib work

vcom frequency_divider.vhdl
vcom frequency_divider_tb.vhdl

vsim -t 1ns work.frequency_divider_tb

add wave -divider Inputs:
add wave -color yellow uut/i_clk
add wave -color yellow uut/i_rst_n

add wave -divider Outputs:
add wave -color green uut/o_clk

run 1000 ns
# adjust the run length above to whatever actually exercises this module's behavior
