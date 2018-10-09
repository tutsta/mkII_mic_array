onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {VGEN CLOCKS AND RESETS}
add wave -noupdate -format Logic -radix binary /control_sm_tben/clk
add wave -noupdate -divider {TOP-LEVEL SIGNALS}
add wave -noupdate -format Logic -radix binary /control_sm_tben/reset
add wave -noupdate -format Logic -radix binary /control_sm_tben/soft_reset
add wave -noupdate -format Logic -radix binary /control_sm_tben/hard_reset
add wave -noupdate -format Logic -radix binary /control_sm_tben/clear_regs
add wave -noupdate -format Logic -radix binary /control_sm_tben/hst_dv
add wave -noupdate -format Logic -radix binary /control_sm_tben/hst_dv_reg
add wave -noupdate -format Logic -radix binary /control_sm_tben/hst_ack
add wave -noupdate -format Logic -radix binary /control_sm_tben/hst_ack_top
add wave -noupdate -format Logic -radix binary /control_sm_tben/hst_ack_ctrl
add wave -noupdate -format Logic -radix hexadecimal /control_sm_tben/cmd
add wave -noupdate -format Logic -radix hexadecimal /control_sm_tben/cmd_reg
add wave -noupdate -format Logic -radix binary /control_sm_tben/adc_wr_en
add wave -noupdate -format Logic -radix binary /control_sm_tben/adc_spi_send
add wave -noupdate -format Logic -radix binary /control_sm_tben/adc_send_done
add wave -noupdate -format Logic -radix binary /control_sm_tben/local_we
add wave -noupdate -format Logic -radix binary /control_sm_tben/trig_start_str
add wave -noupdate -format Logic -radix binary /control_sm_tben/trig_stop_str
add wave -noupdate -format Logic -radix binary /control_sm_tben/trig_halt_str

add wave -noupdate -divider {DUT INTERNAL SIGNALS}
add wave -noupdate -format Logic -radix hexadecimal /control_sm_tben/dut/state_decode
add wave -noupdate -format Logic -radix binary /control_sm_tben/dut/reset_reg
add wave -noupdate -format Logic -radix binary /control_sm_tben/dut/hst_dv_reg
add wave -noupdate -format Logic -radix hexadecimal /control_sm_tben/dut/cmd_reg
add wave -noupdate -format Logic -radix binary /control_sm_tben/dut/adc_send_done_reg
add wave -noupdate -format Logic -radix binary /control_sm_tben/dut/hst_ack_int
add wave -noupdate -format Logic -radix binary /control_sm_tben/dut/trig_halt_str_int
add wave -noupdate -format Logic -radix binary /control_sm_tben/dut/trig_start_str_int
add wave -noupdate -format Logic -radix binary /control_sm_tben/dut/trig_stop_str_int
add wave -noupdate -format Logic -radix binary /control_sm_tben/dut/source_int
add wave -noupdate -format Logic -radix binary /control_sm_tben/dut/local_we_int
add wave -noupdate -format Logic -radix binary /control_sm_tben/dut/adc_wr_en_int
add wave -noupdate -format Logic -radix binary /control_sm_tben/dut/adc_spi_send_int

   
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
