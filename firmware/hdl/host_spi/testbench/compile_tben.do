#--------------------------------------------------------------------------------
# Unisim and XilinxCoreLib Library mappings
#--------------------------------------------------------------------------------
#vmap unisim C:/Xilinx/14.6/ISE_DS/ISE/vhdl/se_60a/unisim
#vmap xilinxcorelib C:/Xilinx/14.6/ISE_DS/ISE/vhdl/se_60a/xilinxcorelib

# set the Modelsim working library directory name
set work_lib work

# Create and/or map the libraries
vlib $work_lib
vmap $work_lib $work_lib

#--------------------------------------------------------------------------------
# Compile the common packages
#--------------------------------------------------------------------------------

# Reset the file list
set vhdl_file_list ""

# Add source files to compile list

lappend vhdl_file_list ../host_spi.vhd
lappend vhdl_file_list host_spi.vgen
lappend vhdl_file_list host_spi.tben

# Compile the files
foreach i $vhdl_file_list {
    puts "vcom -work $work_lib $i"
    vcom -2002 -work $work_lib $i
}
