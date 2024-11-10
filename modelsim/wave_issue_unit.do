onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /issue_unit_tb/clk
add wave -noupdate /issue_unit_tb/rst_n
add wave -noupdate /issue_unit_tb/ready_int
add wave -noupdate /issue_unit_tb/ready_mult
add wave -noupdate /issue_unit_tb/ready_div
add wave -noupdate /issue_unit_tb/ready_mem
add wave -noupdate -color {Violet Red} /issue_unit_tb/div_exec_busy
add wave -noupdate /issue_unit_tb/issue_int
add wave -noupdate /issue_unit_tb/issue_mult
add wave -noupdate /issue_unit_tb/issue_div
add wave -noupdate /issue_unit_tb/issue_mem
add wave -noupdate /issue_unit_tb/cdb_output
add wave -noupdate -expand -group {rsv station} /issue_unit_tb/issue_unit/cdb_rsv_station/i_clk
add wave -noupdate -expand -group {rsv station} /issue_unit_tb/issue_unit/cdb_rsv_station/i_rst_n
add wave -noupdate -expand -group {rsv station} -color Gold /issue_unit_tb/issue_unit/cdb_rsv_station/ready_int
add wave -noupdate -expand -group {rsv station} -color Gold /issue_unit_tb/issue_unit/cdb_rsv_station/ready_mult
add wave -noupdate -expand -group {rsv station} -color Gold /issue_unit_tb/issue_unit/cdb_rsv_station/ready_div
add wave -noupdate -expand -group {rsv station} -color Gold /issue_unit_tb/issue_unit/cdb_rsv_station/ready_mem
add wave -noupdate -expand -group {rsv station} -color {Medium Violet Red} /issue_unit_tb/issue_unit/cdb_rsv_station/div_exec_busy
add wave -noupdate -expand -group {rsv station} /issue_unit_tb/issue_unit/cdb_rsv_station/issue_int_done
add wave -noupdate -expand -group {rsv station} /issue_unit_tb/issue_unit/cdb_rsv_station/issue_mem_done
add wave -noupdate -expand -group {rsv station} /issue_unit_tb/issue_unit/cdb_rsv_station/issue_mult_done
add wave -noupdate -expand -group {rsv station} /issue_unit_tb/issue_unit/cdb_rsv_station/issue_div_done
add wave -noupdate -expand -group {rsv station} /issue_unit_tb/issue_unit/cdb_rsv_station/current_op
add wave -noupdate -expand -group {rsv station} /issue_unit_tb/issue_unit/cdb_rsv_station/rsv_mult
add wave -noupdate -expand -group {rsv station} /issue_unit_tb/issue_unit/cdb_rsv_station/rsv_div
add wave -noupdate -expand -group {rsv station} /issue_unit_tb/issue_unit/cdb_rsv_station/issue_oneclk_write
add wave -noupdate -expand -group {rsv station} /issue_unit_tb/issue_unit/cdb_rsv_station/issue_mult_write
add wave -noupdate -expand -group {rsv station} /issue_unit_tb/issue_unit/cdb_rsv_station/issue_div_write
add wave -noupdate -expand -group {rsv station} /issue_unit_tb/issue_unit/cdb_rsv_station/lru
add wave -noupdate -expand -group {rsv station} -radix hexadecimal -childformat {{/issue_unit_tb/issue_unit/cdb_output.cdb_tag -radix hexadecimal} {/issue_unit_tb/issue_unit/cdb_output.cdb_valid -radix hexadecimal} {/issue_unit_tb/issue_unit/cdb_output.cdb_result -radix hexadecimal} {/issue_unit_tb/issue_unit/cdb_output.cdb_branch -radix hexadecimal} {/issue_unit_tb/issue_unit/cdb_output.cdb_branch_taken -radix hexadecimal} {/issue_unit_tb/issue_unit/cdb_output.issue_done -radix hexadecimal}} -expand -subitemconfig {/issue_unit_tb/issue_unit/cdb_output.cdb_tag {-height 15 -radix hexadecimal} /issue_unit_tb/issue_unit/cdb_output.cdb_valid {-height 15 -radix hexadecimal} /issue_unit_tb/issue_unit/cdb_output.cdb_result {-height 15 -radix hexadecimal} /issue_unit_tb/issue_unit/cdb_output.cdb_branch {-height 15 -radix hexadecimal} /issue_unit_tb/issue_unit/cdb_output.cdb_branch_taken {-height 15 -radix hexadecimal} /issue_unit_tb/issue_unit/cdb_output.issue_done {-height 15 -radix hexadecimal}} /issue_unit_tb/issue_unit/cdb_output
add wave -noupdate -expand -group {cdb mux} /issue_unit_tb/issue_unit/cdb_mux/i_a
add wave -noupdate -expand -group {cdb mux} /issue_unit_tb/issue_unit/cdb_mux/i_b
add wave -noupdate -expand -group {cdb mux} /issue_unit_tb/issue_unit/cdb_mux/i_c
add wave -noupdate -expand -group {cdb mux} /issue_unit_tb/issue_unit/cdb_mux/i_d
add wave -noupdate -expand -group {cdb mux} -color Magenta /issue_unit_tb/issue_unit/cdb_mux/i_selector
add wave -noupdate -expand -group {cdb mux} /issue_unit_tb/issue_unit/cdb_mux/out
add wave -noupdate /issue_unit_tb/issue_unit/sign_prop_div/d
add wave -noupdate /issue_unit_tb/issue_unit/sign_prop_div/q
add wave -noupdate /issue_unit_tb/issue_unit/sign_prop_mult/d
add wave -noupdate /issue_unit_tb/issue_unit/sign_prop_mult/q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {18262 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 405
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
WaveRestoreZoom {0 ps} {26250 ps}
