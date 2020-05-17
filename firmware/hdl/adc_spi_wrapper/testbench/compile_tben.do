
# set the Modelsim working library directory name
set work_lib work

# Create and/or map the libraries
vlib $work_lib
vmap $work_lib $work_lib

# Reset the file list
set vhdl_file_list ""

# Add source files to compile list

#lappend vhdl_file_list ../../mic_array_ctrl_pkg.vhd
lappend vhdl_file_list ../adc_spi_wrapper_v1_0_M00_AXIS.vhd
lappend vhdl_file_list ../adc_spi_wrapper_v1_0_M01_AXIS.vhd
lappend vhdl_file_list ../adc_spi_wrapper_v1_0_S00_AXI.vhd
lappend vhdl_file_list ../adc_spi_wrapper_v1_0_S01_AXIS.vhd
lappend vhdl_file_list ../adc_spi_wrapper_v1_0.vhd

# Add testbench files
lappend vhdl_file_list adc_spi_wrapper_v1_0.vgen
lappend vhdl_file_list adc_spi_wrapper_v1_0.tben

# Compile the files
foreach i $vhdl_file_list {
    puts "vcom -2002 -work $work_lib $i"
    vcom -2002 -work $work_lib $i
}
