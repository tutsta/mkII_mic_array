onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {VGEN CLOCKS AND RESETS}
add wave -noupdate -format Logic -radix binary /adc_spi_engine_tben/spi_clk
add wave -noupdate -divider {TOP-LEVEL SIGNALS}
add wave -noupdate -format Logic -radix binary /adc_spi_engine_tben/reset
add wave -noupdate -format Logic -radix binary /adc_spi_engine_tben/adc_spi_rw
add wave -noupdate -format Logic -radix binary /adc_spi_engine_tben/adc_spi_rw_done
add wave -noupdate -format Logic -radix binary /adc_spi_engine_tben/adc_wr_en
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_engine_tben/cmd_addr
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_engine_tben/adc_din
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_engine_tben/adc_dout

add wave -noupdate -divider {DUT INTERNAL SIGNALS}
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_engine_tben/dut/s_sm_state
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_engine_tben/dut/s_state_decode
add wave -noupdate -format Logic -radix binary /adc_spi_engine_tben/dut/s_adc_spi_rw
add wave -noupdate -format Logic -radix binary /adc_spi_engine_tben/dut/s_adc_spi_rw_d
add wave -noupdate -format Logic -radix binary /adc_spi_engine_tben/dut/s_adc_spi_rw_pulse
add wave -noupdate -format Logic -radix binary /adc_spi_engine_tben/dut/s_adc_wr_en
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_engine_tben/dut/s_cmd_addr
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_engine_tben/dut/s_adc_din
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_engine_tben/dut/s_cmd_addr_l
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_engine_tben/dut/s_adc_din_l
add wave -noupdate -format Logic -radix binary /adc_spi_engine_tben/dut/s_cs_l
add wave -noupdate -format Logic -radix binary /adc_spi_engine_tben/dut/s_sclk
add wave -noupdate -format Logic -radix binary /adc_spi_engine_tben/dut/s_adc_dout
add wave -noupdate -format Logic -radix unsigned /adc_spi_engine_tben/dut/s_cmd_addr_seq_cnt
add wave -noupdate -format Logic -radix binary /adc_spi_engine_tben/dut/s_cmd_addr_seq_cnt_en
add wave -noupdate -format Logic -radix binary /adc_spi_engine_tben/dut/s_sclk_en
add wave -noupdate -format Logic -radix binary /adc_spi_engine_tben/dut/s_bit_cnt_en
add wave -noupdate -format Logic -radix unsigned /adc_spi_engine_tben/dut/s_bit_cnt
add wave -noupdate -format Logic -radix binary /adc_spi_engine_tben/dut/s_inc_byte_cnt
add wave -noupdate -format Logic -radix unsigned /adc_spi_engine_tben/dut/s_byte_cnt


   
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
