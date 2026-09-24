quit -sim

if {[file exists work]} {
	vdel -all -lib work
}
vlib work

vcom hdmi_controler.vhdl
vcom hdmi_controler_tb.vhdl

vsim -t 1ns work.hdmi_controler_tb

add wave -divider Inputs:
add wave -color yellow uut/i_clk
add wave -color yellow uut/i_rst_n

add wave -divider Horizontal:
add wave -color cyan uut/r_h_count
add wave -color cyan uut/r_h_active

add wave -divider Vertical:
add wave -color magenta uut/r_v_count
add wave -color magenta uut/r_v_active

add wave -divider ADV7513:
add wave -color red uut/o_hdmi_hs
add wave -color red uut/o_hdmi_vs
add wave -color red uut/o_hdmi_de

add wave -divider Pixel:
add wave -color green uut/o_pixel_en
add wave -color green uut/o_pixel_address
add wave -color green uut/o_x_counter
add wave -color green uut/o_y_counter

run 4513090 ns
