TARGET=SOC
TOP=SOC

OBJS = SOC.v
OBJS+= cores/cpu/femtorv32_quark.v
OBJS+= cores/uart/perip_uart.v
OBJS+= cores/uart/uart.v
OBJS+= cores/mult/perip_mult.v
OBJS+= cores/mult/mult.v
OBJS+= cores/dpRAM/dpram.v
OBJS+= cores/dpRAM/perip_dpram.v



BUILD_DIR = build

all: $(TARGET).bit

${TARGET}.svf : ${TARGET}.bit

clean:
	rm -rf impl obj_dir *svg a.out *.vcd *.json *.bit build *.asc
sim: 
	rm -f a.out *.vcd
	iverilog -DBENCH -DSIM -DPASSTHROUGH_PLL -DBOARD_FREQ=27 -DCPU_FREQ=27 bench_iverilog.v soc_femto.v
	vvp a.out
	gtkwave bench.vcd

sim_quark:
	rm -f a.out *.vcd
	iverilog -DBENCH -DSIM -DPASSTHROUGH_PLL -DBOARD_FREQ=27 -DCPU_FREQ=27 bench_quark.v $(OBJS)
	vvp a.out
	gtkwave bench.vcd


sim_verilator: 
	verilator -CFLAGS '-I../libfemtorv32/ -DSTANDALONE_FEMTOELF' -DBENCH -DBOARD_FREQ=10 -DCPU_FREQ=10 -DPASSTHROUGH_PLL -Wno-fatal \
	--top-module SOC -cc -exe sim_main.cpp libfemtorv32/femto_elf.c soc_femto.v
	cd obj_dir; make -f VSOC.mk 
	obj_dir/VSOC
  	
svg: $(OBJS)
	yosys -p "prep -top ${TARGET}; write_json ${TARGET}.json" -DPASSTHROUGH_PLL -DBOARD_FREQ=27 -DCPU_FREQ=27  ${OBJS}
	netlistsvg ${TARGET}.json -o ${TARGET}.svg  #--skin default.svg
	yosys -p "prep -top ${TARGET} -flatten; write_json ${TARGET}_flat.json" ${OBJS}
	netlistsvg ${TARGET}_flat.json -o ${TARGET}_flat.svg  #--skin default.svg

configure: ${TARGET}.fs
	sudo openFPGALoader -b tangprimer20k -m impl/pnr/project.fs


$(TARGET).json: $(OBJS)
	mkdir -p $(BUILD_DIR)
	yosys -p 'synth_ice40 -top $(TOP) -json ${TARGET}.json' $(OBJS)

$(TARGET).asc: $(TARGET).json
	nextpnr-ice40 --hx4k --package tq144 --json ${TARGET}.json --pcf ${TARGET}.pcf --asc ${TARGET}.asc --pcf-allow-unconstrained


$(TARGET).bit: $(TARGET).asc
	icepack $(TARGET).asc $(TARGET).bit

configure_lattice: ${TARGET}.bit   # TDI:TDO:TCK:TMS
#	sudo openFPGALoader -c ft232RL --pins=1:2:0:3 -m ${TARGET}.bit 	
	sudo openFPGALoader -c ft232RL --pins=RXD:RTS:TXD:CTS -m $(BUILD_DIR)/${TARGET}.bit 	


.PHONY: clean
