onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /spi_controller_tb/clk
add wave -noupdate /spi_controller_tb/rst
add wave -noupdate /spi_controller_tb/cs
add wave -noupdate /spi_controller_tb/sclk
add wave -noupdate /spi_controller_tb/miso
add wave -noupdate /spi_controller_tb/ready
add wave -noupdate /spi_controller_tb/valid
add wave -noupdate /spi_controller_tb/data
add wave -noupdate /spi_controller_tb/next_sample
add wave -noupdate /spi_controller_tb/BFM/next_sample
add wave -noupdate /spi_controller_tb/BFM/cs
add wave -noupdate /spi_controller_tb/BFM/sclk
add wave -noupdate /spi_controller_tb/BFM/miso
add wave -noupdate /spi_controller_tb/BFM/cs_delta_delay
add wave -noupdate /spi_controller_tb/DUT/clk
add wave -noupdate /spi_controller_tb/DUT/rst
add wave -noupdate /spi_controller_tb/DUT/cs
add wave -noupdate /spi_controller_tb/DUT/sclk
add wave -noupdate /spi_controller_tb/DUT/miso
add wave -noupdate /spi_controller_tb/DUT/ready
add wave -noupdate /spi_controller_tb/DUT/valid
add wave -noupdate /spi_controller_tb/DUT/data
add wave -noupdate /spi_controller_tb/DUT/state
add wave -noupdate /spi_controller_tb/DUT/data_bits
add wave -noupdate /spi_controller_tb/DUT/sclk_counter
add wave -noupdate /spi_controller_tb/DUT/clk_counter
add wave -noupdate /spi_controller_tb/DUT/sclk_sig
add wave -noupdate /spi_controller_tb/DUT/inputFF
add wave -noupdate /spi_controller_tb/DUT/inputFF2
add wave -noupdate /spi_controller_tb/DUT/stable_miso
add wave -noupdate /spi_controller_tb/DUT/max_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10152081 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 216
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
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {13124790 ps}
