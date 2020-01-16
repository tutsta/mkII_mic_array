onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {VGEN CLOCKS AND RESETS}
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/clk
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/reset
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/m00_axis_aresetn

add wave -noupdate -divider {TOP-LEVEL TESTBENCH SIGNALS}
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/stream_go
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/spi0_sclk_i
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/spi0_sclk_o
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/spi0_mosi_i
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/spi0_mosi_o
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/spi0_miso_i
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/spi0_ss_i
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/spi0_ss_o
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/spi_sclk
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/spi_mosi
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/spi_miso
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/spi_ss
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/adc_drdy_n
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/m00_axis_tvalid
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_axi_stream_tben/m00_axis_tdata
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/m00_axis_tstrb
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/m00_axis_tlast
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/m00_axis_tready

add wave -noupdate -divider {ADC SPI-AXI_S INTERFACE TOP WRAPPER SIGNALS}
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_axi_stream_tben/dut/s_fifo_dout
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/s_fifo_rden
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/s_fifo_full
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/s_fifo_empty

add wave -noupdate -divider {ADC SPI STREAM WRAPPER SIGNALS}
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/s_adc_spi_sclk
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/s_adc_spi_dout
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/s_adc_spi_din
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/s_adc_drdy_n
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/s_fifo_din
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/s_fifo_wren
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/s_fifo_full
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/s_fifo_reset

add wave -noupdate -divider {FIFO TO AXI-S CONTROLLER SIGNALS}
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/fifo2axi4s_v1_0_1/s_fifo_data_rdy
add wave -noupdate -format literal /adc_spi_axi_stream_tben/dut/fifo2axi4s_v1_0_1/fifo2axi4s_v1_0_m00_axis_inst/mst_exec_state
add wave -noupdate -format Logic -radix unsigned /adc_spi_axi_stream_tben/dut/fifo2axi4s_v1_0_1/fifo2axi4s_v1_0_m00_axis_inst/read_pointer
add wave -noupdate -format Logic -radix unsigned /adc_spi_axi_stream_tben/dut/fifo2axi4s_v1_0_1/fifo2axi4s_v1_0_m00_axis_inst/count
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/fifo2axi4s_v1_0_1/fifo2axi4s_v1_0_m00_axis_inst/axis_tvalid
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/fifo2axi4s_v1_0_1/fifo2axi4s_v1_0_m00_axis_inst/axis_tvalid_delay
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/fifo2axi4s_v1_0_1/fifo2axi4s_v1_0_m00_axis_inst/axis_tlast
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/fifo2axi4s_v1_0_1/fifo2axi4s_v1_0_m00_axis_inst/axis_tlast_delay
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_axi_stream_tben/dut/fifo2axi4s_v1_0_1/fifo2axi4s_v1_0_m00_axis_inst/stream_data_out
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/fifo2axi4s_v1_0_1/fifo2axi4s_v1_0_m00_axis_inst/tx_en
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/fifo2axi4s_v1_0_1/fifo2axi4s_v1_0_m00_axis_inst/tx_done
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/fifo2axi4s_v1_0_1/fifo2axi4s_v1_0_m00_axis_inst/s_fifo_rden

add wave -noupdate -divider {ADC SPI CONTROLLER INTERNAL SIGNALS}
add wave -noupdate -format literal /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/sm_state
add wave -noupdate -format Logic -radix unsigned /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_state_decode
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_stream_go_reg
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_stream_go_pipe
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_stream_go_dly
add wave -noupdate -format Logic -radix unsigned /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_sclk_div_cnt
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_sclk_free_run
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_sclk_free_run_d1
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_sclk_rising
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_sclk_rising_d1
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_sclk_falling
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_sclk_out_reg
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_spi_mux_sel
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_adc_spi_cs
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_sclk_en
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_bit_cnt_rst
add wave -noupdate -format Logic -radix unsigned /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_bit_cnt
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_cmd_word_reg
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_adc_dout
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_adc_spi_din
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_adc_spi_din_reg 
add wave -noupdate -format Logic -radix unsigned /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_samp_word_bit_cnt
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_samp_word
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_samp_word_latch
add wave -noupdate -format Logic -radix binary /adc_spi_axi_stream_tben/dut/adc_spi_stream_wrap_1/adc_spi_stream_1/s_samp_fifo_wren


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
