onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /spi_ready_reset_tb/state
add wave -noupdate /spi_ready_reset_tb/clk_counter
add wave -noupdate /spi_ready_reset_tb/clk
add wave -noupdate /spi_ready_reset_tb/rst
add wave -noupdate /spi_ready_reset_tb/reset
add wave -noupdate /spi_ready_reset_tb/cs
add wave -noupdate /spi_ready_reset_tb/sclk
add wave -noupdate /spi_ready_reset_tb/miso
add wave -noupdate /spi_ready_reset_tb/ready
add wave -noupdate /spi_ready_reset_tb/valid
add wave -noupdate /spi_ready_reset_tb/data
add wave -noupdate /spi_ready_reset_tb/next_sample
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {42455482044 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {134207099250 ps}
