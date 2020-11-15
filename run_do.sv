vlog apb_mem.sv
vlog test_dut.sv

vsim -novopt test_dut

add wave -position insertpoint sim:/test_dut/*
add wave -position insertpoint sim:/test_dut/dut/*

run -all