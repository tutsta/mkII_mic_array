onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {VGEN CLOCKS AND RESETS}
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/clk
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/reset

add wave -noupdate -divider {TOP-LEVEL SIGNALS}
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/stream_go
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/hst_adc_spi_cs
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/hst_adc_spi_sclk
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/hst_adc_spi_dout
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/hst_adc_spi_din
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/adc_spi_cs
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/adc_spi_sclk
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/adc_spi_dout
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/adc_spi_din
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/adc_drdy_n
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_stream_tben/sample_dout
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/fifo_wren
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/fifo_full
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/fifo_reset

add wave -noupdate -divider {VGEN SIGNALS}
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/vgen/reset
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/vgen/stream_go
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/vgen/hst_adc_spi_cs
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/vgen/hst_adc_sclk
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/vgen/hst_adc_spi_dout
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/vgen/adc_spi_din
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/vgen/adc_drdy_n
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/vgen/adc_spi_cs_reg 
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/vgen/adc_spi_cs_d1
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/vgen/adc_spi_cs_rising
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/vgen/adc_spi_cs_falling
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/vgen/adc_spi_sclk_reg
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/vgen/adc_spi_sclk_d1
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/vgen/adc_spi_dout_reg
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/vgen/adc_spi_rw_latch
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/vgen/adc_rw_bit_latched
add wave -noupdate -format Logic -radix unsigned /adc_spi_stream_tben/vgen/adc_spi_bit_cnt
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_stream_tben/vgen/adc_read_word
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_stream_tben/vgen/sample_data_latch
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/vgen/fifo_full

add wave -noupdate -divider {DUT INTERNAL SIGNALS}
add wave -noupdate -format literal /adc_spi_stream_tben/dut/sm_state
add wave -noupdate -format Logic -radix unsigned /adc_spi_stream_tben/dut/s_state_decode
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/dut/s_stream_go_reg
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/dut/s_stream_go_pipe
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/dut/s_stream_go_dly
add wave -noupdate -format Logic -radix unsigned /adc_spi_stream_tben/dut/s_sclk_div_cnt
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/dut/s_sclk_free_run
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/dut/s_sclk_free_run_d1
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/dut/s_sclk_rising
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/dut/s_sclk_rising_d1
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/dut/s_sclk_falling
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/dut/s_sclk_out_reg
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/dut/s_spi_mux_sel
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/dut/s_adc_spi_cs
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/dut/s_sclk_en
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/dut/s_bit_cnt_rst
add wave -noupdate -format Logic -radix unsigned /adc_spi_stream_tben/dut/s_bit_cnt
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/dut/s_cmd_word_reg
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/dut/s_adc_dout
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/dut/s_adc_spi_din
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/dut/s_adc_spi_din_reg 
add wave -noupdate -format Logic -radix unsigned /adc_spi_stream_tben/dut/s_samp_word_bit_cnt
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_stream_tben/dut/s_samp_word
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_stream_tben/dut/s_samp_word_latch
add wave -noupdate -format Logic -radix binary /adc_spi_stream_tben/dut/s_samp_fifo_wren


   
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
