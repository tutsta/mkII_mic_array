
# set the Modelsim working library directory name
set work_lib work

# Create and/or map the libraries
vlib $work_lib
vmap $work_lib $work_lib

# Reset the file list
set vhdl_file_list ""

# Add source files to compile list

#lappend vhdl_file_list ../../../mic_array_ctrl_pkg.vhd
lappend vhdl_file_list ../../adc_spi_stream.vhd
lappend vhdl_file_list adc_spi_stream.vgen
lappend vhdl_file_list adc_spi_stream.tben

# Compile the files
foreach i $vhdl_file_list {
    puts "vcom -2002 -work $work_lib $i"
    vcom -2002 -work $work_lib $i
}
