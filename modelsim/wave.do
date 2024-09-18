onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /ifq_tb/clk
add wave -noupdate -radix hexadecimal /ifq_tb/rst_n
add wave -noupdate -radix hexadecimal /ifq_tb/pc_in
add wave -noupdate -expand -group i_cache -radix hexadecimal /ifq_tb/procesador/cache/pc_in
add wave -noupdate -expand -group i_cache -radix hexadecimal /ifq_tb/procesador/cache/rd_en
add wave -noupdate -expand -group i_cache -radix hexadecimal /ifq_tb/procesador/cache/abort
add wave -noupdate -expand -group i_cache -radix hexadecimal /ifq_tb/procesador/cache/we
add wave -noupdate -expand -group i_cache -radix hexadecimal /ifq_tb/procesador/cache/clk
add wave -noupdate -expand -group i_cache -radix hexadecimal /ifq_tb/procesador/cache/dout
add wave -noupdate -expand -group i_cache -radix hexadecimal /ifq_tb/procesador/cache/dout_valid
add wave -noupdate -expand -group i_cache -radix hexadecimal /ifq_tb/procesador/cache/map_Address
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1898 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 258
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {4631 ps}
