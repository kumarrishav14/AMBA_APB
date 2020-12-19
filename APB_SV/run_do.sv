vlog tb_top.sv

vsim -novopt tb_top

add wave -position insertpoint sim:/tb_top/intf/*

run -all