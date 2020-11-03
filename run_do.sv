vlog test_arch.sv
vsim -novopt test_arch

add wave -position insertpoint sim:/test_arch/intf/*

run -all