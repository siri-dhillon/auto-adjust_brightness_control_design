onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 30 /spi_controller_tb/clk
add wave -noupdate -height 30 /spi_controller_tb/rst
add wave -noupdate -height 30 /spi_controller_tb/cs
add wave -noupdate -height 30 /spi_controller_tb/sclk
add wave -noupdate -height 30 /spi_controller_tb/miso
add wave -noupdate -height 30 /spi_controller_tb/ready
add wave -noupdate -height 30 /spi_controller_tb/valid
add wave -noupdate -height 30 /spi_controller_tb/data
add wave -noupdate -height 30 /spi_controller_tb/next_sample
add wave -noupdate -height 30 /spi_controller_tb/DUT/state
add wave -noupdate -height 30 /spi_controller_tb/DUT/data_bits
add wave -noupdate -height 30 /spi_controller_tb/DUT/sclk_counter
add wave -noupdate -height 30 /spi_controller_tb/DUT/clk_counter
add wave -noupdate -height 30 /spi_controller_tb/DUT/sclk_sig
add wave -noupdate -height 30 /spi_controller_tb/DUT/inputFF
add wave -noupdate -height 30 /spi_controller_tb/DUT/inputFF2
add wave -noupdate -height 30 /spi_controller_tb/DUT/stable_miso
add wave -noupdate -height 30 /spi_controller_tb/DUT/max_count
add wave -noupdate -height 30 /spi_controller_tb/DUT/sclk_rising_edge
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
WaveRestoreZoom {0 ps} {65929500 ps}
