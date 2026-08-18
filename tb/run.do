transcript on

if {[file exists work]} {
    vdel -lib work -all
}
vlib work

puts "Generating BIT-ACCURATE MATLAB FFT golden vectors..."
if {[catch {exec matlab -batch "run('fft_golden.m')" 2>@1} matlab_result]} {
    puts $matlab_result
    puts "ERROR: MATLAB vector generation failed."
    quit -code 1
}
puts $matlab_result

# Guard against accidentally running an old fft_golden.m.
if {[string first "RTL_BIT_ACCURATE_FLOOR_V3" $matlab_result] < 0} {
    puts "ERROR: Wrong/old fft_golden.m is being executed."
    puts "Expected version stamp: RTL_BIT_ACCURATE_FLOOR_V3"
    quit -code 1
}

vlog -sv Complex_pack.sv
vlog -sv BUTTERFLY.sv Complex_MULT.sv DELAY.sv ROM.sv Counter.sv Control_unit.sv SDF_STAGE.sv FFT_Top.sv
vlog -sv tb_fft.sv

vsim -voptargs=+acc work.tb_fft

add wave -divider "TOP STREAM"
add wave sim:/tb_fft/clk
add wave sim:/tb_fft/rstn
add wave sim:/tb_fft/valid_in
add wave -radix decimal sim:/tb_fft/DIN.re
add wave -radix decimal sim:/tb_fft/DIN.im
add wave sim:/tb_fft/Valid_out
add wave -radix decimal sim:/tb_fft/DOUT.re
add wave -radix decimal sim:/tb_fft/DOUT.im
add wave -position insertpoint  \
sim:/tb_fft/dut/ctrl_inst/counter_out


add wave -divider "CONTROL"
add wave -radix unsigned sim:/tb_fft/dut/ctrl_inst/counter_out
add wave -radix binary sim:/tb_fft/dut/ctrl_inst/valid_pipe
add wave -radix unsigned sim:/tb_fft/dut/rom_addr1
add wave -radix unsigned sim:/tb_fft/dut/rom_addr2

run -all

# Plot DUT vs MATLAB for the first five cases after a successful exact-match run.
if {[file exists plot_fft_DUT.m]} {
    puts "Generating first-five DUT vs MATLAB plots..."
    if {[catch {exec matlab -batch "run('plot_fft_DUT.m')" 2>@1} plot_result]} {
        puts $plot_result
        puts "WARNING: FFT simulation passed, but plotting failed."
    } else {
        puts $plot_result
    }
}
