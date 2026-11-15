quit -sim

if {[file exists work]} {
	vdel -all -lib work
}
vlib work

vcom hdmi_controler.vhdl
vcom hdmi_controler_tb.vhdl

# 1 ps resolution: the 27 MHz clock has a 37.036 ns period
vsim -t 1ps work.hdmi_controler_tb

# Builds the wave window from scratch. Signals keep the names they have in
# hdmi_controler.vhdl (i_clk, i_rst_n, r_h_count, r_v_count, o_hdmi_hs, ...).
#   with_h   : show r_h_count (useless at frame zoom, it is just a blur)
#   with_clk : show the clock (only useful at cycle zoom)
proc setup_wave {with_h with_clk} {
	delete wave *

	# show only the signal name, not the whole hierarchy path
	configure wave -signalnamewidth 1

	if {$with_clk} {
		add wave -divider Clock
		add wave -color yellow /hdmi_controler_tb/uut/i_clk
	}

	add wave -divider Reset
	add wave -color yellow /hdmi_controler_tb/uut/i_rst_n

	if {$with_h} {
		add wave -divider {H count}
		add wave -color cyan -radix unsigned /hdmi_controler_tb/uut/r_h_count
	}

	add wave -divider {V count}
	add wave -color magenta -radix unsigned /hdmi_controler_tb/uut/r_v_count

	add wave -divider {Horizontal sync}
	add wave -color red /hdmi_controler_tb/uut/o_hdmi_hs

	add wave -divider {Vertical sync}
	add wave -color red /hdmi_controler_tb/uut/o_hdmi_vs

	add wave -divider {Data enable}
	add wave -color red /hdmi_controler_tb/uut/o_hdmi_de
}

# Figure 1: one full line (line 100, in the middle of the active area)
proc fig_line {} {
	setup_wave 1 0
	wave zoom range 3176200ns 3211200ns
}

# Figure 2: frame change (a bit more than one frame)
proc fig_frame {} {
	setup_wave 0 0
	wave zoom full
}

# Figure 3: a few clock cycles where o_hdmi_de rises (r_h_count 120 to 121)
proc fig_detail {} {
	setup_wave 1 1
	wave zoom range 3181980ns 3182360ns
}

# Record the signals BEFORE running. A signal that is only added to the wave
# window after the run shows "No Data", because its history was never saved.
log /hdmi_controler_tb/uut/i_clk
log /hdmi_controler_tb/uut/i_rst_n
log /hdmi_controler_tb/uut/r_h_count
log /hdmi_controler_tb/uut/r_v_count
log /hdmi_controler_tb/uut/o_hdmi_hs
log /hdmi_controler_tb/uut/o_hdmi_vs
log /hdmi_controler_tb/uut/o_hdmi_de

# one frame is 858 * 525 = 450450 cycles = 16.68 ms
run 17500 us

# type fig_line, fig_frame or fig_detail in the console to switch figures
fig_line
