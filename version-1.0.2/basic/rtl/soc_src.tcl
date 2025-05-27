set_device -name GW2A-18C GW2A-LV18PG256C8/I7
add_file soc_femto.cst
add_file SOC.v
add_file cores/cpu/femtorv32_quark.v
add_file cores/uart/perip_uart.v
add_file cores/uart/uart.v
add_file cores/mult/mult.v
add_file cores/mult/perip_mult.v
set_option -use_mspi_as_gpio 1
set_option -use_sspi_as_gpio 1
set_option -use_ready_as_gpio 1
set_option -use_done_as_gpio 1
set_option -rw_check_on_ram 1
run all
