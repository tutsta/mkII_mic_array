onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider {TESTBENCH TOP-LEVEL SIGNALS}
add wave -noupdate -format Logic -radix binary /host_spi_tben/clk
add wave -noupdate -format Logic -radix binary /host_spi_tben/reset
add wave -noupdate -format Logic -radix binary /host_spi_tben/cs_l
add wave -noupdate -format Logic -radix binary /host_spi_tben/sclk
add wave -noupdate -format Logic -radix binary /host_spi_tben/sdi
add wave -noupdate -format Logic -radix binary /host_spi_tben/sdo
add wave -noupdate -format Logic -radix binary /host_spi_tben/hst_dv
add wave -noupdate -format Logic -radix binary /host_spi_tben/hst_ack
add wave -noupdate -format Logic -radix hexadecimal /host_spi_tben/cmd
add wave -noupdate -format Logic -radix hexadecimal /host_spi_tben/addr
add wave -noupdate -format Logic -radix hexadecimal /host_spi_tben/hst_din
add wave -noupdate -format Logic -radix hexadecimal /host_spi_tben/hst_dout
add wave -noupdate -divider {VGEN INTERNAL SIGNALS}
add wave -noupdate -divider {DUT INTERNAL SIGNALS}
add wave -noupdate -format Logic -radix binary /host_spi_tben/dut/reset_reg
add wave -noupdate -format Logic -radix binary /host_spi_tben/dut/cs_reg
add wave -noupdate -format Logic -radix binary /host_spi_tben/dut/cs_reg_d1
add wave -noupdate -format Logic -radix binary /host_spi_tben/dut/cs_rising
add wave -noupdate -format Logic -radix binary /host_spi_tben/dut/sclk_reg
add wave -noupdate -format Logic -radix binary /host_spi_tben/dut/sdi_reg
add wave -noupdate -format Logic -radix binary /host_spi_tben/dut/hst_ack_reg
add wave -noupdate -format Logic -radix binary /host_spi_tben/dut/sclk_reg_d1
add wave -noupdate -format Logic -radix binary /host_spi_tben/dut/sclk_rising
add wave -noupdate -format Logic -radix binary /host_spi_tben/dut/sclk_falling
add wave -noupdate -format Logic -radix hexadecimal {/host_spi_tben/dut/din_des(31 downto 0)}
add wave -noupdate -format Logic -radix binary /host_spi_tben/dut/din_des
add wave -noupdate -format Logic -radix binary /host_spi_tben/dut/bit_count_en
add wave -noupdate -format Logic -radix binary /host_spi_tben/dut/bit_count_rst
add wave -noupdate -format Logic -radix hexadecimal /host_spi_tben/dut/bit_count
add wave -noupdate -format Logic -radix binary /host_spi_tben/dut/latch_din
add wave -noupdate -format Logic -radix binary /host_spi_tben/dut/hst_dv_int
add wave -noupdate -format Logic -radix hexadecimal /host_spi_tben/dut/hst_data
add wave -noupdate -format Logic -radix hexadecimal /host_spi_tben/dut/sdo_data_en
add wave -noupdate -format Logic -radix hexadecimal /host_spi_tben/dut/hst_din_latch
add wave -noupdate -format Logic -radix binary /host_spi_tben/dut/first_bit
add wave -noupdate -format Logic -radix binary /host_spi_tben/dut/first_bit_d1
add wave -noupdate -format Logic -radix binary /host_spi_tben/dut/first_bit_pulse
add wave -noupdate -format Logic -radix binary /host_spi_tben/dut/read_en


TreeUpdate [SetDefaultTree]
WaveRestoreCursors {50 ns}
WaveRestoreZoom {0 ns} {100 ns}
#WaveRestoreZoom {3556293 ps} {3862703 ps}
configure wave -namecolwidth 500
configure wave -valuecolwidth 77
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
