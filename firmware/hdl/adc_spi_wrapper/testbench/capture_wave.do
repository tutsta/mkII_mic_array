onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {VGEN CLOCKS AND RESETS}
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s00_axi_aclk   
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s00_axi_aclk   
add wave -noupdate -divider {TESTBENCH TOP-LEVEL SIGNALS}
add wave -noupdate -divider {ADC SPI INTERFACE}
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/spi0_sclk_i    
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/spi0_sclk_o    
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/spi0_mosi_i    
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/spi0_mosi_o    
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/spi0_miso_i    
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/spi0_ss_i      
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/spi0_ss_o      
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/spi_sclk       
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/spi_mosi       
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/spi_miso       
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/spi_ss         
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/adc_drdy_n

add wave -noupdate -divider {Datamover control interface}
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/dut/l_dm_command_word
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_dm_send_command
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_dm_send_done
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/m01_axis_aclk
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_dm_reset_n
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/m01_axis_tvalid
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/dut/m01_axis_tdata
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/dut/m01_axis_tstrb
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/m01_axis_tlast
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/m01_axis_tready

add wave -noupdate -divider {Datamover FIFO-to-AXI stream interface}
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/dut/l_fifo_dout
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_fifo_rden
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_fifo_empty
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_fifo_full
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/m00_axis_aclk
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/m00_axis_aresetn
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/m00_axis_tvalid
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/dut/m00_axis_tdata
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/dut/m00_axis_tstrb
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/m00_axis_tlast
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/m00_axis_tready

add wave -noupdate -divider {Datamover status interface}
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_dm_read_status
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_dm_status_rdy
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/dut/l_dm_status
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/s01_axis_aclk
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/s01_axis_aresetn
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/s01_axis_tready
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/dut/s01_axis_tdata
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/s01_axis_tstrb
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/s01_axis_tlast
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/s01_axis_tvalid


#add wave -noupdate -divider {AXI-REGISTER INTERFACE}
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s00_axi_aclk   
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s00_axi_aresetn
#add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/s00_axi_awaddr
#add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/s00_axi_awprot
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s00_axi_awvalid
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s00_axi_awready
#add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/s00_axi_wdata
#add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/s00_axi_wstrb
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s00_axi_wvalid
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s00_axi_wready
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s00_axi_bresp 
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s00_axi_bvalid
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s00_axi_bready
#add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/s00_axi_araddr
#add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/s00_axi_arprot
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s00_axi_arvalid
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s00_axi_arready
#add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/s00_axi_rdata
#add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/s00_axi_rresp
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s00_axi_rvalid  
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s00_axi_rready

#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/m00_axis_aclk
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/m00_axis_aresetn
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/m00_axis_tvalid
#add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/m00_axis_tdata
#add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/m00_axis_tstrb
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/m00_axis_tlast
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/m00_axis_tready
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/m01_axis_aclk
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/m01_axis_aresetn
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/m01_axis_tvalid
#add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/m01_axis_tdata
#add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/m01_axis_tstrb
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/m01_axis_tlast
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/m01_axis_tready 
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s01_axis_aclk   
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s01_axis_aresetn
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s01_axis_tready 
#add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/s01_axis_tdata
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s01_axis_tstrb 
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s01_axis_tlast 
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/s01_axis_tvalid

add wave -noupdate -divider {VGEN SIGNALS}
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/vgen/s00_axi_araddr
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/vgen/s00_axi_arvalid
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/vgen/s00_axi_rready
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/vgen/s00_axi_rdata
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/vgen/s00_axi_rresp
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/vgen/s00_axi_awaddr
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/vgen/s00_axi_wdata
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/vgen/s00_axi_awvalid
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/vgen/s00_axi_wvalid
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/vgen/s00_axi_bready
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/vgen/s00_axi_bresp
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/vgen/l_trig_reg_read 
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/vgen/l_trig_reg_write
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/vgen/l_s00_axi_araddr
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/vgen/l_s00_axi_rdata 
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/vgen/l_s00_axi_rresp
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/vgen/l_s00_axi_awaddr
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/vgen/l_s00_axi_wdata 
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/vgen/l_s00_axi_bresp

add wave -noupdate -divider {DUT TOP-LLEVEL SIGNALS}
add wave -noupdate -format Literal /adc_spi_wrapper_v1_0_tben/dut/l_sm_state
add wave -noupdate -format Logic -radix unsigned /adc_spi_wrapper_v1_0_tben/dut/l_state_decode
add wave -noupdate -format Logic -radix unsigned /adc_spi_wrapper_v1_0_tben/dut/l_watchdog_cnt
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_watchdog_err
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_adc_stream_go
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_adc_stream_go_reg
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_adc_stream_go_rising
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_adc_spi_ctrl_reset
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_dm_ps_reset
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_dm_reset_n
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_dm_start_addr_inc
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/dut/l_dm_start_addr
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/dut/l_dm_start_addr_latch
add wave -noupdate -format Logic -radix unsigned /adc_spi_wrapper_v1_0_tben/dut/l_dm_bursts
add wave -noupdate -format Logic -radix unsigned /adc_spi_wrapper_v1_0_tben/dut/l_dm_bursts_latch
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_dm_burst_cnt_inc
add wave -noupdate -format Logic -radix unsigned /adc_spi_wrapper_v1_0_tben/dut/l_dm_burst_cnt
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_dm_burst_cnt_reached
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_dm_send_command
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_dm_send_done
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/dut/l_dm_command_word
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_dm_read_status
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_dm_status_rdy
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/dut/l_dm_status
add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/dut/l_fifo_dout
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_fifo_rden
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_fifo_full
add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_fifo_empty

#add wave -noupdate -divider {DUT INTERNAL SIGNALS}
#add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/dut/adc_spi_stream_wrap_1/s_fifo_din
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/adc_spi_stream_wrap_1/s_fifo_wren
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/adc_spi_stream_wrap_1/s_fifo_full
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/adc_spi_stream_wrap_1/s_fifo_reset
#add wave -noupdate -format Logic -radix hexadecimal /adc_spi_wrapper_v1_0_tben/dut/l_fifo_dout
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_fifo_rden
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_fifo_full
#add wave -noupdate -format Logic -radix binary /adc_spi_wrapper_v1_0_tben/dut/l_fifo_empty


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
