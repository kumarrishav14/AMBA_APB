vlog test_arch.sv

vsim -novopt top +UVM_VERBOSITY=UVM_HIGH

add wave -position insertpoint sim:/top/clk
add wave -position insertpoint sim:/top/intf/*

run -all