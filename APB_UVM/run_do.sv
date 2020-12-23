vlog tb_top.sv

vsim -novopt top

add wave -position insertpoint sim:/top/clk
add wave -position insertpoint sim:/top/intf/*

run -all